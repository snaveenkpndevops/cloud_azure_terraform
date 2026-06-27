
data "azurerm_subscription" "current" {}

locals {
  aide_id = "uhgwm110-026049"
  global_tags = {
    "aide-id"      = local.aide_id
    "environment"  = var.namespace
    "service-tier" = "p2"
  }
}

module "optum_tags" {
  source         = "git::https://github.com/dojo360/optum-tags"
  tags           = local.global_tags
  cloud_provider = "azure"
}

module "sa" {
  for_each = var.function_apps

  # Go to https://github.com/dojo360/azure-storage-account/releases for the latest version.
  source              = "git::https://github.com/dojo360/azure-storage-account//profiles/storage-account?ref=v114.2.0"

  name = each.value.storage_account.name_prefix
  namespace           = var.namespace
  resource_group_name = data.azurerm_resource_group.my_rg.name
  location            = data.azurerm_resource_group.my_rg.location
  tags                = module.optum_tags.tags

  shared_access_key_enabled         = each.value.storage_account.shared_access_key_enabled
  shared_access_key_warning_enabled = false

  default_action = "Deny"

  bypass = "AzureServices"

  ip_rules = [
    "128.35.0.0/16",
    "149.111.0.0/16",
    "161.249.0.0/16",
    "168.183.0.0/16",
    "198.203.174.0/23",
    "198.203.176.0/22",
    "198.203.180.0/23"
  ]

  observability = {
    enabled = false
  }

  # Uncomment if public endpoint not needed.
  # private_endpoints = {
  #   enabled = false
  # }

  # depends_on = [
  #   azurerm_private_dns_zone_virtual_network_link.storage_link,
  #   azurerm_private_dns_zone_virtual_network_link.storage_file_link
  # ]

  private_endpoints = {
    enabled = true

    endpoints = [
      {
        key          = "${each.key}-blob-pe"
        service_type = "blob"

        network = {
          subnet_id          = data.azurerm_subnet.my_private_snet.id
          virtual_network_id = data.azurerm_virtual_network.my_vnet.id
        }

        private_dns_zone_group = {
          nextgen_enabled      = false
          name                 = "privatelink.blob.core.windows.net"
          #private_dns_zone_ids = [azurerm_private_dns_zone.storage_blob.id]
          private_dns_zone_ids = [data.azurerm_private_dns_zone.storage_blob.id]
        }
      },
      {
        key          = "${each.key}-file-pe"
        service_type = "file"

        network = {
          subnet_id          = data.azurerm_subnet.my_private_snet.id
          virtual_network_id = data.azurerm_virtual_network.my_vnet.id
        }

        private_dns_zone_group = {
          nextgen_enabled      = false
          name                 = "privatelink.file.core.windows.net"
          #private_dns_zone_ids = [azurerm_private_dns_zone.storage_file.id]
          private_dns_zone_ids = [data.azurerm_private_dns_zone.storage_file.id]
        }
      }
    ]
  }
}

module "plan" {
  for_each = var.function_apps

  # Go to https://github.com/dojo360/azure-app-service-plan/releases for the latest version.
  source              = "git::https://github.com/dojo360/azure-app-service-plan//profiles/scale-out-v2?ref=v114.1.1"
  name                = each.value.app_service_plan.name
  namespace           = var.namespace
  resource_group_name = data.azurerm_resource_group.my_rg.name
  location            = data.azurerm_resource_group.my_rg.location
  tags                = module.optum_tags.tags

  autoscale_profile = each.value.app_service_plan.autoscale_profile
  os_type           = each.value.app_service_plan.os_type
  sku_name          = each.value.app_service_plan.sku_name
  observability = {
    enabled = false
  }
}

module "func" {
  for_each = var.function_apps

  # Go to https://github.com/dojo360/azure-function-app/releases for the latest version.
  source              = "git::https://github.com/dojo360/azure-function-app//profiles/windows-function-app?ref=v114.3.0"

  name                = each.value.function_app.name
  namespace           = var.namespace
  resource_group_name = data.azurerm_resource_group.my_rg.name
  location            = data.azurerm_resource_group.my_rg.location
  tags                = module.optum_tags.tags

  identity = {
    type = "SystemAssigned"
  }

  service_plan_id                = module.plan[each.key].id
  storage_account_name           = module.sa[each.key].name
  storage_uses_managed_identity  = true
  # storage_account_access_key is intentionally omitted: the AzureRM provider
  # has storage_use_azuread = true which disables shared key auth on the storage
  # account. The function app authenticates via its system-assigned managed
  # identity using the RBAC role assignments below instead.

  virtual_network_subnet_id = data.azurerm_subnet.my_vnet_integration_snet.id

  # Uncomment this, if functions bindings needed
  # functions = each.value.functions

  app_settings = merge(
    {
      FUNCTIONS_EXTENSION_VERSION      = "~4"
      WEBSITE_RUN_FROM_PACKAGE         = "1"
      WEBSITE_VNET_ROUTE_ALL           = "1"
      # Explicitly set managed identity storage auth format.
      # Required when storage_use_azuread = true is set in the provider and
      # shared key access is disabled. Overrides any key-based AzureWebJobsStorage
      # connection string the module may otherwise inject.
      AzureWebJobsStorage__accountName  = module.sa[each.key].name
      AzureWebJobsStorage__credential   = "managedidentity"
    },
    each.value.app_settings
  )

  observability = {
    enabled = false
  }

  site_config = merge(
    {
      application_stack = merge(
        {},
        each.value.function_app.application_stack
      ),
      ip_restriction_default_action = "Allow"
      scm_ip_restriction_default_action = "Allow"
      app_service_logs = {
        disk_quota_mb         = 35
        retention_period_days = 7
      }
      application_insights_key               = azurerm_application_insights.insights[each.key].instrumentation_key
      application_insights_connection_string = azurerm_application_insights.insights[each.key].connection_string
    },
    each.value.site_config
  )

  # Uncomment the below lines for private endpoint 
  # private_endpoints = {
  #   endpoints = [
  #     {
  #       key = format("%s-%s", var.private_subnet.virtual_network_name, var.private_subnet.name)

  #       network = {
  #         subnet_id          = data.azurerm_subnet.my_private_snet.id
  #         virtual_network_id = data.azurerm_virtual_network.my_vnet.id
  #       }

  #       private_dns_zone_group = {
  #         nextgen_enabled      = false
  #         private_dns_zone_ids = [azurerm_private_dns_zone.func_pep.id]
  #       }
  #     }
  #   ]
  # }

  private_endpoints = {
    enabled = false
  }

  public_network_access_enabled = true


  slots = [
    for slot in each.value.slots : {
      name                          = slot.name
      storage_account_name          = module.sa[each.key].name
      storage_uses_managed_identity = true

      app_settings = {
        AzureWebJobsStorage__accountName = module.sa[each.key].name
        AzureWebJobsStorage__credential  = "managedidentity"
        FUNCTIONS_EXTENSION_VERSION      = "~4"
        WEBSITE_RUN_FROM_PACKAGE         = "1"
        WEBSITE_VNET_ROUTE_ALL           = "1"
        WEBSITE_DNS_SERVER               = "168.63.129.16"
      }

      site_config = merge(
        {
          application_stack = merge(
            {},
            each.value.function_app.application_stack
          ),
          ip_restriction_default_action = "Allow"
          scm_ip_restriction_default_action = "Allow"
          app_service_logs = {
            disk_quota_mb         = 35
            retention_period_days = 7
          }
          application_insights_key               = azurerm_application_insights.insights[each.key].instrumentation_key
          application_insights_connection_string = azurerm_application_insights.insights[each.key].connection_string          
        },
        each.value.site_config
      )
      virtual_network_subnet_id = data.azurerm_subnet.my_vnet_integration_snet.id

      # Uncomment the below lines for private endpoint 
      # private_endpoints = {
      #   endpoints = [
      #     {
      #       key = format("%s-%s", var.private_subnet.virtual_network_name, var.private_subnet.name)

      #       network = {
      #         subnet_id          = data.azurerm_subnet.my_private_snet.id
      #         virtual_network_id = data.azurerm_virtual_network.my_vnet.id
      #       }

      #       private_dns_zone_group = {
      #         nextgen_enabled      = false
      #         private_dns_zone_ids = [azurerm_private_dns_zone.func_pep.id]
      #       }
      #     }
      #   ]
      # }

      private_endpoints = {
        enabled = false
      }
    }
  ]

  depends_on = [module.sa]
}
 

resource "azurerm_application_insights" "insights" {
  for_each            = var.function_apps
  name                = "${each.value.function_app.name}-appi"
  location            = data.azurerm_resource_group.my_rg.location
  resource_group_name = data.azurerm_resource_group.my_rg.name
  application_type    = "web"
  workspace_id        = data.azurerm_log_analytics_workspace.workspace.id
  tags                = module.optum_tags.tags
}

# ---------------------------------------------------------------------------
# RBAC: grant each function app's system-assigned identity the minimum roles
# required on its storage account when storage_use_azuread = true is enforced
# in the AzureRM provider (shared key auth is disabled by the storage module).
# Without these assignments the host runtime fails to acquire the host lock
# lease and returns 403 AuthenticationFailed on every start-up.
# ---------------------------------------------------------------------------

resource "azurerm_role_assignment" "func_storage_blob_owner" {
  for_each = var.function_apps

  scope                = module.sa[each.key].id
  role_definition_name = "Storage Blob Data Owner"
  principal_id         = module.func[each.key].identity[0].principal_id

  depends_on = [module.func, module.sa]
}

resource "azurerm_role_assignment" "func_storage_queue_contributor" {
  for_each = var.function_apps

  scope                = module.sa[each.key].id
  role_definition_name = "Storage Queue Data Contributor"
  principal_id         = module.func[each.key].identity[0].principal_id

  depends_on = [module.func, module.sa]
}

resource "azurerm_role_assignment" "func_storage_table_contributor" {
  for_each = var.function_apps

  scope                = module.sa[each.key].id
  role_definition_name = "Storage Table Data Contributor"
  principal_id         = module.func[each.key].identity[0].principal_id

  depends_on = [module.func, module.sa]
}

