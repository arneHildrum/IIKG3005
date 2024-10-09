variable "rg_name" {
  description = "Resource Group Name"
  type        = string
  default     = "arnehi-github-rg"
}

variable "location" {
  description = "Location for the resources"
  type        = string
  default     = "Westeurope"
}

variable "sa_name" {
  description = "Storage Account Name"
  type        = string
  default     = "sa-github"
}

variable "sc_name" {
  description = "Name of the storage container"
  type        = string
  default     = "sc-github"
}

variable "kv_name" {
  description = "Name of the key vault"
  type        = string
  default     = "kv-github"
}

variable "ak_name" {
  description = "Name of the access key"
  type        = string
  default     = "ak-github"
}

variable "sid" {
  description = "Subscription ID"
  type        = string
  sensitive   = true
}