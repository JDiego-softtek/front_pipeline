# =============================================================================
# app/backend.tf
#
# AZURERM REMOTE BACKEND CONFIGURATION
# ─────────────────────────────────────
# The backend block below intentionally contains NO inline values.
# All configuration is supplied at runtime via:
#
#   terraform init -backend-config=../backend.hcl
#
# backend.hcl (checked-in, environment-scoped) provides:
#   resource_group_name  = "rg-tfstate-dev"
#   storage_account_name = "stgtfstatedev001"
#   container_name       = "tfstate"
#
# The state key is the only value that differs per stack and is therefore
# set here explicitly:
#   key = "dev/app.tfstate"
#
# AUTHENTICATION
# ──────────────
# Authentication to the backend storage account is performed via OIDC
# (Workload Identity Federation in GitHub Actions) or via Managed Identity
# when running from an Azure VM / Cloud Shell.
# No SAS tokens or storage account keys are stored anywhere.
#
# LOCKING
# ───────
# Azure Blob Storage native leases provide state locking automatically.
# No additional DynamoDB-style lock table is required.
# =============================================================================

terraform {
  backend "azurerm" {
    key = "dev/app.tfstate"
    # All other values come from -backend-config=../backend.hcl
  }
}
