data "azurerm_client_config" "current" {}

module "optum_tags" {
  source         = "git::https://github.com/dojo360/optum-tags"
  tags           = local.global_tags
  cloud_provider = "azure"
}

## Fetches centralized Private DNS Zone IDs — do NOT pin to a version
module "azure_hub_commons" {
  source = "git::https://github.com/dojo360/azure-hub-commons"
}

locals {
  aide_id = "uhgwm110-026049"
  global_tags = {
    "aide-id"      = local.aide_id
    "environment"  = var.namespace
    "service-tier" = "p2"
  }

}

resource "azurerm_service_plan" "asp" {
  #for_each                   = local.webapps --- IGNORE temp---
  name                       = "asp-quantam-${var.location}-${var.environment}"
  location                   = var.location
  resource_group_name        = var.resource_group_name
  #app_service_environment_id = var.app_service_environment_id
  os_type                    = "Windows"
  sku_name                   = var.sku_size
  worker_count               = var.sku_capacity_default
  zone_balancing_enabled     = var.environment == "prod" ? true : false
  #zone_balancing_enabled     = var.environment == "prod" || var.environment == "dev" ? true : false   # To test and simulate Mobile app service issue 

  timeouts {
    create = "2h"
  }

  tags = module.optum_tags.tags
}

