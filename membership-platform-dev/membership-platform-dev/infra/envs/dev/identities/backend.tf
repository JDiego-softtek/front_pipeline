terraform {
  backend "azurerm" {
    key = "dev/identities.tfstate"
  }
}
