# ===========================================================================
# TEMPLATE FILE — DO NOT USE DIRECTLY
# This file is a scaffolding template only. It is never loaded by Terraform
# at runtime from this location. Copy it into a new layer or environment
# directory (e.g. infra/envs/<env>/<layer>/versions.tf) as a starting point.
# ===========================================================================

# ---------------------------------------------------------------------------
# SHARED TERRAFORM VERSION CONSTRAINTS
# Identical across app, observability, and security layers.
# network/ does not use the random provider — its versions.tf omits that block.
# ---------------------------------------------------------------------------

terraform {
  required_version = ">= 1.6.0, < 2.0.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
  }
}
