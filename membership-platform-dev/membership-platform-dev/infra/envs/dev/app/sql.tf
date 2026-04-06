resource "random_password" "sql_admin_password" {
  length  = 20
  special = true
}

module "sql_database" {
  source = "../../../modules/mssql"

  resource_group_name = data.azurerm_resource_group.rg.name
  location            = var.location

  key_vault_id   = data.terraform_remote_state.security.outputs.key_vault_id
  key_vault_name = data.terraform_remote_state.security.outputs.key_vault_name

  sql_server_name   = var.sql_server_name
  sql_database_name = var.sql_database_name

  admin_username = var.sql_admin_user
  admin_password = random_password.sql_admin_password.result

  min_vcores       = var.min_vcores
  max_vcores       = var.max_vcores
  auto_pause_delay = var.auto_pause_delay
  max_size_gb      = var.max_size_gb
}
