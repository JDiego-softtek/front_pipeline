variable "subscription_id" {
  description = "Azure subscription ID"
  type        = string
}

variable "project" {
  description = "Project short name"
  type        = string
}

variable "environment" {
  description = "Environment name (dev / qa / prod)"
  type        = string
}

variable "resource_group_name" {
  description = "Existing resource group name"
  type        = string
}

variable "location" {
  description = "Azure region for all resources"
  type        = string
}

variable "owner" {
  description = "Team or person responsible for this layer"
  type        = string
}

variable "cost_center" {
  description = "Cost center code for billing attribution"
  type        = string
}

variable "criticality" {
  description = "Workload criticality level"
  type        = string
  validation {
    condition     = contains(["low", "medium", "high", "critical"], var.criticality)
    error_message = "criticality must be one of: low, medium, high, critical."
  }
}

variable "workload" {
  description = "Workload or application name"
  type        = string
}

variable "backend_resource_group" {
  description = "Resource group containing the Terraform state storage account"
  type        = string
}

variable "backend_storage_account" {
  description = "Storage account name for Terraform remote state"
  type        = string
}

variable "backend_container" {
  description = "Blob container name for Terraform remote state"
  type        = string
  default     = "tfstate"
}

variable "acr_sku" {
  description = "Azure Container Registry SKU (Basic / Standard / Premium)"
  type        = string
  default     = "Basic"
}

variable "acr_admin_enabled" {
  description = "Enable admin user for ACR. Keep false; use managed identities instead."
  type        = bool
  default     = false
}

variable "acr_public_access_enabled" {
  description = "Allow public network access to ACR. Disable in QA/Prod with private endpoint."
  type        = bool
  default     = true
}

variable "aca_services" {
  description = "Container Apps to deploy. Key = app name."
  type = map(object({
    image_name = string
    image_tag  = string
    cpu        = number
    memory     = string
    ingress = object({
      external_enabled = bool
      target_port      = number
      transport        = optional(string, "auto")
    })
    env = optional(map(string), {})
  }))
}

variable "aca_subnet_name" {
  description = "Subnet name to host the ACA Environment"
  type        = string
  default     = "snet-aca-exp"
}


variable "apim_subnet_name" {
  description = "Subnet name to host APIM"
  type        = string
  default     = "snet-apim"
}

variable "apim_publisher_name" {
  description = "APIM publisher display name"
  type        = string
}

variable "apim_publisher_email" {
  description = "APIM publisher contact email address"
  type        = string
}

variable "sql_server_name" {
  description = "SQL Server name"
  type        = string
}

variable "sql_database_name" {
  description = "SQL Database name"
  type        = string
}

variable "sql_admin_user" {
  description = "SQL Server administrator username"
  type        = string
}

variable "min_vcores" {
  description = "Minimum vCores for serverless SQL auto-scaling"
  type        = number
}

variable "max_vcores" {
  description = "Maximum vCores for serverless SQL auto-scaling"
  type        = number
}

variable "auto_pause_delay" {
  description = "Auto-pause delay in minutes. Use -1 to disable (recommended for QA/Prod)."
  type        = number
}

variable "max_size_gb" {
  description = "Maximum database size in GB"
  type        = number
}

variable "apim_apis" {
  description = "APIs exposed by APIM and mapped to ACA backends"
  type = map(object({
    display_name    = string
    path            = string
    backend_service = string
  }))
}

# --- Cosmos DB ---

variable "cosmos_account_name" {
  description = "Cosmos DB account name (globally unique)"
  type        = string
}

variable "cosmos_serverless" {
  description = "Enable Cosmos DB serverless mode. Recommended for dev. Cannot be combined with geo-redundancy."
  type        = bool
  default     = true
}

variable "cosmos_consistency_level" {
  description = "Cosmos DB default consistency level"
  type        = string
  default     = "Session"
}

variable "cosmos_public_network_access_enabled" {
  description = "Allow public access to Cosmos DB. Set to false after private endpoint is deployed."
  type        = bool
  default     = true
}

variable "cosmos_databases" {
  description = "Databases and containers to create under the Cosmos DB account."
  type = map(object({
    throughput = optional(number)
    containers = map(object({
      partition_key_paths = list(string)
      throughput          = optional(number)
      default_ttl         = optional(number, -1)
    }))
  }))
  default = {}
}

# --- Blob Storage ---

variable "storage_replication_type" {
  description = "Storage replication type. LRS for dev, ZRS or GRS for prod."
  type        = string
  default     = "LRS"
}

variable "storage_public_network_access_enabled" {
  description = "Allow public access to the storage account. Set to false after private endpoint is deployed."
  type        = bool
  default     = true
}

variable "storage_containers" {
  description = "Blob container names to create. All containers are private."
  type        = list(string)
  default     = []
}

# --- Azure Data Factory ---

variable "adf_name" {
  description = "Azure Data Factory name (globally unique)"
  type        = string
}

variable "adf_public_network_access_enabled" {
  description = "Allow public network access to ADF. Keep false — Managed VNet handles all connectivity."
  type        = bool
  default     = false
}

variable "app_services" {
  description = <<-EOT
    App Services to deploy. The map key becomes resource_name — the module enforces the
    "ase-" prefix so key "mot-ui-dev" produces the Azure resource "ase-mot-ui-dev".

    service_plan_key: references a key in app_service_shared_plans. null = dedicated plan.
    service_plan_sku: SKU for the dedicated plan (ignored when service_plan_key is set).
    enable_app_insights: create an Application Insights resource for this app service.
  EOT
  type = map(object({
    service_plan_key    = optional(string, null)
    service_plan_sku    = optional(string, "B1")
    enable_app_insights = optional(bool, true)
    node_version        = optional(string, "20-lts")
    app_settings        = optional(map(string), {})
  }))
  default = {}
}

variable "app_service_shared_plans" {
  description = "Shared App Service Plans. Keys are referenced via service_plan_key in app_services."
  type = map(object({
    sku_name = string
  }))
  default = {}
}



# ---- functions ----

variable "function_name" {}

variable "app_service_plan_id" {}

variable "storage_account_name" {}
variable "storage_account_access_key" {
  sensitive = true
}

variable "functions_subnet_id" {}

variable "cosmos_secret_uri" {}