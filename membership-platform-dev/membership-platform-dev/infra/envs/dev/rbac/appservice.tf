# ---------------------------------------------------------------------------
# App Service (Frontend) — System-Assigned Managed Identity
#
# Identity created automatically with the App Service resource in:
# infra/modules/appservice/main.tf — identity { type = "SystemAssigned" }
# Reference: infra/docs/MANAGED_IDENTITIES.md — item 3
# ---------------------------------------------------------------------------

# [3] App Service → Key Vault: read frontend environment secrets at runtime
resource "azurerm_role_assignment" "appservice_kv_secrets_user" {
  scope                = data.terraform_remote_state.security.outputs.keyvault_id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = data.terraform_remote_state.app.outputs.appservice_principal_id
}
