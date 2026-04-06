terraform {
  backend "azurerm" {
    key = "dev/observability.tfstate"
  }
}
