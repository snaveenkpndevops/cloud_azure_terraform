
variable "oauth_client_id" {
  type = string
}
variable "oauth_client_secret" {
  type = string
}

variable "namespace" {
  type = string
}

variable "location" {
  type = string
}

variable "virtual_network" {
  default = {
    name = ""
    metadata = {
      azure_subscription_name = ""
      uhg_resource_group      = ""
    }
  }
}
variable "subscription_id" {
  description = "Azure subscription ID"
  type        = string
}