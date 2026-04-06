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
  description = "Application resource group name"
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

variable "backend_resource_group" {
  description = "Resource group containing the Terraform state storage account"
  type        = string
}

variable "backend_storage_account" {
  description = "Storage account name for Terraform remote state"
  type        = string
}

variable "backend_container" {
  description = "Blob container name for Terraform remote state"
  type        = string
  default     = "tfstate"
}
