output "id" {
  description = "Data Factory resource ID"
  value       = azurerm_data_factory.this.id
}

output "name" {
  description = "Data Factory name"
  value       = azurerm_data_factory.this.name
}

output "principal_id" {
  description = "Object ID of the system-assigned managed identity. Use this to grant ADF access to SQL, Key Vault, Blob, etc."
  value       = azurerm_data_factory.this.identity[0].principal_id
}
