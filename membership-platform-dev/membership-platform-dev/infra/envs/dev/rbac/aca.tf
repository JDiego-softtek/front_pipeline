# ---------------------------------------------------------------------------
# ACA Services — User-Assigned Managed Identity (id-aca-<env>)
#
# Identity created in: infra/envs/<env>/identities/aca.tf
# ---------------------------------------------------------------------------

# [1] ACA → ACR: pull container images at startup and on revision deploy
resource "azurerm_role_assignment" "aca_acr_pull" {
  scope                = data.terraform_remote_state.app.outputs.acr_id
  role_definition_name = "AcrPull"
  principal_id         = data.terraform_remote_state.identities.outputs.aca_principal_id
}

# [2] ACA → Key Vault: read application secrets at runtime
resource "azurerm_role_assignment" "aca_kv_secrets_user" {
  scope                = data.terraform_remote_state.security.outputs.keyvault_id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = data.terraform_remote_state.identities.outputs.aca_principal_id
}

# [6] ACA → Storage Account: read/write member photos and blobs
resource "azurerm_role_assignment" "aca_storage_blob_contributor" {
  scope                = data.terraform_remote_state.app.outputs.storage_account_id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = data.terraform_remote_state.identities.outputs.aca_principal_id
}

# [7] ACA → Cosmos DB: read/write workflows and audit data
#     Uses the built-in "Cosmos DB Built-in Data Contributor" SQL role.
resource "azurerm_cosmosdb_sql_role_assignment" "aca_cosmos_contributor" {
  resource_group_name = var.resource_group_name
  account_name        = data.terraform_remote_state.app.outputs.cosmos_account_name
  role_definition_id  = "${data.terraform_remote_state.app.outputs.cosmos_account_id}/sqlRoleDefinitions/00000000-0000-0000-0000-000000000002"
  principal_id        = data.terraform_remote_state.identities.outputs.aca_principal_id
  scope               = data.terraform_remote_state.app.outputs.cosmos_account_id
}
