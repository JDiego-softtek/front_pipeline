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
