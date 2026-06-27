//AKV linked service

resource "azurerm_key_vault" "adf_key_vault" {
#   count                           = var.create_adf_key_vault ? 1 : 0
  name                            = "akv-quantam-adf-${var.environment}"
  location                        = var.location
  resource_group_name             = data.azurerm_resource_group.quantam.name
  tags                            = module.optum_tags.tags
  enabled_for_deployment          = true
  enabled_for_template_deployment = true
  enabled_for_disk_encryption     = true
  enable_rbac_authorization       = true
  purge_protection_enabled        = true
  tenant_id                       = data.azurerm_client_config.current.tenant_id
  sku_name                        = "standard"

  network_acls {
    bypass                     = "AzureServices"
    default_action             = "Deny"
    ip_rules                   = var.adf_kv_ip_addresses
    #virtual_network_subnet_ids = var.adf_kv_subnet_ids
  }
}

resource "azurerm_data_factory_linked_service_key_vault" "this" {
 # count           = var.create_adf_key_vault ? 1 : 0
  depends_on      = [azurerm_data_factory.azure_dataFactory, azurerm_key_vault.adf_key_vault]
  name            = "quantam-adf-kv-ls-${var.location}-${var.environment}"
  data_factory_id = azurerm_data_factory.azure_dataFactory.id
  key_vault_id    = azurerm_key_vault.adf_key_vault.id
}


resource "azurerm_role_assignment" "datafactory_workspace_current_adf_akv" {
  depends_on           = [azurerm_key_vault.adf_key_vault]
  scope                = azurerm_key_vault.adf_key_vault.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_data_factory.azure_dataFactory.identity[0].principal_id
}

#resource "azurerm_role_assignment" "akv-jit-admin" {
#  depends_on           = [azurerm_key_vault.adf_key_vault]
#  scope                = azurerm_key_vault.adf_key_vault.id
#  role_definition_name = "Key Vault Administrator"
#  principal_id         = "882c830e-d7b8-4f91-933b-b76e603dd0f1"
#}


