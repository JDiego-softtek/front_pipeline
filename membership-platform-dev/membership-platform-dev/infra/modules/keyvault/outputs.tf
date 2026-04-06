output "id" {
  description = "Key Vault resource ID"
  value       = azurerm_key_vault.this.id
}

output "name" {
  description = "Key Vault name"
  value       = azurerm_key_vault.this.name
}

output "vault_uri" {
  description = "Key Vault URI"
  value       = azurerm_key_vault.this.vault_uri
}

output "resource_group_name" {
  description = "The resource group that contains the Key Vault."
  value       = azurerm_key_vault.this.resource_group_name
}

output "tenant_id" {
  description = "The Entra ID tenant ID associated with the Key Vault."
  value       = azurerm_key_vault.this.tenant_id
}

output "location" {
  description = "The Azure region where the Key Vault is deployed."
  value       = azurerm_key_vault.this.location
}