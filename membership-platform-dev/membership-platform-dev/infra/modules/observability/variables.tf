variable "resource_name" {
  description = "Prefix used for observability resource names"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "resource_group_name" {
  description = "Resource group name"
  type        = string
}

variable "tags" {
  description = "Tags applied to observability resources"
  type        = map(string)
  default     = {}
}

variable "workbook_template_path" {
  description = "Path to the workbook JSON template"
  type        = string
}