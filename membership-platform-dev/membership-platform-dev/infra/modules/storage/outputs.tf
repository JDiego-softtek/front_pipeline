output "id" {
  description = "Storage account resource ID"
  value       = azurerm_storage_account.this.id
}

output "name" {
  description = "Storage account name"
  value       = azurerm_storage_account.this.name
}

output "primary_blob_endpoint" {
  description = "Primary blob service endpoint URL"
  value       = azurerm_storage_account.this.primary_blob_endpoint
}

output "primary_access_key" {
  description = "Primary storage account access key (sensitive)"
  value       = azurerm_storage_account.this.primary_access_key
  sensitive   = true
}

output "container_names" {
  description = "List of container names created under this storage account"
  value       = keys(azurerm_storage_container.this)
}
