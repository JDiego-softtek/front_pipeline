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
  description = "Resource group where all managed identities are created"
  type        = string
}

variable "location" {
  description = "Azure region"
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
