# ---------------------------------------------------------------------------
# Azure Data Factory — System-Assigned Managed Identity
#
# Identity created automatically with the ADF resource in:
# infra/modules/adf/main.tf — identity { type = "SystemAssigned" }
#
# NOTE: Item 4 (ADF → Azure SQL DB) requires T-SQL, not Azure RBAC.
#       Grant the ADF identity as an Azure AD external user on the SQL server:
#         CREATE USER [<adf-name>] FROM EXTERNAL PROVIDER;
#         ALTER ROLE db_datareader ADD MEMBER [<adf-name>];
#         ALTER ROLE db_datawriter ADD MEMBER [<adf-name>];
# ---------------------------------------------------------------------------

# [5] ADF → Storage Account: read/write AS400 flat files in the output
resource "azurerm_role_assignment" "adf_storage_blob_contributor" {
  scope                = data.terraform_remote_state.app.outputs.storage_account_id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = data.terraform_remote_state.app.outputs.adf_principal_id
}
