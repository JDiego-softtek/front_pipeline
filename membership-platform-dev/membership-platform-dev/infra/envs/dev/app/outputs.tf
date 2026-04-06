output "resource_name" {
  description = "Base prefix used for resource naming"
  value       = local.resource_name
}

output "apim_name" {
  description = "APIM instance name"
  value       = module.apim.apim_name
}

output "gateway_url" {
  description = "APIM gateway URL"
  value       = module.apim.gateway_url
}

output "frontdoor_endpoint_host" {
  description = "Front Door endpoint hostname"
  value       = module.frontdoor.frontdoor_endpoint_host
}

output "frontend_hostname" {
  description = "Default hostname of the first App Service (alphabetical by key). Null when app_services is empty."
  value       = length(module.appservice) > 0 ? values(module.appservice)[0].default_hostname : null
}

output "frontend_url" {
  description = "HTTPS URL of the first App Service (alphabetical by key). Null when app_services is empty."
  value       = length(module.appservice) > 0 ? "https://${values(module.appservice)[0].default_hostname}" : null
}

output "acr_login_server" {
  description = "ACR login server hostname"
  value       = module.acr.login_server
}

output "aca_service_fqdns" {
  description = "Map of ACA service name => FQDN"
  value       = module.aca.service_fqdns
}

output "cosmos_endpoint" {
  description = "Cosmos DB document endpoint URL"
  value       = module.cosmosdb.endpoint
}

output "cosmos_database_names" {
  description = "Databases created under the Cosmos DB account"
  value       = module.cosmosdb.database_names
}

output "adf_name" {
  description = "Data Factory name"
  value       = module.adf.name
}

output "adf_principal_id" {
  description = "ADF system-assigned identity principal ID — use to grant access to SQL, Key Vault, Blob, etc."
  value       = module.adf.principal_id
}

output "storage_account_name" {
  description = "Blob storage account name"
  value       = module.storage.name
}

output "storage_primary_blob_endpoint" {
  description = "Primary blob service endpoint URL"
  value       = module.storage.primary_blob_endpoint
}

output "storage_container_names" {
  description = "Blob containers created: member-photos (photo capture) and as400-files (ADF output)"
  value       = module.storage.container_names
}

output "appservice_principal_id" {
  description = "Principal ID of the first App Service (alphabetical by key) — used for role assignments in platform/rbac. Null when app_services is empty."
  value       = length(module.appservice) > 0 ? values(module.appservice)[0].principal_id : null
}

output "appservice_hostnames" {
  description = "Map of app service key => default hostname."
  value       = { for k, v in module.appservice : k => v.default_hostname }
}

output "appservice_principal_ids" {
  description = "Map of app service key => system-assigned managed identity principal ID."
  value       = { for k, v in module.appservice : k => v.principal_id }
}

output "appservice_ids" {
  description = "Map of app service key => resource ID."
  value       = { for k, v in module.appservice : k => v.appservice_id }
}

output "acr_id" {
  description = "Resource ID of the Azure Container Registry — used as scope in platform/rbac AcrPull assignment"
  value       = module.acr.id
}

output "storage_account_id" {
  description = "Resource ID of the blob storage account — used as scope in platform/rbac storage assignments"
  value       = module.storage.id
}

output "cosmos_account_id" {
  description = "Resource ID of the Cosmos DB account — used as scope in platform/rbac Cosmos role assignment"
  value       = module.cosmosdb.id
}

output "cosmos_account_name" {
  description = "Name of the Cosmos DB account — required by azurerm_cosmosdb_sql_role_assignment in platform/rbac"
  value       = module.cosmosdb.name
}
