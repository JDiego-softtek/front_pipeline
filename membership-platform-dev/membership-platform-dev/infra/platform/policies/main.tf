data "azurerm_subscription" "current" {}

resource "azurerm_policy_definition" "require_tags" {
  name         = "mot-require-mandatory-tags"
  policy_type  = "Custom"
  mode         = "Indexed"
  display_name = "MOT - Require mandatory tags on all resources"

  metadata = jsonencode({
    category = "Tags"
    version  = "1.0.0"
  })

  policy_rule = jsonencode({
    if = {
      anyOf = [
        for tag in var.mandatory_tags : {
          field  = "tags['${tag}']"
          exists = "false"
        }
      ]
    }
    then = {
      effect = "Audit"
    }
  })
}

resource "azurerm_subscription_policy_assignment" "require_tags" {
  name                 = "mot-require-tags"
  display_name         = "MOT - Require mandatory tags"
  subscription_id      = data.azurerm_subscription.current.id
  policy_definition_id = azurerm_policy_definition.require_tags.id
  description          = "Audits resources missing mandatory tags: ${join(", ", var.mandatory_tags)}"
}

resource "azurerm_subscription_policy_assignment" "allowed_locations" {
  name                 = "mot-allowed-locations"
  display_name         = "MOT - Allowed Azure locations"
  subscription_id      = data.azurerm_subscription.current.id
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/e56962a6-4747-49cd-b67b-bf8b01975c4f"
  description          = "Denies deployments outside approved regions: ${join(", ", var.allowed_locations)}"

  parameters = jsonencode({
    listOfAllowedLocations = {
      value = var.allowed_locations
    }
  })
}

resource "azurerm_policy_definition" "sql_tls_min_version" {
  name         = "mot-sql-tls-min-version"
  policy_type  = "Custom"
  mode         = "Indexed"
  display_name = "MOT - SQL Server must enforce TLS 1.2 minimum"

  metadata = jsonencode({
    category = "SQL"
    version  = "1.0.0"
  })

  policy_rule = jsonencode({
    if = {
      allOf = [
        {
          field  = "type"
          equals = "Microsoft.Sql/servers"
        },
        {
          field = "Microsoft.Sql/servers/minimalTlsVersion"
          notIn = ["1.2"]
        }
      ]
    }
    then = {
      effect = "Audit"
    }
  })
}

resource "azurerm_subscription_policy_assignment" "sql_tls_min_version" {
  name                 = "mot-sql-tls"
  display_name         = "MOT - SQL Server TLS 1.2 minimum"
  subscription_id      = data.azurerm_subscription.current.id
  policy_definition_id = azurerm_policy_definition.sql_tls_min_version.id
  description          = "Audits SQL Servers not configured with minimalTlsVersion = 1.2"
}
