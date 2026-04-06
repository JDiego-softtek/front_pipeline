module "aca" {
  source = "../../../modules/aca"

  resource_name       = local.resource_name
  identity_id         = data.terraform_remote_state.identities.outputs.aca_identity_id
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = var.location
  tags                = local.tags

  subnet_id                  = data.terraform_remote_state.network.outputs.subnet_ids[var.aca_subnet_name]
  log_analytics_workspace_id = local.observability_log_analytics_workspace_id

  services = var.aca_services
}
