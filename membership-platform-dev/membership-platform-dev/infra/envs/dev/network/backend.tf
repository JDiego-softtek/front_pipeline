terraform {
  backend "azurerm" {
    key = "dev/network.tfstate"
  }
}
