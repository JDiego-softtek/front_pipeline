variable "subscription_id" {
  description = "Azure subscription ID to assign policies to"
  type        = string
}

variable "allowed_locations" {
  description = "List of approved Azure regions. Deployments outside these regions will be denied."
  type        = list(string)
  default     = ["eastus", "eastus2"]
}

variable "mandatory_tags" {
  description = "List of tag keys that must be present on all indexed resources."
  type        = list(string)
  default     = ["cost_center", "owner", "environment", "criticality"]
}
