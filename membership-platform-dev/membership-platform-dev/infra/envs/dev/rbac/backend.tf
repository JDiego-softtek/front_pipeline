terraform {
  backend "azurerm" {
    key = "dev/rbac.tfstate"
  }
}
