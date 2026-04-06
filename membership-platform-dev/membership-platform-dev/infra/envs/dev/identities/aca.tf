# ---------------------------------------------------------------------------
# ACA Services — User-Assigned Managed Identity
#
# One UAMI shared across all Container Apps in the environment.
# The identity ID is consumed by the app layer (infra/envs/<env>/app/aca.tf)
# via terraform_remote_state, and its principal ID is consumed by
# infra/envs/<env>/rbac/aca.tf for role assignments.
#
# To add a new UAMI for a different resource, create a new .tf file in this
# directory following the same pattern and add its outputs below.
# ---------------------------------------------------------------------------

resource "azurerm_user_assigned_identity" "aca" {
  name                = "id-aca-${local.resource_name}"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = local.tags
}
