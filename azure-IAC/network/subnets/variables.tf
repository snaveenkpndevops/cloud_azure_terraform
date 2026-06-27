variable "namespace" {
  type = string
}

variable "location" {
  type = string
}

variable "virtual_network_name" {
  default = ""
}

variable "resource_group_name" {
  default = ""
}
###########################################################################################################
#Konwn issue: Vnet CIRD will be assigned during terraform apply and module subnet expects CIDR cannot be left empty 
#Hence, Decouple the configuration of the Virtual Network from its subnets and manage them through separate deployment processes.
#so comment the subnet module,variable and vars create the Vnet and then uncomment the subnet module,variable and vars to create subnets with assigned CIDR from Vnet deployment.


variable "subscription_id" {
  description = "Azure subscription ID"
  type        = string
}


variable "oauth_client_id" {
  type = string
}
variable "oauth_client_secret" {
  type = string
}

variable "nextgen_subnets" {
  description = "NextGen Subnet configurations"
  type = map(object({
    name           = string
    address_prefix = string
    metadata = object({
      uhg_resource_group = string
    })
    network_security_rules = optional(list(object({
      name                         = string
      access                       = string
      direction                    = string
      priority                     = number
      protocol                     = string
      source_address_prefix        = optional(string)
      source_address_prefixes      = optional(list(string))
      source_port_range            = optional(string)
      source_port_ranges           = optional(list(string))
      destination_address_prefix   = optional(string)
      destination_address_prefixes = optional(list(string))
      destination_port_range       = optional(string)
      destination_port_ranges      = optional(list(string))
    })), [])
    service_delegation = optional(object({
      name    = string
      actions = optional(list(string))
    }))
    timeouts = optional(object({
      create = optional(string, "60m")
      update = optional(string, "60m")
      delete = optional(string, "60m")
    }))
  }))
  default = {}
}