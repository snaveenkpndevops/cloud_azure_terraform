data "azurerm_client_config" "current" {}

data "azurerm_resource_group" "quantam" {
  name = var.azure_resource_group_name
}

module "optum_tags" {
  source         = "git::https://github.com/dojo360/optum-tags"
  tags           = local.global_tags
  cloud_provider = "azure"
}

locals {
  aide_id = "uhgwm110-026049"
  global_tags = {
    "aide-id"      = local.aide_id
    "environment"  = var.environment
    "service-tier" = "p2"
  }

}



#adf
resource "azurerm_data_factory" "azure_dataFactory" {
  # depends_on                      = [azurerm_user_assigned_identity.webtrax_uai]
  location                        = var.location
  name                            = "adf-quantam-${var.location}-${var.environment}"
  resource_group_name             = data.azurerm_resource_group.quantam.name
  tags                            = module.optum_tags.tags
  public_network_enabled          = false
  managed_virtual_network_enabled = true
  identity {
    type         = "SystemAssigned"
    #identity_ids = [azurerm_user_assigned_identity.webtrax_uai.id]
  }
}

data "azurerm_subnet" "pep_subnet" {
  name                 = var.pep_subnet_name
  virtual_network_name = data.azurerm_virtual_network.my_uhg_azure_vnet.name
  resource_group_name  = var.resource_group_name
}

resource "azurerm_private_endpoint" "adf_pe" {
  name                = "pep-adf-quantam-${var.environment}"
  location            = var.location
  resource_group_name = data.azurerm_resource_group.quantam.name
  subnet_id           = data.azurerm_subnet.pep_subnet.id

  private_service_connection {
    name                           = "psc-adf-quantam-${var.environment}"
    private_connection_resource_id = azurerm_data_factory.azure_dataFactory.id
    subresource_names              = ["dataFactory"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name = "default"

    private_dns_zone_ids = [
      azurerm_private_dns_zone.adf_dns.id
    ]
  }

  tags = module.optum_tags.tags
}

resource "azurerm_private_dns_zone" "adf_dns" {
  name                = "privatelink.datafactory.azure.net"
  resource_group_name = data.azurerm_resource_group.quantam.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "adf_dns_link" {
  name                  = "adf-dns-link"
  resource_group_name   = data.azurerm_resource_group.quantam.name
  private_dns_zone_name = azurerm_private_dns_zone.adf_dns.name
  virtual_network_id    = data.azurerm_virtual_network.my_uhg_azure_vnet.id
}
