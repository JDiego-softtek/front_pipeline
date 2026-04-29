output "ids" {
  description = "Function App resource IDs by key"
  value = {
    for k, v in azurerm_linux_function_app.this :
    k => v.id
  }
}

output "names" {
  description = "Function App names by key"
  value = {
    for k, v in azurerm_linux_function_app.this :
    k => v.name
  }
}

output "principal_ids" {
  description = "Managed Identity principal IDs by Function App"
  value = {
    for k, v in azurerm_linux_function_app.this :
    k => v.identity[0].principal_id
  }
}

output "hostnames" {
  description = "Default hostnames by Function App"
  value = {
    for k, v in azurerm_linux_function_app.this :
    k => v.default_hostname
  }
}

output "service_plan_id" {
  value = azurerm_service_plan.this.id
}
