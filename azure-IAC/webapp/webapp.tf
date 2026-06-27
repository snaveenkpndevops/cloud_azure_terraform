## =========================================================
##  QUANTAM MIGRATION
## File: webapp.tf
## Phase‑1: Platform skeleton only
## Phase‑2: Full web app configuration with IP restrictions, APR21
## =========================================================

locals {

  
  webapps = {
    quantam = {
      name = "ase-quantam-web-${var.location}-${var.environment}"
      kv_name = "kv-qtmweb-${var.location}-${var.environment}"
    }
    quantam2_0 = {
      name = "ase-quantam-2-0-${var.location}-${var.environment}"
      kv_name = "kv-qtm2-${var.location}-${var.environment}"
    }
    trackingapi = {
      name = "ase-quantam-trackingapi-${var.location}-${var.environment}"
      kv_name = "kv-qtmtapi-${var.location}-${var.environment}"
    }
    medicaappservice = {
      name    = "ase-quantam-medicaappservice-${var.location}-${var.environment}"
      kv_name = "kv-medica-${var.environment}"
    }
    quantam_appservices = {
      name    = "ase-quantam-appservices-${var.location}-${var.environment}"
      kv_name = "kv-appsvc-${var.environment}"
    }

  
  ## WEBTRAX APPS (COMMENTED – NOT DELETED)
  # webapps = {
  #   webtrax = {
  #     name = "webtrax-${var.environment}"
  #   }
  #   ops2 = {
  #    name = "ops2-${var.environment}"
  #  }
  }
  
  ## -------------------------------------------------------
  ## WEBTRAX: Zscaler IP Restrictions
  ## COMMENTED FOR QUANTAM PHASE‑1
  ## -------------------------------------------------------</start>
  ##Generate dynamic IP restrictions for zscaler IPs
  zscaler_ip_restrictions = [
    for idx, ip in var.zscaler_ips : {
      ip_address                = ip
      name                      = "zscaler-${idx + 1}"
      priority                  = 220 + idx
      action                    = "Allow"
      headers                   = []
      service_tag               = null
      virtual_network_subnet_id = null
    }
  ]

  # # Generate dynamic SCM IP restrictions for zscaler IPs
  zscaler_scm_ip_restrictions = [
    for idx, ip in var.zscaler_ips : {
      ip_address                = ip
      name                      = "zscaler-scm-${idx + 1}"
      priority                  = 320 + idx
      action                    = "Allow"
      headers                   = []
      service_tag               = null
      virtual_network_subnet_id = null
    }
  ]

  # For each webapp key, find the first storage account that grants it access
  # Driven by webapp_access field — no SA key hardcoded
  storage_by_webapp = {
    for webapp_key in keys(local.webapps) :
    webapp_key => try(
      [for sa in values(var.storage_accounts) : sa if contains(sa.webapp_access, webapp_key)][0],
      null
    )
  }

  ## ----------------------------------------------------------
  ## Per-app settings map
  ## ----------------------------------------------------------
  quantam2_0_app_settings = {
    # Secrets — resolved from this app's own Key Vault at runtime by Azure
    "DB_USER"                 = "@Microsoft.KeyVault(VaultName=${local.webapps.quantam2_0.kv_name};SecretName=DB-USER)"
    "DB_PWD"                  = "@Microsoft.KeyVault(VaultName=${local.webapps.quantam2_0.kv_name};SecretName=DB-PWD)"
    "DB_SERVER"               = "@Microsoft.KeyVault(VaultName=${local.webapps.quantam2_0.kv_name};SecretName=DB-SERVER)"
    "DB_NAME"                 = "@Microsoft.KeyVault(VaultName=${local.webapps.quantam2_0.kv_name};SecretName=DB-NAME)"
    "NAS_ENDPOINT_URL"        = "@Microsoft.KeyVault(VaultName=${local.webapps.quantam2_0.kv_name};SecretName=NAS-ENDPOINT-URL)"
    "NAS_USER_ID"             = "@Microsoft.KeyVault(VaultName=${local.webapps.quantam2_0.kv_name};SecretName=NAS-USER-ID)"
    "NAS_USER_PASSWORD"       = "@Microsoft.KeyVault(VaultName=${local.webapps.quantam2_0.kv_name};SecretName=NAS-USER-PASSWORD)"
    "NAS_BASE_PATH"           = "@Microsoft.KeyVault(VaultName=${local.webapps.quantam2_0.kv_name};SecretName=NAS-BASE-PATH)"
    "QUANTAM_API_NAS_URL"     = "@Microsoft.KeyVault(VaultName=${local.webapps.quantam2_0.kv_name};SecretName=QUANTAM-API-NAS-URL)"
    "Snow_Flake_Key"          = "@Microsoft.KeyVault(VaultName=${local.webapps.quantam2_0.kv_name};SecretName=Snow-Flake-Key)"
    "FALLBACK_APPROVER_EMAIL" = "@Microsoft.KeyVault(VaultName=${local.webapps.quantam2_0.kv_name};SecretName=FALLBACK-APPROVER-EMAIL)"
    "Sql_Request_Timeout"     = "@Microsoft.KeyVault(VaultName=${local.webapps.quantam2_0.kv_name};SecretName=Sql-Request-Timeout)"
    # Non-secret config — plain values from tfvars
    "NEXT_PUBLIC_PROD_URL"          = var.quantam2_0_prod_url
    "NEXT_PUBLIC_STAGE_URL"         = var.quantam2_0_stage_url
    "NEXT_PUBLIC_TEST_URL"          = var.quantam2_0_test_url
    "NEXT_PUBLIC_GetTrackingAPI"    = "https://${local.webapps.trackingapi.name}.azurewebsites.net"
    "NEXT_PUBLIC_SYSTEM_FROM_EMAIL" = var.system_from_email
    "WEBSITE_RUN_FROM_PACKAGE"         = "1"
    "WEBSITE_ENABLE_SYNC_UPDATE_SITE"  = "true"
    "WEBSITE_DNS_SERVER" = "168.63.129.16"
    ## Storage — blob endpoint for managed identity access (DefaultAzureCredential)
    "AZURE_STORAGE_BLOB_ENDPOINT" = local.storage_by_webapp["quantam2_0"] != null ? "https://${local.storage_by_webapp["quantam2_0"].name}.blob.core.windows.net" : ""
    ## Storage — connection string (seeded to KV, replaces NAS URL)
    "AZURE_STORAGE_CONNECTION_STRING" = "@Microsoft.KeyVault(VaultName=${local.webapps.quantam2_0.kv_name};SecretName=STORAGE-CONNECTION-STRING)"
  }

  trackingapi_app_settings = {
    # Secrets — resolved from Key Vault at runtime
    "ConnectionStrings__WebTrax" = "@Microsoft.KeyVault(VaultName=${local.webapps.trackingapi.kv_name};SecretName=WebTrax-ConnectionString)"
    "ApiKeys__0"                 = "@Microsoft.KeyVault(VaultName=${local.webapps.trackingapi.kv_name};SecretName=ApiKey-0)"
    "ApiKeys__1"                 = "@Microsoft.KeyVault(VaultName=${local.webapps.trackingapi.kv_name};SecretName=ApiKey-1)"
    "ApiKeys__2"                 = "@Microsoft.KeyVault(VaultName=${local.webapps.trackingapi.kv_name};SecretName=ApiKey-2)"

    # Non-secret config — plain values from tfvars
    "SamApi__BaseUrl"        = var.sam_api_base_url
    "SamApi__DailyEndpoint"  = var.sam_api_daily_endpoint
    "SamApi__WeeklyEndpoint" = var.sam_api_weekly_endpoint
    "AppSettings__Timezone"  = var.app_timezone

    "WEBSITE_DNS_SERVER" = "168.63.129.16"
  }

  medicaappservice_app_settings = merge(
    {
      # ------------------------------------------------------------------
      # SECRETS — Key names match appsettings.json structure exactly
      # __ is the Azure App Service separator for nested JSON keys
      # ------------------------------------------------------------------
      # ConnectionStrings:WebTrax → ConnectionStrings__WebTrax
      "ConnectionStrings__WebTrax" = "@Microsoft.KeyVault(VaultName=${local.webapps.medicaappservice.kv_name};SecretName=Medica-ConnectionString)"
      # NasSettings:User / NasSettings:Password → credentials for NAS share access
      "NasSettings__User"          = "@Microsoft.KeyVault(VaultName=${local.webapps.medicaappservice.kv_name};SecretName=NAS-USER)"
      "NasSettings__Password"      = "@Microsoft.KeyVault(VaultName=${local.webapps.medicaappservice.kv_name};SecretName=NAS-PASSWORD)"

      # ------------------------------------------------------------------
      # NON-SENSITIVE — SMTP is an anonymous relay (no credentials needed)
      # SmtpSettings:Host / SmtpSettings:FromAddress
      # ------------------------------------------------------------------
      "SmtpSettings__Host"        = var.medica_smtp_host
      "SmtpSettings__FromAddress" = var.system_from_email

      # NasSettings:BaseUrl — plain URL, not a secret
      "NasSettings__BaseUrl" = var.medica_nas_base_url

      # ------------------------------------------------------------------
      # LOGGING — matches appsettings.json Logging section exactly
      # ------------------------------------------------------------------
      "Logging__LogLevel__Default"                    = "Information"
      "Logging__LogLevel__Microsoft"                  = "Warning"
      "Logging__LogLevel__Microsoft.Hosting.Lifetime" = "Information"
      "AllowedHosts"                                  = "*"

      # ------------------------------------------------------------------
      # AZURE APP SERVICE STANDARD SETTINGS
      # ------------------------------------------------------------------
      "ASPNETCORE_ENVIRONMENT"   = var.environment
      "WEBSITE_RUN_FROM_PACKAGE" = "1"
      "WEBSITE_DNS_SERVER"       = "168.63.129.16"
    },
    # ------------------------------------------------------------------
    # IMPORT SERVICE SETTINGS — flattened from map(map(string)) in tfvars
    # ImportServiceSettings::{Service}::{Field} → app setting key
    # Example: ImportServiceSettings__MellonPrenotes__DataPath
    # ------------------------------------------------------------------
    {
      for pair in flatten([
        for svc, fields in var.medica_import_service_settings : [
          for field, value in fields : {
            key   = "ImportServiceSettings__${svc}__${field}"
            value = value
          }
        ]
      ]) : pair.key => pair.value
    }
  )

  # -------------------------------------------------------
  # quantam webapp (ase-quantam-web-*) app settings
  # All secrets resolved from kv-qtmweb-centralus-{env} at runtime.
  # Connection strings use Azure App Service standard prefixes:
  #   SQLCONNSTR_*    → ConfigurationManager.ConnectionStrings[name] (System.Data.SqlClient)
  #   CUSTOMCONNSTR_* → ConfigurationManager.ConnectionStrings[name] (Custom / no providerName)
  # -------------------------------------------------------
  # -------------------------------------------------------
  # quantam connection strings — must use connection_string{} blocks,
  # NOT app_settings prefixes. Azure API rejects SQLCONNSTR_*/CUSTOMCONNSTR_*
  # in app_settings (HTTP 400 ExtendedCode 04072).
  # type="SQLServer"  → System.Data.SqlClient providerName
  # type="Custom"     → no providerName (CMCFacets, Agate, FCR-MIDAS)
  # -------------------------------------------------------
  quantam_connection_strings = [
    { name = "WebTraxConnectionString1",  type = "SQLServer", value = "@Microsoft.KeyVault(VaultName=${local.webapps.quantam.kv_name};SecretName=WebTrax-ConnectionString)" },
    { name = "WebTraxConnectionString2",  type = "SQLServer", value = "@Microsoft.KeyVault(VaultName=${local.webapps.quantam.kv_name};SecretName=WebTrax-ConnectionString)" },
    { name = "WebTraxDBConnectionString", type = "SQLServer", value = "@Microsoft.KeyVault(VaultName=${local.webapps.quantam.kv_name};SecretName=WebTrax-ConnectionString)" },
    { name = "LocalSqlServer",            type = "SQLServer", value = "@Microsoft.KeyVault(VaultName=${local.webapps.quantam.kv_name};SecretName=WebTrax-ConnectionString)" },
    { name = "Ifalls_UBH",               type = "SQLServer", value = "@Microsoft.KeyVault(VaultName=${local.webapps.quantam.kv_name};SecretName=Ifalls-UBH-ConnectionString)" },
    { name = "CMCFacets",                type = "Custom",    value = "@Microsoft.KeyVault(VaultName=${local.webapps.quantam.kv_name};SecretName=CMCFacets-ConnectionString)" },
    { name = "Agate",                    type = "Custom",    value = "@Microsoft.KeyVault(VaultName=${local.webapps.quantam.kv_name};SecretName=Agate-ConnectionString)" },
    { name = "FCR-MIDAS",                type = "Custom",    value = "@Microsoft.KeyVault(VaultName=${local.webapps.quantam.kv_name};SecretName=FCR-MIDAS-ConnectionString)" },
  ]

  quantam_app_settings = {
    # ------------------------------------------------------------------
    # SECRETS — resolved from Key Vault at runtime via managed identity
    # ------------------------------------------------------------------
    "SQL_Server"        = "@Microsoft.KeyVault(VaultName=${local.webapps.quantam.kv_name};SecretName=SQL-Server)"
    "TrackerUserKey"    = "@Microsoft.KeyVault(VaultName=${local.webapps.quantam.kv_name};SecretName=TrackerUserKey)"
    "IF_UBH"            = "@Microsoft.KeyVault(VaultName=${local.webapps.quantam.kv_name};SecretName=IF-UBH)"
    "NasUploadUsername" = "@Microsoft.KeyVault(VaultName=${local.webapps.quantam.kv_name};SecretName=NasUploadUsername)"
    "NasUploadPassword" = "@Microsoft.KeyVault(VaultName=${local.webapps.quantam.kv_name};SecretName=NasUploadPassword)"

    # ------------------------------------------------------------------
    # CUSTOM DOMAIN URLs — non-secret, managed via GitHub env vars
    # Set by keyvault.yaml (az webapp config appsettings set);
    # tfvars holds default app-service URL as fallback for Terraform.
    # ------------------------------------------------------------------
    "Quantam2.0Url"  = var.quantam2_0_url
    "TimeTrackerUri" = var.quantam_time_tracker_uri

    # ------------------------------------------------------------------
    # NON-SENSITIVE — plain values from tfvars (no KV round-trip needed)
    # ------------------------------------------------------------------
    "SSRS_WTX"             = var.quantam_ssrs_wtx
    "SSRS_Prod"            = var.quantam_ssrs_prod
    "OPS2URL"              = var.quantam_ops2_url
    "WTXDBEnviroment"      = var.quantam_wtxdb_environment
    "ChartImageHandler"    = var.quantam_chart_image_handler
    "DisableEmailEnv"      = var.quantam_disable_email_env
    "ErrorLogFallbackPath" = var.quantam_error_log_fallback_path
    "WEBSITE_DNS_SERVER"   = "168.63.129.16"
  }

  quantam_appservices_app_settings = merge(
    {
      # Connection strings
      "ConnectionStrings__WebTrax"            = "@Microsoft.KeyVault(VaultName=${local.webapps.quantam_appservices.kv_name};SecretName=WebTrax-ConnectionString)"
      "ConnectionStrings__WebTrax-Stage"      = "@Microsoft.KeyVault(VaultName=${local.webapps.quantam_appservices.kv_name};SecretName=WebTrax-Stage-ConnectionString)"
      "ConnectionStrings__Janus"              = "@Microsoft.KeyVault(VaultName=${local.webapps.quantam_appservices.kv_name};SecretName=Janus-ConnectionString)"
      "ConnectionStrings__Nice"               = "@Microsoft.KeyVault(VaultName=${local.webapps.quantam_appservices.kv_name};SecretName=Nice-ConnectionString)"
      "ConnectionStrings__Facets"             = "@Microsoft.KeyVault(VaultName=${local.webapps.quantam_appservices.kv_name};SecretName=Facets-ConnectionString)"
      "ConnectionStrings__SnowflakeHighmark"  = "@Microsoft.KeyVault(VaultName=${local.webapps.quantam_appservices.kv_name};SecretName=SnowflakeHighmark-ConnectionString)"
      "ConnectionStrings__SnoWFlake.Rsa_Key" = "@Microsoft.KeyVault(VaultName=${local.webapps.quantam_appservices.kv_name};SecretName=SnoWFlake-Rsa-Key)"

      # Sensitive app settings
      "AppSettings__NasUser"            = "@Microsoft.KeyVault(VaultName=${local.webapps.quantam_appservices.kv_name};SecretName=Nas-User)"
      "AppSettings__NasPassword"        = "@Microsoft.KeyVault(VaultName=${local.webapps.quantam_appservices.kv_name};SecretName=Nas-Password)"
      "AppSettings__NiceUsername"       = "@Microsoft.KeyVault(VaultName=${local.webapps.quantam_appservices.kv_name};SecretName=Nice-Username)"
      "AppSettings__NicePassword"       = "@Microsoft.KeyVault(VaultName=${local.webapps.quantam_appservices.kv_name};SecretName=Nice-Password)"
      "AppSettings__NiceBasicAuthToken" = "@Microsoft.KeyVault(VaultName=${local.webapps.quantam_appservices.kv_name};SecretName=Nice-Basic-Auth-Token)"

      # Common app settings
      "ASPNETCORE_ENVIRONMENT"                    = var.environment
      "Logging__LogLevel__Default"                = "Information"
      "Logging__LogLevel__Microsoft"              = "Warning"
      "Logging__LogLevel__Microsoft.Hosting.Lifetime" = "Information"
      "AllowedHosts"                              = "*"
      "WEBSITE_RUN_FROM_PACKAGE"                  = "1"
      "WEBSITE_DNS_SERVER"                        = "168.63.129.16"
    },
    {
      for k, v in var.quantam_appservices_app_settings : "AppSettings__${k}" => v
    }
  )

  webapp_app_settings = {
    for k, v in local.webapps : k => merge(
      {
        "APPINSIGHTS_INSTRUMENTATIONKEY"             = azurerm_application_insights.insights[k].instrumentation_key
        "APPLICATIONINSIGHTS_CONNECTION_STRING"      = azurerm_application_insights.insights[k].connection_string
        "ApplicationInsightsAgent_EXTENSION_VERSION" = "~2"
        "XDT_MicrosoftApplicationInsights_Mode"      = "default"
        "WEBSITE_RUN_FROM_PACKAGE"                   = "1"
      },
      k == "quantam2_0" ? local.quantam2_0_app_settings : {},
      k == "trackingapi"  ? local.trackingapi_app_settings   : {},
      k == "medicaappservice"  ? local.medicaappservice_app_settings   : {},
      k == "quantam"      ? local.quantam_app_settings        : {},
      k == "quantam_appservices" ? local.quantam_appservices_app_settings : {}
    )
  }
}

## ---------------------------------------------------------
## Existing VNet & Subnet (created via network module)
## ---------------------------------------------------------

data "azurerm_virtual_network" "my_uhg_azure_vnet" {
  name                = var.virtual_network_name
  resource_group_name = var.resource_group_name
}

data "azurerm_subnet" "uhg_azure_subnet" {
  name                 = var.subnet_name
  virtual_network_name = data.azurerm_virtual_network.my_uhg_azure_vnet.name
  resource_group_name  = var.resource_group_name 
}

## Private Endpoint subnet (no service delegation — required for PEP)
data "azurerm_subnet" "pep_subnet" {
  name                 = var.pep_subnet_name
  virtual_network_name = data.azurerm_virtual_network.my_uhg_azure_vnet.name
  resource_group_name  = var.resource_group_name
}

## =========================================================
## Windows Web App
## =========================================================

resource "azurerm_windows_web_app" "app" {
  for_each                      = local.webapps
  name                          = each.value.name
  location                      = var.location
  resource_group_name           = var.resource_group_name
  service_plan_id = azurerm_service_plan.asp.id
  #service_plan_id               = azurerm_service_plan.asp[each.key].id
  https_only                    = true
  client_certificate_enabled    = false
  #client_certificate_mode       = var.client_cert_mode
  public_network_access_enabled = true

  app_settings = local.webapp_app_settings[each.key]

  ## Connection strings — must be set via connection_string{} blocks, not app_settings.
  ## Azure rejects SQLCONNSTR_*/CUSTOMCONNSTR_* in app_settings (HTTP 400).
  dynamic "connection_string" {
    for_each = each.key == "quantam" ? local.quantam_connection_strings : []
    content {
      name  = connection_string.value.name
      type  = connection_string.value.type
      value = connection_string.value.value
    }
  }

  virtual_network_subnet_id = data.azurerm_subnet.uhg_azure_subnet.id
  #general settings
  site_config {
    always_on                     = true # in azure stack its off
    managed_pipeline_mode         = "Integrated"
    minimum_tls_version           = "1.2"
    http2_enabled                 = true
    ftps_state                    = "FtpsOnly"
    default_documents             = ["Default.htm", "Default.html", "Default.asp", "index.htm", "index.html", "iisstart.htm", "default.aspx", "index.php", "hostingstart.html"]
    use_32_bit_worker             = false
    vnet_route_all_enabled        = true
    ## WEBTRAX SECURITY (DISABLED FOR PHASE‑1)
    ip_restriction_default_action = "Deny"


    application_stack {
      current_stack  = each.key == "quantam2_0" ? "node"   : "dotnet"
      node_version   = each.key == "quantam2_0" ? "~20"    : null
      dotnet_version = contains(["medicaappservice", "trackingapi", "quantam_appservices"], each.key) ? "v8.0" : "v4.0"
    }

    #health_check_path                 = ""
    #health_check_eviction_time_in_min = 3

    
    ## -----------------------------------------------------
    ## WEBTRAX IP RESTRICTIONS – FULLY PRESERVED
    ## (COMMENTED for Quantam Phase‑1) // RE‑ENABLED FOR QUANTAM PHASE‑2
    ## -----------------------------------------------------
    dynamic "ip_restriction" {
      for_each = concat([{
        ## Allow outbound traffic from the Function App VNet integration subnet
        ip_address                = null
        name                      = "allow-function-app-vnet-subnet"
        priority                  = 100
        action                    = "Allow"
        headers                   = []
        service_tag               = null
        virtual_network_subnet_id = data.azurerm_subnet.uhg_azure_subnet.id
        },
        {
        ip_address                = "168.183.0.0/16"
        name                      = "deployment box-1"
        priority                  = 200
        action                    = "Allow"
        headers                   = []
        service_tag               = null
        virtual_network_subnet_id = null
        },
        {
          ip_address                = "149.111.0.0/16"
          name                      = "deployment box-2"
          priority                  = 201
          action                    = "Allow"
          headers                   = []
          service_tag               = null
          virtual_network_subnet_id = null
        },
        {
          ip_address                = "128.35.0.0/16"
          name                      = "deployment box-3"
          priority                  = 202
          action                    = "Allow"
          headers                   = []
          service_tag               = null
          virtual_network_subnet_id = null
        },
        {
          ip_address                = "161.249.0.0/16"
          name                      = "deployment box-4"
          priority                  = 203
          action                    = "Allow"
          headers                   = []
          service_tag               = null
          virtual_network_subnet_id = null
        },
        {
          ip_address                = "198.203.174.0/23"
          name                      = "deployment box-5"
          priority                  = 204
          action                    = "Allow"
          headers                   = []
          service_tag               = null
          virtual_network_subnet_id = null
        },
        {
          ip_address                = "198.203.176.0/22"
          name                      = "deployment box-6"
          priority                  = 205
          action                    = "Allow"
          headers                   = []
          service_tag               = null
          virtual_network_subnet_id = null
        },
        {
          ip_address                = "198.203.180.0/23"
          name                      = "deployment box-7"
          priority                  = 206
          action                    = "Allow"
          headers                   = []
          service_tag               = null
          virtual_network_subnet_id = null
        },
        {
          ip_address                = "20.115.181.64/29"
          name                      = "UHG-Windows-1"
          priority                  = 207
          action                    = "Allow"
          headers                   = []
          service_tag               = null
          virtual_network_subnet_id = null
        },
        {
          ip_address                = "20.22.7.88/29"
          name                      = "UHG-Windows-2"
          priority                  = 208
          action                    = "Allow"
          headers                   = []
          service_tag               = null
          virtual_network_subnet_id = null
        },
        {
          ip_address                = "20.252.122.0/29"
          name                      = "UHG-Windows-3"
          priority                  = 209
          action                    = "Allow"
          headers                   = []
          service_tag               = null
          virtual_network_subnet_id = null
        },
        {
          ip_address                = "20.94.108.224/29"
          name                      = "UHG-Windows-4"
          priority                  = 210
          action                    = "Allow"
          headers                   = []
          service_tag               = null
          virtual_network_subnet_id = null
        },
        # {
        #   ip_address                = null
        #   name                      = "vnet-bastion"
        #   priority                  = 101
        #   action                    = "Allow"
        #   headers                   = []
        #   service_tag               = null
        #   virtual_network_subnet_id = var.vnet_bastion_subnet_id
        # },
        {
          ip_address                = null
          name                      = "AzureAppServiceManagement"
          priority                  = 108
          action                    = "Allow"
          headers                   = []
          service_tag               = "AppServiceManagement"
          virtual_network_subnet_id = null
        }], local.zscaler_ip_restrictions)

      content {
        ip_address                = ip_restriction.value["ip_address"]
        name                      = ip_restriction.value["name"]
        priority                  = ip_restriction.value["priority"]
        action                    = ip_restriction.value["action"]
        headers                   = ip_restriction.value["headers"]
        service_tag               = ip_restriction.value["service_tag"]
        virtual_network_subnet_id = ip_restriction.value["virtual_network_subnet_id"]
      }
    }
    dynamic "scm_ip_restriction" {
      for_each = concat([{
        #  scm_ip_restriction = [{
        ip_address                = "168.183.0.0/16"
        name                      = "deployment box-1"
        priority                  = 300
        action                    = "Allow"
        headers                   = []
        service_tag               = null
        virtual_network_subnet_id = null
        },
        {
          ip_address                = "149.111.0.0/16"
          name                      = "deployment box-2"
          priority                  = 301
          action                    = "Allow"
          headers                   = []
          service_tag               = null
          virtual_network_subnet_id = null
        },
        {
          ip_address                = "128.35.0.0/16"
          name                      = "deployment box-3"
          priority                  = 302
          action                    = "Allow"
          headers                   = []
          service_tag               = null
          virtual_network_subnet_id = null
        },
        {
          ip_address                = "161.249.0.0/16"
          name                      = "deployment box-4"
          priority                  = 303
          action                    = "Allow"
          headers                   = []
          service_tag               = null
          virtual_network_subnet_id = null
        },
        {
          ip_address                = "198.203.174.0/23"
          name                      = "deployment box-5"
          priority                  = 304
          action                    = "Allow"
          headers                   = []
          service_tag               = null
          virtual_network_subnet_id = null
        },
        {
          ip_address                = "198.203.176.0/22"
          name                      = "deployment box-6"
          priority                  = 305
          action                    = "Allow"
          headers                   = []
          service_tag               = null
          virtual_network_subnet_id = null
        },
        {
          ip_address                = "198.203.180.0/23"
          name                      = "deployment box-7"
          priority                  = 306
          action                    = "Allow"
          headers                   = []
          service_tag               = null
          virtual_network_subnet_id = null
        },
        {
          ip_address                = "20.115.181.64/29"
          name                      = "UHG-Windows-1"
          priority                  = 307
          action                    = "Allow"
          headers                   = []
          service_tag               = null
          virtual_network_subnet_id = null
        },
        {
          ip_address                = "20.22.7.88/29"
          name                      = "UHG-Windows-2"
          priority                  = 308
          action                    = "Allow"
          headers                   = []
          service_tag               = null
          virtual_network_subnet_id = null
        },
        {
          ip_address                = "20.252.122.0/29"
          name                      = "UHG-Windows-3"
          priority                  = 309
          action                    = "Allow"
          headers                   = []
          service_tag               = null
          virtual_network_subnet_id = null
        },
        {
          ip_address                = "20.94.108.224/29"
          name                      = "UHG-Windows-4"
          priority                  = 310
          action                    = "Allow"
          headers                   = []
          service_tag               = null
          virtual_network_subnet_id = null
        },
        # {
        #   ip_address                = null
        #   name                      = "vnet-bastion"
        #   priority                  = 103
        #   action                    = "Allow"
        #   headers                   = []
        #   service_tag               = null
        #   virtual_network_subnet_id = var.vnet_bastion_subnet_id
        # },
      ], local.zscaler_scm_ip_restrictions)


      content {
        ip_address                = scm_ip_restriction.value["ip_address"]
        name                      = scm_ip_restriction.value["name"]
        priority                  = scm_ip_restriction.value["priority"]
        action                    = scm_ip_restriction.value["action"]
        headers                   = scm_ip_restriction.value["headers"]
        service_tag               = scm_ip_restriction.value["service_tag"]
        virtual_network_subnet_id = scm_ip_restriction.value["virtual_network_subnet_id"]
      }
    }
    
  }

  identity {
    type = "SystemAssigned"
  }

  lifecycle { 
    ignore_changes = [
      virtual_network_subnet_id,
      tags["hidden-link: /app-insights-resource-id"]
    ] 
  }

  tags = module.optum_tags.tags

  logs {
    application_logs {
      file_system_level = "Verbose"
    }
    detailed_error_messages = true
    failed_request_tracing  = true
    http_logs {
      file_system {
        retention_in_days = 30
        retention_in_mb   = 35
      }
    }
  }
}

## =========================================================
## Log Analytics & Application Insights
## =========================================================
#Log Analytics Workspace for logs to splunk
resource "azurerm_log_analytics_workspace" "workspace" {
  #name                = "app-insights-workspace"
  name                = var.analytics_workspace_name
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = module.optum_tags.tags
  sku               = "PerGB2018"
  retention_in_days = 30
}

resource "azurerm_application_insights" "insights" {
  for_each            = local.webapps
  name                = "${each.value.name}-appi"
  location            = var.location
  resource_group_name = var.resource_group_name
  application_type    = "web"
  workspace_id        = azurerm_log_analytics_workspace.workspace.id
  tags                = module.optum_tags.tags
}

data "azurerm_monitor_diagnostic_categories" "diagnostic_categories" {
  for_each   = azurerm_application_insights.insights
  resource_id = each.value.id
  # depends_on = [
  #   azurerm_log_analytics_workspace.workspace,
  #   azurerm_application_insights.insights
  # ]
}


## =========================================================
## WEBTRAX → QUANTAM
## Event Hub / Splunk diagnostics
## DISABLED FOR PHASE‑1 – ENABLED FOR PHASE‑2
## =========================================================</start>
data "azurerm_eventhub_namespace" "namespace" {
  name                = lookup({ tst = "lp-cl-centralus-eventhub-14b710f0", stg = "lp-cl-centralus-eventhub-14b710f0",prod = "" }, var.environment, "lp-cl-centralus-eventhub-14b710f0")
  resource_group_name = "lp-central-logging"
}


data "azurerm_eventhub_namespace_authorization_rule" "namespace_rule" {
  name                = "RootManageSharedAccessKey"
  resource_group_name = data.azurerm_eventhub_namespace.namespace.resource_group_name
  namespace_name      = data.azurerm_eventhub_namespace.namespace.name
}

resource "azurerm_monitor_diagnostic_setting" "diagnostics" {
  for_each                       = azurerm_application_insights.insights
  name                           = "diagnostic-setting-${each.key}"
  target_resource_id             = each.value.id
  log_analytics_workspace_id     = azurerm_log_analytics_workspace.workspace.id
  eventhub_name                  = "diagnostic-logs"
  eventhub_authorization_rule_id = data.azurerm_eventhub_namespace_authorization_rule.namespace_rule.id

  dynamic "enabled_log" {
    for_each = data.azurerm_monitor_diagnostic_categories.diagnostic_categories[each.key].log_category_types
    content {
      category = enabled_log.value
    }
  }
  # enabled_metric {
  #   category = "AllMetrics"
  # }

  metric {
    category = "AllMetrics"
    enabled  = false
  }
  lifecycle {
    ignore_changes = [enabled_log, metric]
  }
}

## =========================================================
## Private Endpoints — one per web app
## Uses the centralized Private DNS Zone for App Service:
##   privatelink.azurewebsites.net
##   /subscriptions/9458f9de-55ca-4777-ae7d-353b870f5b27/
##     resourceGroups/dns-hub-private-zones-prod/...
## =========================================================

resource "azurerm_private_endpoint" "webapp" {
 for_each            = local.webapps
 name                = replace(each.value.name, "ase-", "pep-")
 location            = var.location
 resource_group_name = var.resource_group_name
 ## Must use the PEP subnet — no service delegation allowed on this subnet
 subnet_id           = data.azurerm_subnet.pep_subnet.id

 private_service_connection {
   name                           = replace(each.value.name, "ase-", "psc-")
   private_connection_resource_id = azurerm_windows_web_app.app[each.key].id
   is_manual_connection           = false
   subresource_names              = ["sites"]
 }

  ## Team-managed Private DNS Zone — registers the private endpoint A record so the
  ## spoke VNet resolves webapp FQDNs to the private IP via azurerm_private_dns_zone.webapp_dns.
 private_dns_zone_group {
   name = replace(each.value.name, "ase-", "pdz-")
   private_dns_zone_ids = [
     data.azurerm_private_dns_zone.webapp_dns.id
   ]
 }

 depends_on = [
   azurerm_windows_web_app.app,
   azurerm_private_dns_zone_virtual_network_link.webapp_dns_link
 ]

 tags = module.optum_tags.tags
}

#resource "azurerm_app_service_custom_hostname_binding" "quantamtest" {
#  hostname            = var.custom_hostname
#  app_service_name    = azurerm_windows_web_app.app["quantam"].name
#  resource_group_name = var.resource_group_name
#
#  depends_on = [azurerm_private_endpoint.webapp]
#}

#----------------------------------------------#
#kv config
resource "azurerm_key_vault" "webapp_key_vault" {
  for_each                        = local.webapps
  name                            = each.value.kv_name
  location                        = var.location
  resource_group_name             = var.resource_group_name
  tags                            = module.optum_tags.tags
  # enabled_for_deployment          = true
  # enabled_for_template_deployment = true
  # enabled_for_disk_encryption     = true
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

resource "azurerm_role_assignment" "webapp_kv_access" {
  for_each             = local.webapps
  scope                = azurerm_key_vault.webapp_key_vault[each.key].id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_windows_web_app.app[each.key].identity[0].principal_id
}

# resource "azurerm_role_assignment" "human_kv_access" {
#   scope                = azurerm_key_vault.webapp_key_vault["quantam"].id
#   role_definition_name = "Key Vault Secrets Officer"
#   principal_id         = "d9af27ee-3ee7-491f-9272-ae7a3ae063df"
# }

resource "azurerm_role_assignment" "human_kv_access" {
  for_each             = azurerm_key_vault.webapp_key_vault
  scope                = each.value.id
  role_definition_name = "Key Vault Secrets Officer"
  principal_id         = "d9af27ee-3ee7-491f-9272-ae7a3ae063df"
}

resource "azurerm_role_assignment" "human_kv_secrets_user" {
  for_each             = azurerm_key_vault.webapp_key_vault
  scope                = each.value.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = "d9af27ee-3ee7-491f-9272-ae7a3ae063df"
}


/*resource "azurerm_role_assignment" "jit_kv_access" {
  for_each             = local.webapps
  scope                = azurerm_key_vault.webapp_key_vault[each.key].id
  role_definition_name = "Key Vault Administrator"
  principal_id         = "d9af27ee-3ee7-491f-9272-ae7a3ae063df"
}*/

## Team-managed Private DNS Zone for App Service private endpoints
## Required so the spoke VNet can resolve webapp FQDNs to the private endpoint IP.
## This follows the same pattern as the KV DNS zone below.
## Subscription-scoped DNS zones are owned by network/dns module.
## 'removed' blocks evict TST-owned state entries without destroying in Azure.
## Safe to remove these blocks after TST + STG have both applied successfully.

data "azurerm_private_dns_zone" "webapp_dns" {
  name                = "privatelink.azurewebsites.net"
  resource_group_name = var.resource_group_name
}

data "azurerm_private_dns_zone" "kv_dns" {
  name                = "privatelink.vaultcore.azure.net"
  resource_group_name = var.resource_group_name
}

resource "azurerm_private_dns_zone_virtual_network_link" "webapp_dns_link" {
  name                  = "webapp-dns-link-${var.environment}"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = data.azurerm_private_dns_zone.webapp_dns.name
  virtual_network_id    = data.azurerm_virtual_network.my_uhg_azure_vnet.id
  lifecycle { ignore_changes = [tags] }
}

resource "azurerm_private_dns_zone_virtual_network_link" "kv_dns_link" {
  name                  = "kv-dns-link-${var.environment}"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = data.azurerm_private_dns_zone.kv_dns.name
  virtual_network_id    = data.azurerm_virtual_network.my_uhg_azure_vnet.id
  lifecycle { ignore_changes = [tags] }
}


resource "azurerm_private_endpoint" "kv_pe" {
  for_each            = local.webapps
  name                = "${each.value.name}-kv-pe"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = data.azurerm_subnet.pep_subnet.id

  private_service_connection {
    name                           = "${each.value.name}-kv-psc"
    private_connection_resource_id = azurerm_key_vault.webapp_key_vault[each.key].id
    subresource_names              = ["vault"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "${each.value.name}-dns-group"
    private_dns_zone_ids = [data.azurerm_private_dns_zone.kv_dns.id]
  }

  lifecycle { ignore_changes = [tags] }
}
