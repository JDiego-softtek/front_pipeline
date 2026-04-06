data "azurerm_resource_group" "rg" {
  name = var.resource_group_name
}

module "observability" {
  source = "../../../modules/observability"

  resource_name       = local.resource_name
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = var.location
  tags                = local.tags

  workbook_template_path = "${path.root}/../../../dashboards/dev/azure/workbook.json.tpl"
}
