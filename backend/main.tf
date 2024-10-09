terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.2.0"
    }
  }
  backend "azurerm" {
    resource_group_name  = "arnehi-github-rg"          # Can be passed via `-backend-config=`"resource_group_name=<resource group name>"` in the `init` command.
    storage_account_name = "sa-github"                 # Can be passed via `-backend-config=`"storage_account_name=<storage account name>"` in the `init` command.
    container_name       = "sc-github"                 # Can be passed via `-backend-config=`"container_name=<container name>"` in the `init` command.
    key                  = "backend.terraform.tfstate" # Can be passed via `-backend-config=`"key=<blob key name>"` in the `init` command.
  }
}

provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy    = true
      recover_soft_deleted_key_vaults = true
    }
  }
  subscription_id = var.sid # Must be set in the backend configuration
}

data "azurerm_client_config" "current" {}

resource "random_string" "random_string" {
  length  = 8
  special = false
  upper   = false
}

######################################################################################################################

resource "azurerm_resource_group" "rg_backend" {
  name     = var.rg_name
  location = var.location
}

resource "azurerm_storage_account" "sa_backend" {
  name                     = "${lower(var.sa_name)}_${random_string.random_string.result}"
  resource_group_name      = var.rg_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "GRS"

  tags = {
    environment = "dev"
  }
}

resource "azurerm_storage_container" "sc_backend" {
  name                  = "${lower(var.sc_name)}_${random_string.random_string.result}"
  storage_account_name  = azurerm_storage_account.sa_backend.name
  container_access_type = "private"
}

resource "azurerm_key_vault" "kv_backend" {
  name                        = "${lower(var.kv_name)}_${random_string.random_string.result}"
  location                    = var.location
  resource_group_name         = var.rg_name
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false

  sku_name = "standard"

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    key_permissions = [
      "Get", "List", "Create",
    ]

    secret_permissions = [
      "Get", "List", "Set",
    ]

    storage_permissions = [
      "Get", "List", "Set",
    ]
  }
}

resource "azurerm_key_vault_secret" "sa_backend_access_key" {
  name         = var.ak_name
  value        = azurerm_storage_account.sa_backend.primary_access_key
  key_vault_id = azurerm_key_vault.kv_backend.id
}