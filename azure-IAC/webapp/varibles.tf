variable "location" {
  type        = string
  description = "The location to deploy resources to."
}

variable "environment" {
  type        = string
  description = "The name of the environment that is being deployed."
}


variable "namespace" {
  type = string
}

variable "analytics_workspace_name" {
  type        = string
  description = "Name of analytics workspace"
}

variable "app_insights_name" {
  type        = string
  description = "Name of app insights service"
}

# variable "health_check_path" {
#   type        = string
#   description = "The health check path of the app service"
#   default     = "/api/v1/status"
# }


# variable "vnet_private_endpoint_subnet" {
#   type        = string
#   description = "private endpoint needs to be on a seperate subnet that has no delegations"
# }


# variable "virtual_network_main_resource_group" {
#   type        = string
#   description = "virtual network main resource group"
# }

# variable "azurerm_private_dns_zone_name" {
#   type        = string
#   description = "azurerm private dns zone name"
# }

# variable "azurerm_private_dns_zone_id" {
#   type        = string
#   description = "azurerm private dns zone name"
# }

# Key Vault app service certificate name
# variable "app_cert_name" {
#   type        = string
#   description = "The name of the app service certificate to be stored in Azure Key Vault"
#   default     = ""
# }

# variable "app_custom_dns" {
#   type        = string
#   description = "Custom DNS Host Name for webtrax web app service"
# }

variable "client_cert_mode" {
  description = "Client certificate mode"
  type        = string
  default     = "Ignore"
}


variable "virtual_network_name" {
    default = ""
}
variable "subnet_name" {
  default = ""
}

variable "pep_subnet_name" {
  type        = string
  description = "Name of the dedicated private endpoint subnet (no service delegation)"
  default     = "snet-quantam-pep-centralus-tst"
}

#variable "custom_hostname" {
#  type        = string
#  description = "Custom hostname to bind to the quantam web app (e.g. quantamtest-cloud.optum.com)"
#  default     = ""
#}
variable "subscription_id" {
 default = "" 
}

variable "zscaler_ips" {
  description = "IP ranges of Zscaler Public Addresses"
  default = [
    "8.25.203.0/24",
    "64.74.126.64/26",
    "70.39.159.0/24",
    "72.52.96.0/26",
    "89.167.131.0/24",
    "104.129.192.0/20",
    "112.196.99.180/30",
    "136.226.0.0/16",
    "137.83.128.0/18",
    "147.161.128.0/17",
    "165.225.0.0/17",
    "165.225.192.0/18",
    "167.103.0.0/16",
    "170.85.0.0/16",
    "185.46.212.0/22",
    "199.168.148.0/22",
    "213.152.228.0/24",
    "216.52.207.64/26",
    "216.218.133.192/26"
  ]
}

variable "resource_group_name" {
  type = string
  default = "pc-managed-networking"
}

variable "sku_capacity_default" {
  type        = string
  description = "Plan capacity"
}


# variable "app_service_environment_id" {
#   type        = string
#   description = "App Service Environment id"
#   default     = null
# }


variable "sku_size" {
  type        = string
  description = "sku tier"
}

variable "adf_kv_ip_addresses" {
  type        = list(string)
  description = "The IP addresses allowed to access the ADF Key Vault."

  default = [
    # Existing CIDR ranges
    "6.56.104.0/21",
    "198.203.174.0/23",
    "149.111.0.0/16",
    "198.203.176.0/22",
    "168.183.0.0/16",
    "161.249.0.0/16",
    "6.53.216.0/21",
    "198.203.180.0/23",
    "128.35.0.0/16",
    "6.55.8.0/21",
  ]
}

variable "quantam2_0_prod_url" {
  type        = string
  description = "Public URL of the quantam-2-0 production webapp"
}

variable "quantam2_0_stage_url" {
  type        = string
  description = "Public URL of the quantam-2-0 stage webapp"
}

variable "quantam2_0_test_url" {
  type        = string
  description = "Public URL of the quantam-2-0 test webapp"
}

variable "system_from_email" {
  type        = string
  description = "System from-address for Quantam notification emails"
}

variable "sam_api_base_url" {
  type        = string
  description = "SAM API base URL for the trackingapi"
}

variable "sam_api_daily_endpoint" {
  type        = string
  description = "SAM API daily report endpoint path"
}

variable "sam_api_weekly_endpoint" {
  type        = string
  description = "SAM API weekly report endpoint path"
}

variable "app_timezone" {
  type        = string
  description = "Timezone string for the trackingapi (e.g. Central Standard Time)"
  default     = "Central Standard Time"
}

# -------------------------------------------------------
# quantam-web non-sensitive app settings (plain values — no KV)
# -------------------------------------------------------
variable "quantam_ssrs_wtx" {
  type        = string
  description = "SSRS report server URL for the current environment"
  default     = ""
}

variable "quantam_ssrs_prod" {
  type        = string
  description = "SSRS report server URL for production"
  default     = ""
}

variable "quantam_ops2_url" {
  type        = string
  description = "OPS2 base URL for redirects"
  default     = ""
}

variable "quantam_wtxdb_environment" {
  type        = string
  description = "Display name shown on the login page banner (e.g. 'WebTrax Test Server')"
  default     = ""
}

variable "quantam_chart_image_handler" {
  type        = string
  description = "Chart image handler config string"
  default     = "storage=file;timeout=20;"
}

variable "quantam2_0_url" {
  type        = string
  description = "Quantam 2.0 webapp URL — default app-service URL; overridden by keyvault.yaml GitHub env var for custom domain"
  default     = ""
}

variable "quantam_disable_email_env" {
  type        = string
  description = "Environment name used to suppress real emails in non-prod (e.g. 'stage')"
  default     = ""
}

variable "quantam_time_tracker_uri" {
  type        = string
  description = "Tracking API base URI — default app-service URL; overridden by keyvault.yaml GitHub env var for custom domain"
  default     = ""
}

variable "quantam_error_log_fallback_path" {
  type        = string
  description = "Fallback file/UNC path for error log writes when DB is unavailable"
  default     = ""
}

variable "medica_smtp_host" {
  type        = string
  description = "SMTP relay host for medicaappservice — SmtpSettings:Host in appsettings.json"
  default     = ""
}

variable "medica_nas_base_url" {
  type        = string
  description = "NAS base URL for medicaappservice — NasSettings:BaseUrl in appsettings.json"
  default     = ""
}

variable "medica_import_service_settings" {
  description = <<-EOT
    ImportServiceSettings per service — flattened into Azure App Service app settings.
    Key = service name (e.g. MellonPrenotes), value = map of field → value.
    Fields: Recipients, Support, DataPath, ArchivePath (service-dependent).
    Produces app settings: ImportServiceSettings__{Service}__{Field}
  EOT
  type    = map(map(string))
  default = {}
}

variable "quantam_appservices_app_settings" {
  description = <<-EOT
    Non-sensitive AppSettings values for quantamserviceapis.
    Entries are flattened as AppSettings__{Key} in Azure App Service.
    Sensitive values and connection strings are sourced from Key Vault references.
  EOT
  type    = map(string)
  default = {}
}

variable "storage_accounts" {
  description = <<-EOT
    Map of storage accounts to deploy alongside the webapp.
    Key is the logical identifier (must match webapp map keys for webapp_access).

    shared_access_key_enabled: true when app needs a connection string or file shares.
    endpoint_service_types: list of blob/file/table/queue.
    containers: blob containers. access_type defaults to "private".
    shares: file shares. quota in GB. requires shared_access_key_enabled = true.
    webapp_access: list of webapp map keys (quantam2_0, quantam, trackingapi, medicaappservice)
                   to grant Storage Blob Data Contributor RBAC.
  EOT

  type = map(object({
    name                      = string
    shared_access_key_enabled = optional(bool, false)
    endpoint_service_types    = optional(list(string), ["blob"])

    containers = optional(list(object({
      name        = string
      access_type = optional(string, "private")
    })), [])

    shares = optional(list(object({
      name  = string
      quota = number
    })), [])

    webapp_access = optional(list(string), [])
  }))

  default = {}
}
