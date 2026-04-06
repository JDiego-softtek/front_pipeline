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


  effective_subnets = var.enable_private_endpoints ? var.subnets : {
    for k, v in var.subnets : k => v if k != "snet-data"
  }
}
