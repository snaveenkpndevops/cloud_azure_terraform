provider "azurerm" {
  subscription_id = var.subscription_id
  features {}
}

provider "azapi" {}

terraform {
  backend "azurerm" {}

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.2.0"
    }

    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.35.0"
    }

    azapi = {
      source  = "Azure/azapi"
      version = "~> 1.13"
    }
  }
}
