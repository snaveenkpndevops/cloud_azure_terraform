terraform {
  backend "azurerm" {}
  required_version = "~> 1.14"
  required_providers {
    # dojo360 = {
    #   source = "uhg-dojo360/dojo360"
    # }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

provider "azurerm" {
  storage_use_azuread = true
  subscription_id     = var.subscription_id
  features {}
}

# provider "dojo360" {
#   client_id     = var.oauth_client_id
#   client_secret = var.oauth_client_secret
#   cloud_type    = "azure"
# }
