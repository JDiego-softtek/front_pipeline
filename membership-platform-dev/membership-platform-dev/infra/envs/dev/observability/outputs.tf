# =============================================================================
# observability/outputs.tf
#
# OUTPUT CONTRACT — ADDITIVE-ONLY POLICY
# ───────────────────────────────────────
# Rules enforced by this team:
#   1. Never remove or rename an existing output without a full deprecation cycle.
#   2. New outputs may be added freely (additive-only).
#   3. Mark secrets / instrumentation keys as sensitive = true.
#   4. Every output MUST have a description.
#
# Consumers of this state (app, rbac) reference these values via:
#   data.terraform_remote_state.observability.outputs.<key>
# =============================================================================

# -----------------------------------------------------------------------------
# Log Analytics Workspace
# -----------------------------------------------------------------------------
output "log_analytics_workspace_id" {
  description = "The resource ID of the Log Analytics workspace. Used by consumer stacks to associate diagnostic settings."
  value       = module.observability.log_analytics_id
}

output "log_analytics_workspace_name" {
  description = "The name of the Log Analytics workspace."
  value       = module.observability.log_analytics_name
}

output "log_analytics_workspace_guid" {
  description = <<-EOT
    The workspace GUID (customer ID) of the Log Analytics workspace.
    Required when configuring the OMS agent or direct data ingestion via
    the Log Analytics Data Collector API.
  EOT
  value       = module.observability.log_analytics_workspace_guid
}

output "log_analytics_primary_shared_key" {
  description = <<-EOT
    The primary shared key of the Log Analytics workspace.
    Required for agent-based log collection. Treat as a secret.
    Prefer Managed Identity authentication where possible.
  EOT
  value       = module.observability.log_analytics_primary_shared_key
  sensitive   = true
}

output "log_analytics_resource_group_name" {
  description = "The resource group that contains the Log Analytics workspace."
  value       = module.observability.log_analytics_resource_group_name
}

# -----------------------------------------------------------------------------
# Application Insights
# (not yet provisioned in this environment — outputs return null)
# -----------------------------------------------------------------------------
output "app_insights_id" {
  description = "The resource ID of the Application Insights component."
  value       = null
}

output "app_insights_name" {
  description = "The name of the Application Insights component."
  value       = null
}

output "app_insights_instrumentation_key" {
  description = <<-EOT
    The instrumentation key for the Application Insights component.
    Inject this value as the APPINSIGHTS_INSTRUMENTATIONKEY environment variable
    in App Service and ACA workloads.
    NOTE: For new workloads prefer connection_string (see app_insights_connection_string).
  EOT
  value       = null
  sensitive   = true
}

output "app_insights_connection_string" {
  description = <<-EOT
    The connection string for the Application Insights component.
    Inject this value as the APPLICATIONINSIGHTS_CONNECTION_STRING environment variable
    in App Service and ACA workloads. Preferred over instrumentation_key for new workloads
    as it supports regional ingestion endpoints and does not require a separate key.
  EOT
  value       = null
  sensitive   = true
}

output "app_insights_app_id" {
  description = "The App ID (application ID) of the Application Insights component. Used for cross-resource queries in Log Analytics."
  value       = null
}

# -----------------------------------------------------------------------------
# Diagnostic settings helper — pre-built retention policy object
# -----------------------------------------------------------------------------
output "diagnostic_retention_days" {
  description = "The standard log retention period in days enforced for this environment. Reference this in diagnostic setting resources."
  value       = module.observability.log_analytics_retention_in_days
}

# -----------------------------------------------------------------------------
# Action Groups
# (not yet provisioned in this environment — output returns empty map)
# -----------------------------------------------------------------------------
output "action_group_ids" {
  description = <<-EOT
    Map of logical action group name to action group resource ID.
    Consumer stacks reference these IDs in azurerm_monitor_metric_alert.action blocks.
    Example keys: "critical", "warning", "info"
    Add new keys freely; never remove or rename existing keys.
  EOT
  value       = {}
}

# -----------------------------------------------------------------------------
# Resource Group metadata
# -----------------------------------------------------------------------------
output "resource_group_name" {
  description = "The name of the resource group that contains the observability resources."
  value       = data.azurerm_resource_group.rg.name
}

output "resource_group_id" {
  description = "The resource ID of the observability resource group."
  value       = data.azurerm_resource_group.rg.id
}

output "location" {
  description = "The Azure region where the observability resources are deployed."
  value       = module.observability.location
}
