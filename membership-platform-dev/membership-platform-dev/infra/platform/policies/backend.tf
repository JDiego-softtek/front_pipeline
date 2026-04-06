terraform {
  backend "azurerm" {
    resource_group_name  = "rg-membership-eus2-01"
    storage_account_name = "statetfmembershipdev"
    container_name       = "tfstate"
    key                  = "platform/policies.tfstate"
  }
}
