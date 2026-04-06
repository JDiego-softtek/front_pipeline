variable "resource_group_name" {
  description = "Resource group where DNS zones will be created"
  type        = string
}

variable "private_dns_zones" {
  description = "List of Private DNS zone names to create (e.g. privatelink.database.windows.net)"
  type        = list(string)
}

variable "spoke_vnet_id" {
  description = "Resource ID of the spoke VNet to link to all DNS zones"
  type        = string
}

variable "tags" {
  description = "Tags to apply to all DNS resources"
  type        = map(string)
  default     = {}
}
