# ---------------------------------------------------------------------------
# App Service — User-Assigned Managed Identity
#
# One UAMI for all App Service workloads in the environment.
# The identity ID is consumed by the app layer via terraform_remote_state,
# and its principal ID is consumed by the rbac layer for role assignments.
# ---------------------------------------------------------------------------

resource "azurerm_user_assigned_identity" "appservice" {
  name                = "id-appservice-${local.resource_name}"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = local.tags
}
