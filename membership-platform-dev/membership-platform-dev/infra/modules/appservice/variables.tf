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

variable "service_plan_id" {
  description = "ID of an existing shared App Service Plan. When null, a dedicated plan is created for this app service."
  type        = string
  default     = null
}

variable "service_plan_sku_name" {
  description = "SKU for the dedicated plan. Ignored when service_plan_id is set."
  type        = string
  default     = "B1"
}

variable "enable_app_insights" {
  description = "Create an Application Insights resource linked to this app service. When false, no app insights vars are injected."
  type        = bool
  default     = true
}

variable "app_settings" {
  type    = map(string)
  default = {}
}

variable "node_version" {
  type    = string
  default = "20-lts"
}

variable "frontend_subnet_id" {
  type = string
}

variable "log_analytics_workspace_id" {
  type = string
}
