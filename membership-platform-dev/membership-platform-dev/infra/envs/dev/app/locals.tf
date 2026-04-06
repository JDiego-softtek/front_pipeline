# =============================================================================
# app/locals.tf
#
# CENTRALIZED REMOTE STATE REFERENCE MAP
# ──────────────────────��────────────────
# All references to terraform_remote_state outputs are resolved here into
# named locals. Resource files (.tf) MUST use these locals — they must NEVER
# call data.terraform_remote_state.*.outputs.* directly.
#
# Benefits:
#   • Single place to update if a producer output is renamed (deprecation).
#   • IDE-friendly: grep for local.<name> is unambiguous.
#   • Makes plan/apply diffs readable — references are aliased, not raw paths.
#   • Enables easy mocking in test environments by overriding locals only.
#
# Convention:
#   Prefix each group with the producer stack name:
#     network_*      → from data.terraform_remote_state.network
#     security_*     → from data.terraform_remote_state.security
#     identities_*   → from data.terraform_remote_state.identities
#     observability_* → from data.terraform_remote_state.observability
# =============================================================================

locals {

  # --------------------------------------------------------------------------
  # Naming / tagging
  # --------------------------------------------------------------------------
  resource_name = "${var.project}-${var.environment}"
  environment   = var.environment

  tags = {
    project     = var.project
    environment = var.environment
    owner       = var.owner
    managed_by  = "terraform"
    cost_center = var.cost_center
    criticality = var.criticality
    workload    = var.workload
  }

  # --------------------------------------------------------------------------
  # Network — virtual network, subnets, NSGs, private DNS zones
  # --------------------------------------------------------------------------
  network_vnet_id           = data.terraform_remote_state.network.outputs.vnet_id
  network_vnet_name         = data.terraform_remote_state.network.outputs.vnet_name
  network_vnet_rg           = data.terraform_remote_state.network.outputs.vnet_resource_group_name
  network_subnet_ids        = data.terraform_remote_state.network.outputs.subnet_ids
  network_nsg_ids           = data.terraform_remote_state.network.outputs.nsg_ids
  network_private_dns_zones = data.terraform_remote_state.network.outputs.private_dns_zone_ids
  network_location          = data.terraform_remote_state.network.outputs.location

  # Convenience: commonly accessed individual subnet IDs
  # Add new entries here as new subnets are defined in the network stack.
  subnet_id_aca        = local.network_subnet_ids["snet-aca-exp"]
  subnet_id_appservice = local.network_subnet_ids["snet-frontend"]
  subnet_id_data       = try(local.network_subnet_ids["snet-data"], null)

  # --------------------------------------------------------------------------
  # Security — Key Vault, certificates
  # --------------------------------------------------------------------------
  security_key_vault_id    = data.terraform_remote_state.security.outputs.key_vault_id
  security_key_vault_name  = data.terraform_remote_state.security.outputs.key_vault_name
  security_key_vault_uri   = data.terraform_remote_state.security.outputs.key_vault_uri
  security_key_vault_rg    = data.terraform_remote_state.security.outputs.key_vault_resource_group_name
  security_certificate_ids = data.terraform_remote_state.security.outputs.certificate_ids
  # NOTE: certificate_secret_ids is sensitive — reference directly from
  # data source when injecting into resource arguments that accept sensitive values.
  # Do NOT store sensitive outputs in non-sensitive locals.

  # --------------------------------------------------------------------------
  # Identities — managed identity resource IDs, client IDs, principal IDs
  # --------------------------------------------------------------------------
  identities_aca_id           = data.terraform_remote_state.identities.outputs.aca_identity_id
  identities_aca_client_id    = data.terraform_remote_state.identities.outputs.aca_identity_client_id
  identities_aca_principal_id = data.terraform_remote_state.identities.outputs.aca_identity_principal_id

  identities_appservice_id           = data.terraform_remote_state.identities.outputs.appservice_identity_id
  identities_appservice_client_id    = data.terraform_remote_state.identities.outputs.appservice_identity_client_id
  identities_appservice_principal_id = data.terraform_remote_state.identities.outputs.appservice_identity_principal_id

  identities_adf_id           = data.terraform_remote_state.identities.outputs.adf_identity_id
  identities_adf_client_id    = data.terraform_remote_state.identities.outputs.adf_identity_client_id
  identities_adf_principal_id = data.terraform_remote_state.identities.outputs.adf_identity_principal_id

  # Full map — use when iterating over identities (e.g., bulk key vault access policies)
  identities_all = data.terraform_remote_state.identities.outputs.managed_identities

  # --------------------------------------------------------------------------
  # Observability — Log Analytics, Application Insights
  # --------------------------------------------------------------------------
  observability_log_analytics_workspace_id   = data.terraform_remote_state.observability.outputs.log_analytics_workspace_id
  observability_log_analytics_workspace_name = data.terraform_remote_state.observability.outputs.log_analytics_workspace_name
  observability_log_analytics_workspace_guid = data.terraform_remote_state.observability.outputs.log_analytics_workspace_guid
  observability_diagnostic_retention_days    = data.terraform_remote_state.observability.outputs.diagnostic_retention_days
  observability_action_group_ids             = data.terraform_remote_state.observability.outputs.action_group_ids
  # NOTE: app_insights_connection_string and app_insights_instrumentation_key
  # are sensitive. Reference data.terraform_remote_state.observability.outputs.*
  # directly in resource arguments that accept sensitive values.

}
