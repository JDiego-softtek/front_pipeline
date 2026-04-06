# =============================================================================
# network/outputs.tf
#
# OUTPUT CONTRACT — ADDITIVE-ONLY POLICY
# ───────────────────────────────────────
# Rules enforced by this team:
#   1. Never remove or rename an existing output without a full deprecation cycle.
#   2. New outputs may be added freely (additive-only).
#   3. Mark secrets as sensitive = true.
#   4. Every output MUST have a description.
#
# Consumers of this state (app, rbac) reference these values via:
#   data.terraform_remote_state.network.outputs.<key>
# =============================================================================

# -----------------------------------------------------------------------------
# Virtual Network
# -----------------------------------------------------------------------------
output "vnet_id" {
  description = "The resource ID of the virtual network."
  value       = module.networking.vnet_id
}

output "vnet_name" {
  description = "The name of the virtual network."
  value       = module.networking.vnet_name
}

output "vnet_address_space" {
  description = "The address space(s) of the virtual network."
  value       = module.networking.vnet_address_space
}

output "vnet_resource_group_name" {
  description = "The resource group that contains the virtual network."
  value       = module.networking.vnet_resource_group_name
}

# -----------------------------------------------------------------------------
# Subnets — map of logical name → subnet resource ID
#
# Convention: keys must remain stable; add new keys freely.
# Example keys: "app", "aca", "data", "management"
# -----------------------------------------------------------------------------
output "subnet_ids" {
  description = <<-EOT
    Map of logical subnet name to subnet resource ID.
    Keys are stable identifiers used by consumer stacks to select the correct
    subnet without hard-coding resource IDs.
    Example: subnet_ids["aca"] → "/subscriptions/.../subnets/snet-aca-dev"
  EOT
  value       = module.networking.subnet_ids
}

output "subnet_address_prefixes" {
  description = "Map of logical subnet name to its CIDR address prefix."
  value       = module.networking.subnet_address_prefixes
}

# -----------------------------------------------------------------------------
# Network Security Groups — map of logical name → NSG resource ID
# -----------------------------------------------------------------------------
output "nsg_ids" {
  description = <<-EOT
    Map of logical NSG name to NSG resource ID.
    Keys align with subnet keys where a dedicated NSG is attached.
    Example: nsg_ids["aca"] → "/subscriptions/.../networkSecurityGroups/nsg-aca-dev"
  EOT
  value       = module.networking.nsg_ids
}

output "nsg_names" {
  description = "Map of logical NSG name to NSG resource name."
  value       = module.networking.nsg_names
}

# -----------------------------------------------------------------------------
# Private DNS Zones — map of zone name → zone resource ID
# Used by consumer stacks to register private endpoints.
# -----------------------------------------------------------------------------
output "private_dns_zone_ids" {
  description = <<-EOT
    Map of DNS zone FQDN to private DNS zone resource ID.
    Example keys: "privatelink.azurewebsites.net",
                  "privatelink.database.windows.net",
                  "privatelink.vaultcore.azure.net"
  EOT
  value       = length(module.dns) > 0 ? module.dns[0].zone_ids : {}
}

output "private_dns_zone_names" {
  description = "List of all private DNS zone FQDNs managed by this stack."
  value       = length(module.dns) > 0 ? values(module.dns[0].zone_names) : []
}

# -----------------------------------------------------------------------------
# Location / Region metadata (convenience outputs)
# -----------------------------------------------------------------------------
output "location" {
  description = "The Azure region where network resources are deployed."
  value       = module.networking.location
}

output "resource_group_id" {
  description = "The resource ID of the network resource group."
  value       = data.azurerm_resource_group.rg.id
}
