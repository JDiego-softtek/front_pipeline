output "aca_acr_pull_id" {
  description = "Role assignment ID: ACA UAMI → ACR (AcrPull)"
  value       = azurerm_role_assignment.aca_acr_pull.id
}

output "aca_kv_secrets_user_id" {
  description = "Role assignment ID: ACA UAMI → Key Vault (Key Vault Secrets User)"
  value       = azurerm_role_assignment.aca_kv_secrets_user.id
}

output "aca_storage_blob_contributor_id" {
  description = "Role assignment ID: ACA UAMI → Storage Account (Storage Blob Data Contributor)"
  value       = azurerm_role_assignment.aca_storage_blob_contributor.id
}

output "appservice_kv_secrets_user_id" {
  description = "Role assignment ID: App Service SAMI → Key Vault (Key Vault Secrets User)"
  value       = azurerm_role_assignment.appservice_kv_secrets_user.id
}

output "adf_storage_blob_contributor_id" {
  description = "Role assignment ID: ADF SAMI → Storage Account (Storage Blob Data Contributor)"
  value       = azurerm_role_assignment.adf_storage_blob_contributor.id
}
