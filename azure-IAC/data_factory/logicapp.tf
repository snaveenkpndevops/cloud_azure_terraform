data "azurerm_subnet" "logicapp_subnet" {
  name                 = var.logicapp_subnet_name
  virtual_network_name = data.azurerm_virtual_network.my_uhg_azure_vnet.name
  resource_group_name  = var.resource_group_name
}

resource "azurerm_storage_account" "logicapp_storage" {
  name                     = "stglogicapp${var.environment}"
  resource_group_name      = data.azurerm_resource_group.quantam.name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"
  min_tls_version          = "TLS1_2"

  public_network_access_enabled = false

  tags = module.optum_tags.tags
}

resource "azurerm_private_endpoint" "logicapp_storage_pe" {
  name                = "pe-logicapp-storage-quantam-${var.environment}"
  location            = var.location
  resource_group_name = data.azurerm_resource_group.quantam.name
  subnet_id           = data.azurerm_subnet.pep_subnet.id
  tags                = module.optum_tags.tags

  private_service_connection {
    name                           = "psc-logicapp-storage-quantam-${var.environment}"
    private_connection_resource_id = azurerm_storage_account.logicapp_storage.id
    is_manual_connection           = false
    subresource_names              = ["blob"]
  }

  dynamic "private_dns_zone_group" {
    for_each = var.private_dns_zone_blob_id != "" ? [1] : []
    content {
      name                 = "pdns-logicapp-storage"
      private_dns_zone_ids = [var.private_dns_zone_blob_id]
    }
  }
}

resource "azurerm_service_plan" "logicapp_plan" {
  name                = "asp-logicapp-quantam-${var.environment}"
  resource_group_name = data.azurerm_resource_group.quantam.name
  location            = var.location
  os_type             = "Windows"
  sku_name            = "WS1"

  tags = module.optum_tags.tags
}

resource "azurerm_logic_app_standard" "email_notification" {
  name                       = "logic-quantam-email-${var.environment}"
  location                   = var.location
  resource_group_name        = data.azurerm_resource_group.quantam.name
  app_service_plan_id        = azurerm_service_plan.logicapp_plan.id
  storage_account_name       = azurerm_storage_account.logicapp_storage.name
  storage_account_access_key = azurerm_storage_account.logicapp_storage.primary_access_key
  version                    = "~4"

  virtual_network_subnet_id = data.azurerm_subnet.logicapp_subnet.id

  app_settings = {
    "FUNCTIONS_WORKER_RUNTIME"     = "node"
    "WEBSITE_NODE_DEFAULT_VERSION" = "~18"
    "WEBSITE_CONTENTOVERVNET"      = "1"
    "WEBSITE_VNET_ROUTE_ALL"       = "1"
    "WEBSITE_DNS_SERVER"           = "168.63.129.16"
  }

  site_config {
    vnet_route_all_enabled        = true
    public_network_access_enabled = false
  }

  identity {
    type = "SystemAssigned"
  }

  tags = module.optum_tags.tags
}

resource "azurerm_private_endpoint" "logicapp_pe" {
  name                = "pe-logicapp-quantam-${var.environment}"
  location            = var.location
  resource_group_name = data.azurerm_resource_group.quantam.name
  subnet_id           = data.azurerm_subnet.pep_subnet.id
  tags                = module.optum_tags.tags

  private_service_connection {
    name                           = "psc-logicapp-quantam-${var.environment}"
    private_connection_resource_id = azurerm_logic_app_standard.email_notification.id
    is_manual_connection           = false
    subresource_names              = ["sites"]
  }

  dynamic "private_dns_zone_group" {
    for_each = var.private_dns_zone_sites_id != "" ? [1] : []
    content {
      name                 = "pdns-logicapp"
      private_dns_zone_ids = [var.private_dns_zone_sites_id]
    }
  }
}

# Optional later if ADF must call Logic App through managed private networking
# resource "azurerm_data_factory_managed_private_endpoint" "adf_to_logicapp" {
#   name               = "pe-adf-to-logicapp-quantam-${var.environment}"
#   data_factory_id    = azurerm_data_factory.azure_dataFactory.id
#   target_resource_id = azurerm_logic_app_standard.email_notification.id
#   subresource_name   = "sites"
#
#   depends_on = [azurerm_private_endpoint.logicapp_pe]
# }
