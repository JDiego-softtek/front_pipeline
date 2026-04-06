output "log_analytics_id" {
  description = "The resource ID of the Log Analytics workspace."
  value       = azurerm_log_analytics_workspace.this.id
}

output "log_analytics_name" {
  description = "The name of the Log Analytics workspace."
  value       = azurerm_log_analytics_workspace.this.name
}

output "log_analytics_workspace_guid" {
  description = "The workspace GUID (customer ID) of the Log Analytics workspace."
  value       = azurerm_log_analytics_workspace.this.workspace_id
}

output "log_analytics_primary_shared_key" {
  description = "The primary shared key of the Log Analytics workspace."
  value       = azurerm_log_analytics_workspace.this.primary_shared_key
  sensitive   = true
}

output "log_analytics_resource_group_name" {
  description = "The resource group that contains the Log Analytics workspace."
  value       = azurerm_log_analytics_workspace.this.resource_group_name
}

output "log_analytics_retention_in_days" {
  description = "The log retention period in days configured for the workspace."
  value       = azurerm_log_analytics_workspace.this.retention_in_days
}

output "location" {
  description = "The Azure region where the observability resources are deployed."
  value       = azurerm_log_analytics_workspace.this.location
}

output "workbook_id" {
  description = "The resource ID of the SRE workbook."
  value       = azurerm_application_insights_workbook.sre_dashboard.id
}

output "workbook_display_name" {
  description = "The display name of the SRE workbook."
  value       = azurerm_application_insights_workbook.sre_dashboard.display_name
}