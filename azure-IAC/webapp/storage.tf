## =========================================================
## QUANTAM STORAGE ACCOUNTS
## File: storage.tf
## Uses native azurerm resources — consistent with webapp.tf.
## dojo360 provider is NOT used here because webapp-deploy.yaml
## uses the EPL reusable workflow which does not support dojo360.
## =========================================================

locals {
  ## Unique service types across all storage accounts → one DNS zone per type
  all_storage_service_types = toset(flatten([
    for sa_key, sa in var.storage_accounts : sa.endpoint_service_types
  ]))

  storage_dns_zone_names = {
    blob  = "privatelink.blob.core.windows.net"
    file  = "privatelink.file.core.windows.net"
    table = "privatelink.table.core.windows.net"
    queue = "privatelink.queue.core.windows.net"
  }
}


## ---------------------------------------------------------
## Private DNS Zones — one per service type
## Team-managed + VNet-linked (spoke VNet) so webapp DNS
## resolves storage FQDNs to private endpoint IPs correctly.
## ---------------------------------------------------------

data "azurerm_private_dns_zone" "storage" {
  for_each            = local.all_storage_service_types
  name                = local.storage_dns_zone_names[each.key]
  resource_group_name = var.resource_group_name
}

resource "azurerm_private_dns_zone_virtual_network_link" "storage" {
  for_each              = local.all_storage_service_types
  name                  = "storage-${each.key}-link-${var.namespace}"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = data.azurerm_private_dns_zone.storage[each.key].name
  virtual_network_id    = data.azurerm_virtual_network.my_uhg_azure_vnet.id
  tags                  = module.optum_tags.tags
}

## ---------------------------------------------------------
## Storage Accounts
## Name = {name}{namespace} e.g. stqtm20tst
## ---------------------------------------------------------
resource "azurerm_storage_account" "quantam" {
  for_each = var.storage_accounts

  #name                = "${each.value.name}${var.namespace}"
  name                = "${each.value.name}"
  resource_group_name = var.resource_group_name
  location            = var.location

  account_kind             = "StorageV2"
  account_tier             = "Standard"
  account_replication_type = "LRS"

  https_traffic_only_enabled        = true
  min_tls_version                   = "TLS1_2"
  infrastructure_encryption_enabled = true
  allow_nested_items_to_be_public   = false
  shared_access_key_enabled         = each.value.shared_access_key_enabled

#  network_rules {
#    default_action = "Deny"
#    bypass         = ["AzureServices"]
#    ip_rules       = []
#  }

  network_rules {
    default_action = "Deny"
    bypass         = ["AzureServices"]
    ip_rules = [
      "128.35.0.0/16",
      "149.111.0.0/16",
      "161.249.0.0/16",
      "168.183.0.0/16",
      "198.203.174.0/23",
      "198.203.176.0/22",
      "198.203.180.0/23"
    ]
  }

  identity {
    type = "SystemAssigned"
  }

  tags = module.optum_tags.tags
}

## ---------------------------------------------------------
## Blob Containers
## Flattened: for each SA × each container
## ---------------------------------------------------------
resource "azurerm_storage_container" "quantam" {
  for_each = {
    for item in flatten([
      for sa_key, sa in var.storage_accounts : [
        for ctr in sa.containers : {
          key          = "${sa_key}-${ctr.name}"
          sa_key       = sa_key
          name         = ctr.name
          access_type  = ctr.access_type
        }
      ]
    ]) : item.key => item
  }

  name                  = each.value.name
  #storage_account_id    = azurerm_storage_account.quantam[each.value.sa_key].id
  storage_account_name  = azurerm_storage_account.quantam[each.value.sa_key].name
  container_access_type = each.value.access_type
}

## ---------------------------------------------------------
## File Shares (requires shared_access_key_enabled = true)
## Flattened: for each SA × each share
## ---------------------------------------------------------
resource "azurerm_storage_share" "quantam" {
  for_each = {
    for item in flatten([
      for sa_key, sa in var.storage_accounts : [
        for share in sa.shares : {
          key    = "${sa_key}-${share.name}"
          sa_key = sa_key
          name   = share.name
          quota  = share.quota
        }
      ]
    ]) : item.key => item
  }

  name               = each.value.name
  #storage_account_id = azurerm_storage_account.quantam[each.value.sa_key].id
  storage_account_name = azurerm_storage_account.quantam[each.value.sa_key].name
  quota              = each.value.quota
}

## ---------------------------------------------------------
## Private Endpoints — one per SA × service type
## ---------------------------------------------------------
resource "azurerm_private_endpoint" "storage" {
  for_each = {
    for item in flatten([
      for sa_key, sa in var.storage_accounts : [
        for svc_type in sa.endpoint_service_types : {
          key      = "${sa_key}-${svc_type}-pep"
          sa_key   = sa_key
          svc_type = svc_type
        }
      ]
    ]) : item.key => item
  }

  name                = "pep-${each.value.sa_key}-${each.value.svc_type}-${var.location}-${var.environment}"
  resource_group_name = var.resource_group_name
  location            = var.location
  subnet_id           = data.azurerm_subnet.pep_subnet.id

  private_service_connection {
    name                           = "psc-${each.value.sa_key}-${each.value.svc_type}-${var.environment}"
    private_connection_resource_id = azurerm_storage_account.quantam[each.value.sa_key].id
    is_manual_connection           = false
    subresource_names              = [each.value.svc_type]
  }

  private_dns_zone_group {
    name = "pdz-${each.value.sa_key}-${each.value.svc_type}"
    private_dns_zone_ids = [
      data.azurerm_private_dns_zone.storage[each.value.svc_type].id
    ]
  }

  depends_on = [azurerm_private_dns_zone_virtual_network_link.storage]

  tags = module.optum_tags.tags
}

## ---------------------------------------------------------
## RBAC — Storage Blob Data Contributor
## Grants each webapp's system-assigned identity access to
## the storage account so it can auth via DefaultAzureCredential
## webapp_access uses the webapps local map key (quantam2_0 etc.)
## ---------------------------------------------------------
resource "azurerm_role_assignment" "storage_blob_contributor" {
  for_each = {
    for item in flatten([
      for sa_key, sa in var.storage_accounts : [
        for webapp_key in sa.webapp_access : {
          key        = "${sa_key}-${webapp_key}"
          sa_key     = sa_key
          webapp_key = webapp_key
        }
      ]
    ]) : item.key => item
  }

  scope                = azurerm_storage_account.quantam[each.value.sa_key].id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_windows_web_app.app[each.value.webapp_key].identity[0].principal_id
}
