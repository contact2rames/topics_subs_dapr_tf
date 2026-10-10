terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=4.5.0"
    }
  }

  backend "azurerm" {
    resource_group_name  = "yyyyy-poc-dev-rg"
    storage_account_name = "yyyyypocqa"
    container_name       = "tfstate"
    key                  = "qa/poc-dapr-components.tfstate"
    use_azuread_auth = true
  }
}

provider "azurerm" {
  features {}

  resource_provider_registrations = "none"

  subscription_id = ""
}