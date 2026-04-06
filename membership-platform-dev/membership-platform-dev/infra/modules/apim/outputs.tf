output "apim_name" {
  value = azurerm_api_management.apim.name
}

output "apim_id" {
  value = azurerm_api_management.apim.id
}

output "gateway_url" {
  value = azurerm_api_management.apim.gateway_url
}

output "management_api_url" {
  value = azurerm_api_management.apim.management_api_url
}


output "developer_portal_url" {
  value = azurerm_api_management.apim.developer_portal_url
}

output "principal_id" {
  description = "Principal ID of the APIM system-assigned managed identity"
  value       = azurerm_api_management.apim.identity[0].principal_id
}

output "tenant_id" {
  description = "Tenant ID of the APIM system-assigned managed identity"
  value       = azurerm_api_management.apim.identity[0].tenant_id
}
