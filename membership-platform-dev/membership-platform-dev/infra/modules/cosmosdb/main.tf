locals {
  containers = merge([
    for db_name, db in var.databases : {
      for container_name, container in db.containers :
      "${db_name}/${container_name}" => merge(container, { database = db_name })
    }
  ]...)
}

resource "azurerm_cosmosdb_account" "this" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  offer_type          = "Standard"
  kind                = "GlobalDocumentDB"

  public_network_access_enabled = var.public_network_access_enabled

  consistency_policy {
    consistency_level       = var.consistency_level
    max_interval_in_seconds = var.consistency_level == "BoundedStaleness" ? var.max_interval_in_seconds : null
    max_staleness_prefix    = var.consistency_level == "BoundedStaleness" ? var.max_staleness_prefix : null
  }

  geo_location {
    location          = var.location
    failover_priority = 0
  }

  dynamic "capabilities" {
    for_each = var.serverless ? ["EnableServerless"] : []
    content {
      name = capabilities.value
    }
  }

  tags = var.tags
}

resource "azurerm_cosmosdb_sql_database" "this" {
  for_each = var.databases

  name                = each.key
  resource_group_name = var.resource_group_name
  account_name        = azurerm_cosmosdb_account.this.name

  throughput = var.serverless ? null : try(each.value.throughput, null)
}

resource "azurerm_cosmosdb_sql_container" "this" {
  for_each = local.containers

  name                = split("/", each.key)[1]
  resource_group_name = var.resource_group_name
  account_name        = azurerm_cosmosdb_account.this.name
  database_name       = each.value.database

  partition_key_paths   = each.value.partition_key_paths
  partition_key_version = 2

  throughput = var.serverless ? null : try(each.value.throughput, null)

  default_ttl = each.value.default_ttl

  depends_on = [azurerm_cosmosdb_sql_database.this]
}
