variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "sql_server_name" {
  type = string
}

variable "sql_database_name" {
  type = string
}

variable "admin_username" {
  type = string
}

variable "admin_password" {
  type      = string
  sensitive = true
}

variable "min_vcores" {
  type = number
}

variable "max_vcores" {
  type = number
}

variable "auto_pause_delay" {
  type = number
}

variable "max_size_gb" {
  type = number
}

variable "key_vault_id" {
  type        = string
  description = "ID del Key Vault donde se guardarán secretos"
}

variable "key_vault_name" {
  type        = string
  description = "Nombre del Key Vault"
}