
variable "resource_group_name" {
  type = string
  default = "pc-managed-networking"
}

variable "networking_resource_group_name" {
  description = "Resource group where shared networking resources (DNS zones, VNet) live"
  type        = string
  default     = "pc-managed-networking"
}

variable "namespace" {
  type = string
}

variable "oauth_client_id" {
  type = string
}

variable "oauth_client_secret" {
  type = string
}

variable "subscription_id" {
  description = "Azure subscription ID"
  type        = string
}

variable "private_subnet" {
  description = "Private endpoint subnet details"
  type = object({
    name                 = string
    resource_group_name  = string
    virtual_network_name = string
  })
}

variable "vnet_integration_subnet" {
  description = "Subnet for VNet integration"
  type = object({
    name                 = string
    resource_group_name  = string
    virtual_network_name = string
  })
}


# variable "location" {
#   type = string
# }

variable "function_apps" {
  description = "Map of function apps configuration"

  type = map(object({
    function_app = object({
      name = string

      application_stack = optional(object({
        dotnet_version = optional(string)
        node_version   = optional(string)
        java_version   = optional(string)
        python_version = optional(string)
      }), {})
    })

    app_settings = optional(map(string), {})

    app_service_plan = object({
      name              = string
      sku_name          = string
      os_type           = string
      autoscale_profile = any
    })

    storage_account = object({
      name_prefix               = string
      shared_access_key_enabled = bool
    })

# Uncomment this, if functions bindings needed
#    functions = list(object({
#      name        = string
#      config_json = string

#      enabled   = optional(bool, true)
#      language  = optional(string)
#      test_data = optional(string)

#      file = optional(object({
#        name    = string
#        content = string
#      }))
#    }))

    slots = list(object({
      name = string
    }))

    site_config = optional(object({
      minimum_tls_version       = optional(string, "1.2")
      http2_enabled             = optional(bool, true)
      ftps_state                = optional(string, "FtpsOnly")
      remote_debugging_enabled  = optional(bool, false)
      use_32_bit_worker_process = optional(bool, false)
    }), {})
  }))

  #  Runtime validation
  validation {
    condition = alltrue([
      for app in values(var.function_apps) :
      length(compact([
        try(app.function_app.application_stack.dotnet_version, null),
        try(app.function_app.application_stack.node_version, null),
        try(app.function_app.application_stack.python_version, null),
        try(app.function_app.application_stack.java_version, null)
      ])) == 1
    ])

    error_message = "Each function app must define exactly ONE runtime."
  }

  #  Storage name validation
  validation {
    condition = alltrue([
      for app in values(var.function_apps) :
      length(app.storage_account.name_prefix) <= 20
    ])

    error_message = "Storage account prefix must be <= 20 characters."
  }

  #  OS validation
  validation {
    condition = alltrue([
      for app in values(var.function_apps) :
      contains(["Windows", "Linux"], app.app_service_plan.os_type)
    ])

    error_message = "os_type must be either Windows or Linux."
  }
}

variable "analytics_workspace_name" {
  description = "Name of the existing Log Analytics workspace"
  type        = string
}