output "frontend_name" {
  value = azurerm_linux_web_app.this.name
}

output "default_hostname" {
  value = azurerm_linux_web_app.this.default_hostname
}

output "service_plan_id" {
  description = "ID of the App Service Plan used (dedicated or shared)."
  value       = local.resolved_plan_id
}

output "application_insights_name" {
  description = "Application Insights resource name. Null when enable_app_insights = false."
  value       = var.enable_app_insights ? azurerm_application_insights.this[0].name : null
}

output "application_insights_connection_string" {
  description = "Application Insights connection string. Null when enable_app_insights = false."
  value       = var.enable_app_insights ? azurerm_application_insights.this[0].connection_string : null
  sensitive   = true
}

output "appservice_id" {
  value = azurerm_linux_web_app.this.id
}

output "principal_id" {
  description = "Object ID of the system-assigned managed identity. Use this to grant App Service access to Key Vault, etc."
  value       = azurerm_linux_web_app.this.identity[0].principal_id
}
