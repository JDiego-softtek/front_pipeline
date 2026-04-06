# ===========================================================================
# TEMPLATE FILE — DO NOT USE DIRECTLY
# This file is a scaffolding template only. It is never loaded by Terraform
# at runtime from this location. Copy it into a new layer or environment
# directory (e.g. infra/envs/<env>/<layer>/providers.tf) as a starting point.
# ===========================================================================

# ---------------------------------------------------------------------------
# SHARED PROVIDER CONFIGURATION
# The Azure provider configuration is identical across all layers.
# Reference this file as the source of truth for provider setup.
# ---------------------------------------------------------------------------

provider "azurerm" {
  features {}
  subscription_id                 = var.subscription_id
  resource_provider_registrations = "none"
}
