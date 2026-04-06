# =============================================================================
# security/outputs.tf
#
# OUTPUT CONTRACT — ADDITIVE-ONLY POLICY
# ───────────────────────────────────────
# Rules enforced by this team:
#   1. Never remove or rename an existing output without a full deprecation cycle.
#   2. New outputs may be added freely (additive-only).
#   3. Mark secrets / sensitive values as sensitive = true.
#   4. Every output MUST have a description.
#
# Consumers of this state (app, rbac) reference these values via:
#   data.terraform_remote_state.security.outputs.<key>
# =============================================================================

# -----------------------------------------------------------------------------
# Key Vault — primary vault for application secrets
# -----------------------------------------------------------------------------
output "key_vault_id" {
  description = "The resource ID of the Key Vault used to store application secrets and certificates."
  value       = module.keyvault.id
}

output "key_vault_name" {
  description = "The name of the Key Vault. Used for constructing secret URIs and for az keyvault CLI commands."
  value       = module.keyvault.name
}

output "key_vault_uri" {
  description = <<-EOT
    The URI of the Key Vault (e.g., https://<vault-name>.vault.azure.net/).
    Consumer stacks use this URI to reference secrets and certificates by their
    full secret identifier URI in App Service / ACA environment variable bindings.
  EOT
  value       = module.keyvault.vault_uri
}

output "key_vault_resource_group_name" {
  description = "The resource group that contains the Key Vault."
  value       = module.keyvault.resource_group_name
}

output "key_vault_tenant_id" {
  description = "The Entra ID tenant ID associated with the Key Vault."
  value       = module.keyvault.tenant_id
}

# -----------------------------------------------------------------------------
# Key Vault — access / network configuration
# -----------------------------------------------------------------------------
output "key_vault_private_endpoint_id" {
  description = <<-EOT
    The resource ID of the private endpoint attached to the Key Vault.
    Null if the vault uses public access (should only occur in non-production
    environments with explicit override).
  EOT
  value       = null
}

output "key_vault_private_ip" {
  description = "The private IP address of the Key Vault private endpoint NIC."
  value       = null
}

# -----------------------------------------------------------------------------
# Certificates — pre-provisioned TLS certificates stored in Key Vault
#
# Map key = logical certificate name (stable); value = full secret/cert URI.
# Consumers (app, ingress) reference these URIs directly in App Service
# TLS bindings or ACA managed certificates.
# -----------------------------------------------------------------------------
output "certificate_ids" {
  description = <<-EOT
    Map of logical certificate name to Key Vault certificate resource ID.
    Example keys: "wildcard", "api", "internal-ca"
    Add new keys freely; never remove or rename existing keys.
  EOT
  value       = {}
}

output "certificate_secret_ids" {
  description = <<-EOT
    Map of logical certificate name to the Key Vault secret identifier (versioned URI).
    App Service / ACA reference these versioned URIs to pin a specific certificate version.
    Use the versionless URI pattern for automatic rotation (see certificate_versionless_secret_ids).
  EOT
  value       = {}
  sensitive   = true
}

output "certificate_versionless_secret_ids" {
  description = <<-EOT
    Map of logical certificate name to the Key Vault versionless secret identifier.
    Use these URIs in App Service / ACA to enable automatic certificate rotation
    without requiring infrastructure redeployment.
  EOT
  value       = {}
}

output "certificate_thumbprints" {
  description = "Map of logical certificate name to certificate thumbprint (hex, uppercase)."
  value       = {}
}

# -----------------------------------------------------------------------------
# Resource Group metadata
# -----------------------------------------------------------------------------
output "resource_group_name" {
  description = "The name of the resource group that contains the security resources."
  value       = data.azurerm_resource_group.rg.name
}

output "resource_group_id" {
  description = "The resource ID of the security resource group."
  value       = data.azurerm_resource_group.rg.id
}

output "location" {
  description = "The Azure region where the security resources are deployed."
  value       = module.keyvault.location
}
