# =============================================================================
# App Service — multi-instance with optional shared plans
#
# Naming: resource_name key → "ase-{key}" (prefix enforced inside module).
# Plans:  each entry may share a plan via service_plan_key or get a dedicated one.
# Logs:   all instances send diagnostics to the shared observability workspace.
#
# =============================================================================

# Shared App Service Plans
# Add entries here when multiple app services should run on the same plan.
# Reference a shared plan from app_services via service_plan_key = "<key>".
resource "azurerm_service_plan" "shared" {
  for_each = var.app_service_shared_plans

  name                = "plan-${each.key}"
  location            = var.location
  resource_group_name = data.azurerm_resource_group.rg.name
  os_type             = "Linux"
  sku_name            = each.value.sku_name

  tags = local.tags
}

module "appservice" {
  for_each = var.app_services
  source   = "../../../modules/appservice"

  resource_name       = each.key
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = var.location
  tags                = local.tags

  # Plan: use shared plan when service_plan_key is set, otherwise create dedicated.
  service_plan_id       = each.value.service_plan_key != null ? azurerm_service_plan.shared[each.value.service_plan_key].id : null
  service_plan_sku_name = each.value.service_plan_sku

  enable_app_insights = each.value.enable_app_insights
  node_version        = each.value.node_version
  app_settings        = each.value.app_settings

  # All app services share the same Log Analytics workspace from observability stack.
  log_analytics_workspace_id = local.observability_log_analytics_workspace_id
  frontend_subnet_id         = local.subnet_id_appservice
}
