data "azurerm_virtual_network" "my_vnet" {
  name                = var.private_subnet.virtual_network_name
  resource_group_name = var.private_subnet.resource_group_name
}

data "azurerm_subnet" "my_private_snet" {
  name                 = var.private_subnet.name
  resource_group_name  = var.private_subnet.resource_group_name
  virtual_network_name = var.private_subnet.virtual_network_name
}

data "azurerm_subnet" "my_vnet_integration_snet" {
  name                 = var.vnet_integration_subnet.name
  resource_group_name  = var.vnet_integration_subnet.resource_group_name
  virtual_network_name = var.vnet_integration_subnet.virtual_network_name
}

data "azurerm_resource_group" "my_rg" {
  name = var.resource_group_name
}

# resource "azurerm_private_dns_zone" "func_pep" {
#   name                = "privatelink.azurewebsites.net"
#   resource_group_name = data.azurerm_resource_group.my_rg.name
#   tags                = module.optum_tags.tags
# }

# resource "azurerm_private_dns_zone_virtual_network_link" "func_pep" {
#   name                  = "link-func-pep-${var.namespace}"
#   resource_group_name   = data.azurerm_resource_group.my_rg.name
#   private_dns_zone_name = azurerm_private_dns_zone.func_pep.name
#   virtual_network_id    = data.azurerm_virtual_network.my_vnet.id
#   tags                  = module.optum_tags.tags
# }

# resource "azurerm_private_dns_zone" "storage_blob" {
#   name                = "privatelink.blob.core.windows.net"
#   resource_group_name = data.azurerm_resource_group.my_rg.name
# }

# resource "azurerm_private_dns_zone_virtual_network_link" "storage_link" {
#   name                  = "storage-link-${var.namespace}"
#   resource_group_name   = data.azurerm_resource_group.my_rg.name
#   private_dns_zone_name = azurerm_private_dns_zone.storage_blob.name
#   virtual_network_id    = data.azurerm_virtual_network.my_vnet.id
# }

# resource "azurerm_private_dns_zone" "storage_file" {
#   name                = "privatelink.file.core.windows.net"
#   resource_group_name = data.azurerm_resource_group.my_rg.name
# }

# resource "azurerm_private_dns_zone_virtual_network_link" "storage_file_link" {
#   name                  = "storage-file-link-${var.namespace}"
#   resource_group_name   = data.azurerm_resource_group.my_rg.name
#   private_dns_zone_name = azurerm_private_dns_zone.storage_file.name
#   virtual_network_id    = data.azurerm_virtual_network.my_vnet.id
# }


data "azurerm_private_dns_zone" "storage_blob" {
  name                = "privatelink.blob.core.windows.net"
  resource_group_name = var.networking_resource_group_name
}

data "azurerm_private_dns_zone" "storage_file" {
  name                = "privatelink.file.core.windows.net"
  resource_group_name = var.networking_resource_group_name
}

data "azurerm_log_analytics_workspace" "workspace" {
  name                = var.analytics_workspace_name
  resource_group_name = var.networking_resource_group_name
}