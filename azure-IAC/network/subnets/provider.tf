terraform {
  backend "azurerm" {}
  required_version = "~> 1.14"
  required_providers {
    uhg = {
      source  = "uhg-uhg/uhg"
      version = "~> 1.16"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}

provider "uhg" {
  oauth_client_id     = var.oauth_client_id
  oauth_client_secret = var.oauth_client_secret
}