provider "azurerm" {
  subscription_id = var.subscription_id
  features {}
}

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
    # null = {
    #   source = "hashicorp/null"
    # }
    # external = {
    #   source  = "hashicorp/external"
    #   version = "2.1.0"
    # }
    # time = {
    #   source  = "hashicorp/time"
    #   version = "~> 0.7.2"
    # }
  }
}
