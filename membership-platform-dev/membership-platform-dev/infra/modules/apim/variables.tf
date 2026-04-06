variable "name" {
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

variable "subnet_apim_id" {
  type = string
}

variable "publisher_name" {
  type = string
}

variable "publisher_email" {
  type = string
}

variable "sku_name" {
  type    = string
  default = "Developer_1"
}

variable "virtual_network_type" {
  type    = string
  default = "External"
}

variable "name_suffix" {
  type        = string
  description = "Suffix to make APIM name globally unique (e.g. jorge01, ps01, 8k2)."
  default     = ""
}

variable "apis" {
  description = "Map of APIs to create in APIM"
  type = map(object({
    display_name = optional(string)
    path         = string
    backend_url  = string
    rewrite_uri  = optional(string)
    protocols    = optional(list(string), ["https"])
    operations = optional(map(object({
      method       = string
      url_template = string
      display_name = optional(string)
      responses    = optional(list(number), [200])
    })), {})
  }))
}

variable "log_analytics_workspace_id" {
  type = string
}