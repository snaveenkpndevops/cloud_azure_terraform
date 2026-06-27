variable "namespace" {
  type = string
}

variable "location" {
  type = string
}

variable "subscription_id" {
  type = string
}

# variable "oauth_client_id" {
#   type = string
# }

# variable "oauth_client_secret" {
#   type      = string
#   sensitive = true
# }

variable "resource_groups" {
  type = map(object({
    name = string
    tags = map(string)
  }))
  default = {}
}