# =============================================================================
# app/data.tf
#
# REMOTE STATE CONSUMPTION — PRODUCER STACK DATA SOURCES
# ───────────────────────────────────────────────────────
# This file declares all terraform_remote_state data sources consumed by the
# app stack. Each data source reads the persisted outputs of an independently
# managed producer stack from Azure Blob Storage.
#
# RULES:
#   1. Only reference keys that are declared in the producer's outputs.tf.
#   2. Never hard-code resource IDs — always derive them from remote state.
#   3. If a required producer state does not exist, Terraform will fail here
#      with a clear "blob not found" error. This is intentional (fast-fail).
#   4. All remote state references are centralised in locals.tf — do NOT
#      reference data.terraform_remote_state.* directly in resource blocks.
#
# Backend config is driven by backend.hcl (passed via terraform init
# -backend-config=../backend.hcl). The producer state keys follow the
# convention: <env>/<stack>.tfstate
# =============================================================================

# ---------------------------------------------------------------------------
# Current subscription / client context
# ---------------------------------------------------------------------------
data "azurerm_client_config" "current" {}

# ---------------------------------------------------------------------------
# Resource group — must exist before this stack runs
# ---------------------------------------------------------------------------
data "azurerm_resource_group" "rg" {
  name = var.resource_group_name
}

# ---------------------------------------------------------------------------
# Network stack — subnets, NSGs, private DNS zones
# ---------------------------------------------------------------------------
data "terraform_remote_state" "network" {
  backend = "azurerm"

  config = {
    resource_group_name  = var.backend_resource_group
    storage_account_name = var.backend_storage_account
    container_name       = var.backend_container
    key                  = "${var.environment}/network.tfstate"
  }
}

# ---------------------------------------------------------------------------
# Security stack — Key Vault URI, certificate IDs
# ---------------------------------------------------------------------------
data "terraform_remote_state" "security" {
  backend = "azurerm"

  config = {
    resource_group_name  = var.backend_resource_group
    storage_account_name = var.backend_storage_account
    container_name       = var.backend_container
    key                  = "${var.environment}/security.tfstate"
  }
}

# ---------------------------------------------------------------------------
# Identities stack — managed identity client IDs and principal IDs
# ---------------------------------------------------------------------------
data "terraform_remote_state" "identities" {
  backend = "azurerm"

  config = {
    resource_group_name  = var.backend_resource_group
    storage_account_name = var.backend_storage_account
    container_name       = var.backend_container
    key                  = "${var.environment}/identities.tfstate"
  }
}

# ---------------------------------------------------------------------------
# Observability stack — Log Analytics workspace ID, App Insights keys
# ---------------------------------------------------------------------------
data "terraform_remote_state" "observability" {
  backend = "azurerm"

  config = {
    resource_group_name  = var.backend_resource_group
    storage_account_name = var.backend_storage_account
    container_name       = var.backend_container
    key                  = "${var.environment}/observability.tfstate"
  }
}
#end