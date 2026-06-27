## Subscription-scoped Private DNS Zones
## Created ONCE per subscription. Shared by all environments (tst, stg, dev).
## Never recreated per environment — webapp module reads these via data sources.

resource "azurerm_private_dns_zone" "webapp_dns" {
  name                = "privatelink.azurewebsites.net"
  resource_group_name = var.resource_group_name

  lifecycle { ignore_changes = [tags] }
}

resource "azurerm_private_dns_zone" "kv_dns" {
  name                = "privatelink.vaultcore.azure.net"
  resource_group_name = var.resource_group_name

  lifecycle { ignore_changes = [tags] }
}

resource "azurerm_private_dns_zone" "storage_blob_dns" {
  name                = "privatelink.blob.core.windows.net"
  resource_group_name = var.resource_group_name
  lifecycle { ignore_changes = [tags] }
}

resource "azurerm_private_dns_zone" "storage_file_dns" {
  name                = "privatelink.file.core.windows.net"
  resource_group_name = var.resource_group_name
  lifecycle { ignore_changes = [tags] }
}