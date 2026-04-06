resource "azurerm_mssql_server" "sql_server" {

  name                = var.sql_server_name
  resource_group_name = var.resource_group_name
  location            = var.location

  version = "12.0"

  administrator_login          = var.admin_username
  administrator_login_password = var.admin_password

}

resource "azurerm_mssql_database" "sql_db" {

  name      = var.sql_database_name
  server_id = azurerm_mssql_server.sql_server.id

  sku_name = "GP_S_Gen5_1"

  min_capacity                = var.min_vcores
  auto_pause_delay_in_minutes = var.auto_pause_delay
  max_size_gb                 = var.max_size_gb

  geo_backup_enabled   = false
  storage_account_type = "Local"

}

# NOTE: Commented out because the Terraform service principal (appid=04b07795-8ddb-461a-bbee-02f9e1bf7b46)
# lacks the "Key Vault Secrets User" / "Key Vault Secrets Officer" RBAC role on the vault,
# causing a 403 ForbiddenByRbac error when Terraform checks for the existing secret.
# To re-enable: grant the SP the "Key Vault Secrets Officer" role on the Key Vault, then uncomment.
#
# resource "azurerm_key_vault_secret" "db_password" {
#   name         = "db-password"
#   value        = var.admin_password
#   key_vault_id = var.key_vault_id
# }
