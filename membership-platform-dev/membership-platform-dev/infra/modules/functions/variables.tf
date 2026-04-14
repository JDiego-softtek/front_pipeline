variable "name" {
  type = string
}

variable "location" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "service_plan_id" {
  type = string
}

variable "storage_account_name" {
  type = string
}

variable "storage_account_access_key" {
  type      = string
  sensitive = true
}

variable "vnet_integration_subnet_id" {
  type = string
}

variable "cosmos_secret_uri" {
  type        = string
  description = "Secret URI en Key Vault (ejemplo)"
}

variable "tags" {
  type    = map(string)
  default = {}
}