#common
variable "location" {}

variable "environment" {
  type = string
}


#adf
variable "tenant" {
  type    = string
  default = "ecp"

}

# variable "create_adf_key_vault" {
#   type    = bool
#   default = true

# }
variable "sqlmi_endpoint" {
  type = string
}
variable "sqlmi_admin_login" {
  type = string
}
variable "sqlmi_admin_password" {
  type = string
}
variable "virtual_network_name" {
  default = ""
}

variable "resource_group_name" {
  default = ""
}

variable "azure_resource_group_name" {
  default = ""
}

variable "managed_resource_group_name" {
  default = ""
}

variable "subnet_name" {
  default = ""
}

variable "pep_subnet_name" {
  default = ""
}

variable "logicapp_subnet_name" {
  type        = string
  description = "Subnet name for Logic App Standard VNet integration."
  default     = ""
}

variable "managed_private_endpoint" {
  description = "Boolean to create the managed private endpoint to snowflake"
  type        = bool
  default     = true
}

variable "kv_reader_role_name" {
  type        = string
  description = "The role definition ID for Key Vault Reader role."
  default     = null
}

variable "adf_kv_ip_addresses" {
  type        = list(string)
  description = "The IP addresses allowed to access the ADF Key Vault."
  default     = ["6.56.104.0/21", "198.203.174.0/23", "149.111.0.0/16", "198.203.176.0/22", "168.183.0.0/16", "161.249.0.0/16", "6.53.216.0/21", "198.203.180.0/23", "128.35.0.0/16", "6.55.8.0/21"]
}

# variable "adf_kv_subnet_ids" {
#   type        = list(string)
#   description = "The subnet IDs allowed to access the ADF Key Vault."
#   default     = []
# }

variable "subscription_id" {
  type        = string
  default = ""
}

variable "private_dns_zone_blob_id" {
  type        = string
  description = "Private DNS zone ID for blob private endpoints."
  default     = ""
}

variable "private_dns_zone_sites_id" {
  type        = string
  description = "Private DNS zone ID for App Service or Logic App private endpoints."
  default     = ""
}
#############################VM########################
 