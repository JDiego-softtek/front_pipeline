output "database_id" {

  value = azurerm_mssql_database.sql_db.id

}

output "server_name" {

  value = azurerm_mssql_server.sql_server.name

}