# =============================================================================
# network/lifecycle-guards.tf
#
# ACCIDENTAL-DESTRUCTION PREVENTION FOR FOUNDATIONAL RESOURCES
# ─────────────────────────────────────────────────────────────
# This file demonstrates the prevent_destroy lifecycle pattern that MUST be
# applied to all foundational (producer) resource groups and their primary
# resources (VNets, subnets, DNS zones).
#
# HOW IT WORKS
# ────────────
# Terraform will refuse to execute a plan that would destroy any resource
# annotated with `lifecycle { prevent_destroy = true }`, even if the plan
# was triggered with `terraform destroy` or by removing the resource block.
#
# WHEN TO REMOVE prevent_destroy
# ─────────────────────────────
# Removal requires a two-step process (deprecation cycle):
#   1. Submit a PR that removes prevent_destroy from the target resource.
#      PR description must include: justification, downstream impact analysis,
#      and approval from the platform lead.
#   2. After the PR is merged, run `terraform plan` in the affected stack to
#      confirm no unintended destroy operations are planned.
#   3. Only then proceed with the intentional destroy.
#
# SCOPE
# ─────
# Apply prevent_destroy to:
#   ✓ azurerm_resource_group (all foundational stacks)
#   ✓ azurerm_virtual_network
#   ✓ azurerm_subnet (production only; dev may omit)
#   ✓ azurerm_private_dns_zone
#   ✗ azurerm_network_security_rule (rules change frequently — omit)
#   ✗ azurerm_route_table_route (routes change frequently — omit)
# =============================================================================

# ---------------------------------------------------------------------------
# Resource Group — prevent accidental deletion of the network foundation
# ---------------------------------------------------------------------------
# NOTE: This block is illustrative. In the real network/main.tf, merge the
# lifecycle block directly into the azurerm_resource_group resource definition.
#
# resource "azurerm_resource_group" "network" {
#   name     = local.rg_name
#   location = var.location
#   tags     = local.common_tags
#
#   lifecycle {
#     prevent_destroy = true
#
#     # Ignore tag drift — tags are managed by Azure Policy, not Terraform.
#     ignore_changes = [tags]
#   }
# }

# ---------------------------------------------------------------------------
# Virtual Network — prevent accidental deletion
# ---------------------------------------------------------------------------
# resource "azurerm_virtual_network" "main" {
#   name                = local.vnet_name
#   location            = azurerm_resource_group.network.location
#   resource_group_name = azurerm_resource_group.network.name
#   address_space       = var.vnet_address_space
#   tags                = local.common_tags
#
#   lifecycle {
#     prevent_destroy = true
#
#     # Address space changes require coordinated planning — block drift.
#     ignore_changes = [tags]
#   }
# }

# ---------------------------------------------------------------------------
# Private DNS Zones — prevent deletion; used by private endpoints
# ---------------------------------------------------------------------------
# resource "azurerm_private_dns_zone" "zones" {
#   for_each            = toset(var.private_dns_zones)
#   name                = each.key
#   resource_group_name = azurerm_resource_group.network.name
#   tags                = local.common_tags
#
#   lifecycle {
#     prevent_destroy = true
#   }
# }

# ---------------------------------------------------------------------------
# PROVIDER-LEVEL GUARD (complementary approach)
# ─────────────────────────────────────────────
# In addition to per-resource lifecycle blocks, configure the azurerm provider
# with resource-group-scoped delete locks for extra safety in production.
#
# Use azurerm_management_lock to apply a "CanNotDelete" lock on the resource
# group itself. This works at the Azure ARM layer, independent of Terraform,
# and prevents deletion even via the Portal or CLI.
#
# Example (place in the network stack):
# ---------------------------------------------------------------------------
# resource "azurerm_management_lock" "network_rg_lock" {
#   name       = "lock-${azurerm_resource_group.network.name}"
#   scope      = azurerm_resource_group.network.id
#   lock_level = "CanNotDelete"
#   notes      = "Foundational network RG — delete requires platform lead approval."
#
#   lifecycle {
#     prevent_destroy = true
#   }
# }
