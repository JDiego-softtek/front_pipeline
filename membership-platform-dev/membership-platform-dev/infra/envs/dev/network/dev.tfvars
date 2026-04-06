# subscription_id is set via TF_VAR_subscription_id environment variable in CI/CD
# Common variables (project, environment, location, owner, cost_center, etc.)
# are defined in ../_shared/common.tfvars — do NOT duplicate them here.
#
# REQUIRED INVOCATION (PowerShell — run from infra/envs/dev/network/):
#   C:\terraform_1.14.7_windows_amd64\terraform.exe plan `
#     -var-file="../_shared/common.tfvars" `
#     -var-file="dev.tfvars"
#
#   C:\terraform_1.14.7_windows_amd64\terraform.exe apply `
#     -var-file="../_shared/common.tfvars" `
#     -var-file="dev.tfvars"
#
# See infra/docs/TERRAFORM_INVOCATION_GUIDE.md for details.

enable_private_endpoints = false

vnet_cidr = "10.10.0.0/20"

subnets = {
  # Entry layer
  snet-apim = {
    cidr = "10.10.0.0/24"
  }

  # Frontend App Service VNet integration
  snet-frontend = {
    cidr = "10.10.1.0/24"
    delegation = {
      name    = "appservice-delegation"
      service = "Microsoft.Web/serverFarms"
      actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
    }
  }

  # Container Apps environment /23 — one IP per replica pod, zone-redundant scaling
  snet-aca-exp = {
    cidr = "10.10.2.0/23"
    delegation = {
      name    = "aca-delegation"
      service = "Microsoft.App/environments"
      actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
    }
  }

  # Private endpoints for all PaaS services SQL, KV, ACR, Cosmos, SB, Blob
  snet-data = {
    cidr                              = "10.10.4.0/24"
    private_endpoint_network_policies = "Enabled"
  }

  # Bastion spoke access and internal tooling
  snet-management = {
    cidr = "10.10.5.0/26"
  }

  # Logic Apps Standard VNet integration
  snet-logic-apps = {
    cidr = "10.10.5.128/25"
  }

  # Durable Functions VNet integration
  snet-functions = {
    cidr = "10.10.6.0/25"
  }

}
