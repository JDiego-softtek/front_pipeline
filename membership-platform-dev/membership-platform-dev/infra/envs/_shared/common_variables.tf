# ===========================================================================
# TEMPLATE FILE — DO NOT USE DIRECTLY
# This file is a scaffolding template only. It is never loaded by Terraform
# at runtime from this location. Copy it into a new layer or environment
# directory (e.g. infra/envs/<env>/<layer>/common_variables.tf) as a starting point.
# ===========================================================================

# ---------------------------------------------------------------------------
# SHARED COMMON VARIABLES
# These variable definitions are identical across app, network, observability,
# and security layers. Each layer should have its own copy or reference this
# file as the source of truth for variable definitions.
# ---------------------------------------------------------------------------

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
