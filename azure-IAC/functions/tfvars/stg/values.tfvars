# =========================
# GLOBAL CONFIG
# =========================

resource_group_name = "rg-quantam-centralus-stg"
networking_resource_group_name = "pc-managed-networking"
subscription_id = "14b710f0-0020-4b63-887d-22a232c0324c"
analytics_workspace_name = "webapp-law-stg"

namespace = "stg"

private_subnet = {
  name                 = "snet-quantam-pep-centralus-stg"
  resource_group_name  = "pc-managed-networking"
  virtual_network_name = "pcm-network-cus-quantam-vnet-stg"
}

vnet_integration_subnet = {
  name                 = "snet-quantam-app-centralus-stg"
  resource_group_name  = "pc-managed-networking"
  virtual_network_name = "pcm-network-cus-quantam-vnet-stg"
}

# =========================
# FUNCTION APPS
# =========================

function_apps = {

  app1 = {
    function_app = {
      name           = "func-quantam-2-0-apis"
      application_stack = {
        dotnet_version = "v6.0"
      }
      #os_type        = "Windows"
    }

    app_settings = {
      "AzureWebJobs.ManualACHQueuesSampling.Disabled" = "0"
      "AzureWebJobs.MedicaCDC360ServiceDroidFileExport.Disabled" = "0"
      #"WEBSITE_CONTENTSHARE" = "medicatestazurefuncb4d8"
      "FUNCTIONS_EXTENSION_VERSION" = "~4"
      "WEBSITE_DNS_SERVER" = "168.63.129.16"
    }

    site_config = {
        minimum_tls_version = "1.2"
        http2_enabled       = true
        ftps_state          = "FtpsOnly"
    }

    app_service_plan = {
      name              = "asp-quantam-2-0-apis"
      sku_name          = "P1v3"
      os_type           = "Windows"
      autoscale_profile = null
    }

    storage_account = {
      name_prefix               = "stqtm20apis"
      shared_access_key_enabled = true
    }

# Uncomment this, if functions bindings needed
#    functions = [
#      {
#        name = "httptrigger1"
#       config_json = "{\"bindings\":[{\"name\":\"req\",\"type\":\"httpTrigger\",\"direction\":\"in\",\"methods\":[\"get\",\"post\"],\"authLevel\":\"function\"},{\"name\":\"$return\",\"type\":\"http\",\"direction\":\"out\"}]}"
#      }
#    ]

    slots = [
      { name = "slot-stg-1" }
    ]
  }

  app2 = {
    function_app = {
      name           = "func-quantam-medicaappservice-apis"
      application_stack = {
        dotnet_version = "v6.0"
      }
      #os_type        = "Windows"
    }

    app_settings = {
      "AzureWebJobs.ManualACHQueuesSampling.Disabled" = "0"
      "AzureWebJobs.MedicaCDC360ServiceDroidFileExport.Disabled" = "0"
      #"WEBSITE_CONTENTSHARE" = "medicatestazurefuncb4d8"
      "FUNCTIONS_EXTENSION_VERSION" = "~4"
      "WEBSITE_DNS_SERVER" = "168.63.129.16"
    }

    site_config = {
        minimum_tls_version = "1.2"
        http2_enabled       = true
        ftps_state          = "FtpsOnly"
    }

    app_service_plan = {
      name              = "asp-quantam-medica-apis"
      sku_name          = "P1v3"
      os_type           = "Windows"
      autoscale_profile = null
    }

    storage_account = {
      name_prefix               = "stmedica"
      shared_access_key_enabled = true
    }

# Uncomment this, if functions bindings needed
#    functions = [
#      {
#        name = "httptrigger1"
#       config_json = "{\"bindings\":[{\"name\":\"req\",\"type\":\"httpTrigger\",\"direction\":\"in\",\"methods\":[\"get\",\"post\"],\"authLevel\":\"function\"},{\"name\":\"$return\",\"type\":\"http\",\"direction\":\"out\"}]}"
#      }
#    ]

    slots = []
  }
}
 
