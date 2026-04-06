# ---------------------------------------------------------------------------
# Env RBAC — centralized for service-to-service role assignments.
#
# Scope: managed identity role assignments only.
#   aca.tf        — ACA UAMI (id-aca-<env>)
#   appservice.tf — App Service system-assigned identity
#   adf.tf        — Azure Data Factory system-assigned identity
#
# Principal IDs and resource IDs are resolved automatically via remote state —
# no manual variable population is required.
# ---------------------------------------------------------------------------

data "azurerm_resource_group" "app_rg" {
  name = var.resource_group_name
}

# UAMIs — created in envs/<env>/identities (applies before this layer)
data "terraform_remote_state" "identities" {
  backend = "azurerm"
  config = {
    resource_group_name  = var.backend_resource_group
    storage_account_name = var.backend_storage_account
    container_name       = var.backend_container
    key                  = "${var.environment}/identities.tfstate"
  }
}

# App layer — SAMI principal IDs + resource IDs (ACR, storage, cosmos)
data "terraform_remote_state" "app" {
  backend = "azurerm"
  config = {
    resource_group_name  = var.backend_resource_group
    storage_account_name = var.backend_storage_account
    container_name       = var.backend_container
    key                  = "${var.environment}/app.tfstate"
  }
}

# Security layer — Key Vault ID
data "terraform_remote_state" "security" {
  backend = "azurerm"
  config = {
    resource_group_name  = var.backend_resource_group
    storage_account_name = var.backend_storage_account
    container_name       = var.backend_container
    key                  = "${var.environment}/security.tfstate"
  }
}
