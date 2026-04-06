# ===========================================================================
# TEMPLATE FILE — DO NOT USE DIRECTLY
# This file is a scaffolding template only. It is never loaded by Terraform
# at runtime from this location. Copy it into a new layer or environment
# directory (e.g. infra/envs/<env>/<layer>/locals.tf) as a starting point.
# ===========================================================================

# ---------------------------------------------------------------------------
# SHARED LOCALS
# The resource_name and tags locals are identical across all layers.
# Layers with additional logic (e.g. network/effective_subnets) should extend
# this block in their own locals.tf rather than duplicating the base block.
# ---------------------------------------------------------------------------

locals {
  resource_name = "${var.project}-${var.environment}"

  tags = {
    project     = var.project
    environment = var.environment
    owner       = var.owner
    managed_by  = "terraform"
    cost_center = var.cost_center
    criticality = var.criticality
    workload    = var.workload
  }
}
