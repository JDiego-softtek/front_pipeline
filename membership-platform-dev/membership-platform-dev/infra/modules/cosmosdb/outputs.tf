output "id" {
  description = "Cosmos DB account resource ID"
  value       = azurerm_cosmosdb_account.this.id
}

output "name" {
  description = "Cosmos DB account name"
  value       = azurerm_cosmosdb_account.this.name
}

output "endpoint" {
  description = "Cosmos DB document endpoint URL"
  value       = azurerm_cosmosdb_account.this.endpoint
}

output "primary_key" {
  description = "Cosmos DB primary master key (sensitive)"
  value       = azurerm_cosmosdb_account.this.primary_key
  sensitive   = true
}

output "primary_readonly_key" {
  description = "Cosmos DB primary read-only key (sensitive)"
  value       = azurerm_cosmosdb_account.this.primary_readonly_key
  sensitive   = true
}

output "database_names" {
  description = "List of database names created under this account"
  value       = keys(azurerm_cosmosdb_sql_database.this)
}
