resource "azurerm_container_app_environment" "this" {
  name                       = "cae-${var.resource_name}"
  location                   = var.location
  resource_group_name        = var.resource_group_name
  log_analytics_workspace_id = var.log_analytics_workspace_id

  infrastructure_subnet_id = var.subnet_id

  tags = var.tags

  lifecycle {
    ignore_changes = [infrastructure_resource_group_name]
  }
}

resource "azurerm_container_app" "this" {
  for_each                     = var.services
  name                         = "ca-${each.key}-${var.resource_name}"
  resource_group_name          = var.resource_group_name
  container_app_environment_id = azurerm_container_app_environment.this.id
  revision_mode                = "Single"
  tags                         = var.tags

  identity {
    type         = "UserAssigned"
    identity_ids = [var.identity_id]
  }

  template {
    min_replicas = 0
    max_replicas = 1

    container {
      name   = each.key
      image  = "${each.value.image_name}:${each.value.image_tag}"
      cpu    = each.value.cpu
      memory = each.value.memory

      dynamic "env" {
        for_each = each.value.env
        content {
          name  = env.key
          value = env.value
        }
      }
    }
  }

  ingress {
    external_enabled = each.value.ingress.external_enabled
    target_port      = each.value.ingress.target_port
    transport        = each.value.ingress.transport

    traffic_weight {
      latest_revision = true
      percentage      = 100
    }
  }
}
