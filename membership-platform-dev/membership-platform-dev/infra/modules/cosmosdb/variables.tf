variable "name" {
  description = "Cosmos DB account name (globally unique)"
  type        = string
}

variable "resource_group_name" {
  description = "Resource group where the Cosmos DB account will be created"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "consistency_level" {
  description = "Default consistency level for the account"
  type        = string
  default     = "Session"

  validation {
    condition     = contains(["Eventual", "Session", "BoundedStaleness", "Strong", "ConsistentPrefix"], var.consistency_level)
    error_message = "consistency_level must be one of: Eventual, Session, BoundedStaleness, Strong, ConsistentPrefix."
  }
}

variable "max_interval_in_seconds" {
  description = "BoundedStaleness only: max lag in seconds (5–86400)"
  type        = number
  default     = 5
}

variable "max_staleness_prefix" {
  description = "BoundedStaleness only: max number of stale requests tolerated (10–2147483647)"
  type        = number
  default     = 100
}

variable "serverless" {
  description = "Enable Cosmos DB serverless mode. Cannot be combined with geo-redundancy or throughput settings."
  type        = bool
  default     = false
}
/*
variable "geo_redundancy_enabled" {
  description = "Enable geo-redundancy (ignored when serverless = true)"
  type        = bool
  default     = false
}

variable "enable_automatic_failover" {
  description = "Enable automatic failover for multi-region accounts (ignored when serverless = true)"
  type        = bool
  default     = false
}
*/
variable "public_network_access_enabled" {
  description = "Allow public network access. Set to false after private endpoint is deployed."
  type        = bool
  default     = true
}

variable "databases" {
  description = "Map of SQL (NoSQL) databases and their containers to create under the account."
  type = map(object({
    throughput = optional(number)

    containers = map(object({
      partition_key_paths = list(string)
      throughput          = optional(number)
      default_ttl         = optional(number, -1)
    }))
  }))
  default = {}
}

variable "tags" {
  description = "Tags to apply to all Cosmos DB resources"
  type        = map(string)
  default     = {}
}
