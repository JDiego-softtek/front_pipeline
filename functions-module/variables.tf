variable "name" {
  type        = string
  description = "Name of the Azure Linux Function App."
}

variable "location" {
  type        = string
  description = "Azure region where the function app is deployed."
}

variable "resource_group_name" {
  type        = string
  description = "Name of the resource group that contains the function app."
}

#variable "service_plan_id" {
#  type        = string
#  description = "Resource ID of the App Service Plan used to host the function app."
#}

#variable "storage_account_name" {
#  type        = string
#  description = "Name of the storage account used by the Functions host and Durable Functions task hub."
#}

#variable "storage_account_id" {
#  type        = string
#  description = "Resource ID of the storage account (used as scope for RBAC role assignments)."
#}

variable "node_version" {
  type        = string
  description = "Node.js version for the function app application stack."
  default     = "22"
}

variable "functions_worker_runtime" {
  type        = string
  description = "Azure Functions worker runtime (e.g. node, dotnet, python)."
  default     = "node"
}

variable "website_run_from_package" {
  type        = string
  description = "Controls the WEBSITE_RUN_FROM_PACKAGE app setting. '1' means run from a package URL or zip deploy."
  default     = "1"
}

variable "functions_extension_version" {
  type        = string
  description = "Azure Functions runtime major version pin (e.g. '~4'). Defaults to '~4' (v4 LTS)."
  default     = "~4"
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to all resources in this module."
  default     = {}
}

#variable "vnet_integration_subnet_id" {
#  type = string
#}

#variable "function_name" {
#  type = string
#}

variable "functions" {
  description = "Map of Function Apps to create."
  type = map(object({
    function_app_name                      = optional(string)
    storage_account_name                   = string
    storage_account_id                     = string
    service_plan_id                        = string
    identity_type                          = optional(string, "SystemAssigned")
    app_settings                           = optional(map(string), {})
    functions_worker_runtime               = optional(string, "node")
    runtime_version                        = optional(string, "22")
    functions_extension_version            = optional(string, "~4")
    https_only                             = optional(bool, true)
    service_plan_sku_name                  = optional(string, "Y1")
  }))
}
