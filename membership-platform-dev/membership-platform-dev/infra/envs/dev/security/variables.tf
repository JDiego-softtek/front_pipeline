variable "subscription_id" {
  description = "Azure subscription ID"
  type        = string
}

variable "project" {
  description = "Project short name"
  type        = string
}

variable "environment" {
  description = "Environment name (dev / qa / prod)"
  type        = string
}

variable "resource_group_name" {
  description = "Existing resource group name"
  type        = string
}

variable "location" {
  description = "Azure region for all resources"
  type        = string
}

variable "owner" {
  description = "Team or person responsible for this layer"
  type        = string
}

variable "cost_center" {
  description = "Cost center code for billing attribution"
  type        = string
}

variable "criticality" {
  description = "Workload criticality level"
  type        = string
  validation {
    condition     = contains(["low", "medium", "high", "critical"], var.criticality)
    error_message = "criticality must be one of: low, medium, high, critical."
  }
}

variable "workload" {
  description = "Workload or application name"
  type        = string
}

variable "keyvault_sku" {
  description = "Key Vault SKU (standard or premium)"
  type        = string
  default     = "standard"
}

variable "keyvault_public_access_enabled" {
  description = "Allow public network access to Key Vault. Set false in QA/Prod."
  type        = bool
  default     = true
}

variable "keyvault_purge_protection_enabled" {
  description = "Enable purge protection on Key Vault. Required for Prod."
  type        = bool
  default     = false
}

variable "keyvault_soft_delete_retention_days" {
  description = "Number of days to retain soft-deleted Key Vault resources (7-90)"
  type        = number
  default     = 7
}
