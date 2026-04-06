variable "name" {
  description = "Azure Data Factory name (globally unique)"
  type        = string
}

variable "resource_group_name" {
  description = "Resource group where the Data Factory will be created"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "public_network_access_enabled" {
  description = "Allow public network access to ADF. Keep false when Managed VNet is enabled — all connectivity is through managed private endpoints."
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags to apply to the Data Factory"
  type        = map(string)
  default     = {}
}
