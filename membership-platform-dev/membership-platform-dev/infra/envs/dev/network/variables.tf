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

variable "vnet_cidr" {
  description = "Address space for the Virtual Network (CIDR notation)"
  type        = string
}

variable "subnets" {
  description = "Subnet definitions map. Key = subnet name."
  type = map(object({
    cidr = string
    delegation = optional(object({
      name    = string
      service = string
      actions = list(string)
    }))
  }))
}

variable "apim_subnet_name" {
  description = "Name of the subnet reserved for APIM (receives special NSG rules)"
  type        = string
  default     = "snet-apim"
}

variable "enable_private_endpoints" {
  description = "When true, creates snet-data and Private DNS zones. Set to false in dev to skip PE infrastructure until it is needed."
  type        = bool
  default     = false
}
