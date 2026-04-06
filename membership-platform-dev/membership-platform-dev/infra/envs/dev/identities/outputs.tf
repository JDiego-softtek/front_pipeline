# =============================================================================
# identities/outputs.tf
#
# OUTPUT CONTRACT — ADDITIVE-ONLY POLICY
# ───────────────────────────────────────
# Rules enforced by this team:
#   1. Never remove or rename an existing output without a full deprecation cycle.
#   2. New outputs may be added freely (additive-only).
#   3. Mark secrets / access tokens as sensitive = true.
#   4. Every output MUST have a description.
#
# Consumers of this state (app, rbac) reference these values via:
#   data.terraform_remote_state.identities.outputs.<key>
# =============================================================================

# -----------------------------------------------------------------------------
# ACA (Azure Container Apps) Managed Identity
# -----------------------------------------------------------------------------
output "aca_identity_id" {
  description = "The resource ID of the User-Assigned Managed Identity used by ACA workloads."
  value       = azurerm_user_assigned_identity.aca.id
}

output "aca_identity_client_id" {
  description = <<-EOT
    The client (application) ID of the ACA managed identity.
    Use this value when configuring workload identity federation or
    azure.clientId annotations on Kubernetes/ACA pods.
  EOT
  value       = azurerm_user_assigned_identity.aca.client_id
}

output "aca_identity_principal_id" {
  description = <<-EOT
    The object (principal) ID of the ACA managed identity in Entra ID.
    Use this value when assigning Azure RBAC roles to the identity.
  EOT
  value       = azurerm_user_assigned_identity.aca.principal_id
}

output "aca_identity_tenant_id" {
  description = "The Entra ID tenant ID associated with the ACA managed identity."
  value       = azurerm_user_assigned_identity.aca.tenant_id
}

# -----------------------------------------------------------------------------
# App Service Managed Identity
# -----------------------------------------------------------------------------
output "appservice_identity_id" {
  description = "The resource ID of the User-Assigned Managed Identity used by App Service workloads."
  value       = azurerm_user_assigned_identity.appservice.id
}

output "appservice_identity_client_id" {
  description = "The client (application) ID of the App Service managed identity."
  value       = azurerm_user_assigned_identity.appservice.client_id
}

output "appservice_identity_principal_id" {
  description = "The object (principal) ID of the App Service managed identity in Entra ID."
  value       = azurerm_user_assigned_identity.appservice.principal_id
}

# -----------------------------------------------------------------------------
# ADF (Azure Data Factory) Managed Identity
# -----------------------------------------------------------------------------
output "adf_identity_id" {
  description = "The resource ID of the User-Assigned Managed Identity used by ADF pipelines."
  value       = azurerm_user_assigned_identity.adf.id
}

output "adf_identity_client_id" {
  description = "The client (application) ID of the ADF managed identity."
  value       = azurerm_user_assigned_identity.adf.client_id
}

output "adf_identity_principal_id" {
  description = "The object (principal) ID of the ADF managed identity in Entra ID."
  value       = azurerm_user_assigned_identity.adf.principal_id
}

# -----------------------------------------------------------------------------
# Convenience: full map of all managed identities
#
# Provides a single structured output for consumers that need to iterate
# over all identities (e.g., for bulk RBAC assignments in the rbac stack).
#
# Schema per entry:
#   {
#     id           = string  # full ARM resource ID
#     client_id    = string  # application/client ID
#     principal_id = string  # Entra ID object ID
#     tenant_id    = string  # Entra ID tenant ID
#   }
# -----------------------------------------------------------------------------
output "managed_identities" {
  description = <<-EOT
    Map of logical workload name to managed identity attributes.
    Stable keys: "aca", "appservice", "adf".
    Add new keys freely; never remove or rename existing keys.
  EOT
  value = {
    aca = {
      id           = azurerm_user_assigned_identity.aca.id
      client_id    = azurerm_user_assigned_identity.aca.client_id
      principal_id = azurerm_user_assigned_identity.aca.principal_id
      tenant_id    = azurerm_user_assigned_identity.aca.tenant_id
    }
    appservice = {
      id           = azurerm_user_assigned_identity.appservice.id
      client_id    = azurerm_user_assigned_identity.appservice.client_id
      principal_id = azurerm_user_assigned_identity.appservice.principal_id
      tenant_id    = azurerm_user_assigned_identity.appservice.tenant_id
    }
    adf = {
      id           = azurerm_user_assigned_identity.adf.id
      client_id    = azurerm_user_assigned_identity.adf.client_id
      principal_id = azurerm_user_assigned_identity.adf.principal_id
      tenant_id    = azurerm_user_assigned_identity.adf.tenant_id
    }
  }
}

# -----------------------------------------------------------------------------
# Resource Group metadata
# -----------------------------------------------------------------------------
output "resource_group_name" {
  description = "The name of the resource group that contains the managed identities."
  value       = data.azurerm_resource_group.rg.name
}

output "resource_group_id" {
  description = "The resource ID of the identities resource group."
  value       = data.azurerm_resource_group.rg.id
}

output "location" {
  description = "The Azure region where the managed identities are deployed."
  value       = data.azurerm_resource_group.rg.location
}
