variable "resource_name" {
  type = string
}
variable "location" {
  type = string
}
variable "resource_group_name" {
  type = string
}

variable "tags" {
  type = map(string)
}

variable "identity_id" {
  description = "Resource ID of the user-assigned managed identity to attach to all container apps. Created in platform/identities."
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID delegated to Microsoft.App/environments"
  type        = string
}

variable "log_analytics_workspace_id" {
  description = "Existing Log Analytics Workspace ID"
  type        = string
}

variable "services" {
  description = "Container Apps to deploy. Key = app name."
  type = map(object({
    image_name = string
    image_tag  = string
    cpu        = number
    memory     = string

    ingress = object({
      external_enabled = bool
      target_port      = number
      transport        = optional(string, "auto")
    })

    env = optional(map(string), {})
  }))
}
