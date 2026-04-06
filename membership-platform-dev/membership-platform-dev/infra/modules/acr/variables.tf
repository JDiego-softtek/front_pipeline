variable "name" {
  description = "Azure Container Registry name"
  type        = string
}

variable "resource_group_name" {
  description = "Resource group name where ACR will be created"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "sku" {
  description = "ACR SKU"
  type        = string
  default     = "Basic"

  validation {
    condition     = contains(["Basic", "Standard", "Premium"], var.sku)
    error_message = "Allowed values for sku are Basic, Standard, or Premium."
  }
}

variable "admin_enabled" {
  description = "Enable admin user for ACR"
  type        = bool
  default     = false
}

variable "public_network_access_enabled" {
  description = "Allow public access to ACR"
  type        = bool
  default     = true
}

variable "anonymous_pull_enabled" {
  description = "Allow anonymous pull"
  type        = bool
  default     = false
}

variable "zone_redundancy_enabled" {
  description = "Enable zone redundancy (Premium only in supported regions)"
  type        = bool
  default     = false
}

variable "identity_type" {
  description = "Managed identity type for ACR. Example: SystemAssigned"
  type        = string
  default     = null
}

variable "tags" {
  type    = map(string)
  default = {}
}