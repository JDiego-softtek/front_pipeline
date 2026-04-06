variable "name" {
  description = "Storage account name (3-24 chars, lowercase alphanumeric, globally unique)"
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9]{3,24}$", var.name))
    error_message = "Storage account name must be 3-24 lowercase alphanumeric characters."
  }
}

variable "resource_group_name" {
  description = "Resource group where the storage account will be created"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "replication_type" {
  description = "Storage replication type. Use LRS for dev, ZRS or GRS for prod."
  type        = string
  default     = "LRS"

  validation {
    condition     = contains(["LRS", "ZRS", "GRS", "RAGRS", "GZRS", "RAGZRS"], var.replication_type)
    error_message = "replication_type must be one of: LRS, ZRS, GRS, RAGRS, GZRS, RAGZRS."
  }
}

variable "public_network_access_enabled" {
  description = "Allow public network access to the storage account. Set to false after private endpoint is deployed."
  type        = bool
  default     = true
}

variable "containers" {
  description = "List of blob container names to create. All containers are created with private access."
  type        = list(string)
  default     = []
}

variable "blob_soft_delete_days" {
  description = "Number of days to retain soft-deleted blobs and containers (1-365)"
  type        = number
  default     = 7
}

variable "tags" {
  description = "Tags to apply to the storage account"
  type        = map(string)
  default     = {}
}
