module "apim" {
  source = "../../../modules/apim"

  name                = local.resource_name
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = var.location

  publisher_name  = var.apim_publisher_name
  publisher_email = var.apim_publisher_email

  log_analytics_workspace_id = local.observability_log_analytics_workspace_id
  subnet_apim_id             = data.terraform_remote_state.network.outputs.subnet_ids[var.apim_subnet_name]


  tags = local.tags

  apis = {
    for api_name, api_cfg in var.apim_apis :
    api_name => {
      display_name = api_cfg.display_name
      path         = api_cfg.path
      backend_url  = "https://${module.aca.service_fqdns[api_cfg.backend_service]}"

      operations = {
        health = {
          method       = "GET"
          url_template = "/"
          responses    = [200]
        }
      }
    }
  }

}

module "frontdoor" {
  source = "../../../modules/frontdoor"

  resource_name       = local.resource_name
  resource_group_name = data.azurerm_resource_group.rg.name

  log_analytics_workspace_id = local.observability_log_analytics_workspace_id

  frontend_host_name     = module.aca.service_fqdns["membership"]
  apim_gateway_host_name = trimsuffix(replace(module.apim.gateway_url, "https://", ""), "/")
  appservice_host_name   = length(module.appservice) > 0 ? values(module.appservice)[0].default_hostname : null
  enable_appservice      = length(var.app_services) > 0

  tags = local.tags
}
