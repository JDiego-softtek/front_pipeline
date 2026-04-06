variable "resource_name" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "tags" {
  type = map(string)
}

variable "frontend_host_name" {
  type = string
}

variable "apim_gateway_host_name" {
  type = string
}

variable "appservice_host_name" {
  type     = string
  default  = null
  nullable = true
}

variable "enable_appservice" {
  type        = bool
  default     = false
  description = "Whether to create the App Service origin, route, and rewrite rule set in Front Door."
}

variable "log_analytics_workspace_id" {
  type = string
}
