data azurerm_virtual_network "my_uhg_azure_vnet" {
name                = var.virtual_network_name
resource_group_name = var.resource_group_name
}

data "azurerm_subnet" "ssisir_subnet" {
name                 = var.subnet_name
virtual_network_name = data.azurerm_virtual_network.my_uhg_azure_vnet.name
resource_group_name  = var.resource_group_name

}

#selfhosted IR
#resource "azurerm_data_factory_integration_runtime_self_hosted" "this" {
#    name            = "quantam-adf-shir-${var.location}-${var.environment}"
#    data_factory_id = azurerm_data_factory.azure_dataFactory.id
#}


resource "azurerm_data_factory_integration_runtime_azure_ssis" "ssis" {
  name            = "quantam-ssis-ir-${var.location}-${var.environment}"
  data_factory_id = azurerm_data_factory.azure_dataFactory.id
  location        = var.location

  node_size       = "Standard_D2_v3"
  number_of_nodes = 1

  # managed_virtual_network_enabled = true

  express_vnet_integration {
   subnet_id = data.azurerm_subnet.ssisir_subnet.id
  }

  catalog_info {
    server_endpoint        = var.sqlmi_endpoint
    administrator_login    = var.sqlmi_admin_login
    administrator_password = var.sqlmi_admin_password
  }
}
