# subscription_id is set via TF_VAR_subscription_id environment variable in CI/CD
# Common variables (project, environment, location, owner, cost_center, etc.)
# are defined in ../_shared/common.tfvars — do NOT duplicate them here.
#
# REQUIRED INVOCATION (PowerShell — run from infra/envs/dev/app/):
#   C:\terraform_1.14.7_windows_amd64\terraform.exe plan `
#     -var-file="../_shared/common.tfvars" `
#     -var-file="dev.tfvars"
#
#   C:\terraform_1.14.7_windows_amd64\terraform.exe apply `
#     -var-file="../_shared/common.tfvars" `
#     -var-file="dev.tfvars"
#
# See infra/docs/TERRAFORM_INVOCATION_GUIDE.md for details.

# Remote state references (must match the storage account used for all layers)
backend_resource_group  = "rg-membership-eus2-01"
backend_storage_account = "statetfmembershipdev"
backend_container       = "tfstate"

# --- ACR ---
acr_sku                   = "Basic"
acr_admin_enabled         = false
acr_public_access_enabled = true

# --- ACA services ---
aca_services = {
  validations = {
    image_name = "nginx"
    image_tag  = "alpine"
    cpu        = 0.5
    memory     = "1Gi"
    ingress = {
      external_enabled = false
      target_port      = 80
      transport        = "http"
    }
  }
  membership = {
    image_name = "nginx"
    image_tag  = "alpine"
    cpu        = 0.5
    memory     = "1Gi"
    ingress = {
      external_enabled = true
      target_port      = 80
      transport        = "http"
    }
  } /*
  signup = {
    image_name = "nginx"
    image_tag  = "alpine"
    cpu        = 0.5
    memory     = "1Gi"
    ingress = {
      external_enabled = false
      target_port      = 80
      transport        = "http"
    }
  }
  renewal = {
    image_name = "nginx"
    image_tag  = "alpine"
    cpu        = 0.5
    memory     = "1Gi"
    ingress = {
      external_enabled = false
      target_port      = 80
      transport        = "http"
    }
  }
  "membership-external" = {
    image_name = "nginx"
    image_tag  = "alpine"
    cpu        = 0.5
    memory     = "1Gi"
    ingress = {
      external_enabled = true
      target_port      = 80
      transport        = "http"
    }
  }*/
}

# --- APIM ---
apim_publisher_name  = "MOT Platform Team"
apim_publisher_email = "devops@mot.com"
apim_apis = {
  validations = {
    display_name    = "Validations API"
    path            = "api/validations"
    backend_service = "validations"
  }
  membership = {
    display_name    = "Membership API"
    path            = "api/membership"
    backend_service = "membership"
  } /*
  signup = {
    display_name    = "Signup API"
    path            = "api/signup"
    backend_service = "signup"
  }
  renewal = {
    display_name    = "Renewal API"
    path            = "api/renewal"
    backend_service = "renewal"
  }
  "membership-external" = {
    display_name    = "Membership External API"
    path            = "api/membership-external"
    backend_service = "membership-external"
  }
  */
}

# --- SQL ---
sql_server_name   = "sql-mot-dev"
sql_database_name = "sqldb-mot-dev"
sql_admin_user    = "sqladmindev"
min_vcores        = 0.5
max_vcores        = 1
auto_pause_delay  = 60
max_size_gb       = 1

# --- Cosmos DB ---
cosmos_account_name                  = "cosmos-mot-dev"
cosmos_serverless                    = true
cosmos_consistency_level             = "Session"
cosmos_public_network_access_enabled = true

cosmos_databases = {
  workflows-db = {
    containers = {
      workflows = {
        partition_key_paths = ["/workflowId"]
      }
    }
  }
}

# --- Blob Storage ---
# One storage account, two containers:
#   member-photos  → Sign-Up / Membership photo capture (P0)
#   as400-files    → ADF output landing zone for AS400 sync (P1)
storage_replication_type              = "LRS"
storage_public_network_access_enabled = true
storage_containers = [
  "member-photos",
  "as400-files",
]

# --- Azure Data Factory ---
adf_name                          = "adf-mot-dev"
adf_public_network_access_enabled = false

# --- App Services ---
# Key = resource_name → Azure resource = "ase-{key}" (prefix enforced in module).
# service_plan_key: null = dedicated plan; set to a key in app_service_shared_plans for sharing.
# enable_app_insights: set to false to skip App Insights creation for this service.
app_services = {
  "mot-ui-dev" = {
    service_plan_key    = null
    service_plan_sku    = "B1"
    enable_app_insights = true
    node_version        = "20-lts"
  }
}

# Shared plans — add an entry here and reference via service_plan_key above.
# Example:
#   app_service_shared_plans = {
#     "shared-frontend-dev" = { sku_name = "B2" }
#   }
app_service_shared_plans = {}

# Functions 

function_name = "func-mot-dev"
location      = "eastus"
resource_group_name = "rg-membership-eus2-01"

app_service_plan_id = "/subscriptions/52d4f2d5-1678-49e1-b8f2-c67d79ee999f/resourceGroups/rg-membership-eus2-01/providers/Microsoft.Web/serverFarms/plan-mot-ui-dev"

storage_account_name       = "cual de las 2 ?"  crear nuevo
storage_account_access_key = "xxxxxxxxxxxxxxxx"

functions_subnet_id = "/subscriptions/52d4f2d5-1678-49e1-b8f2-c67d79ee999f/resourceGroups/rg-membership-eus2-01/providers/Microsoft.Network/virtualNetworks/vnet-mot-dev/subnets/snet-functions"

# cosmos_secret_uri = "i'm unauthorized to view these contents"