module "my_uhg_azure_vnet" {
  # Go to https://github.com/dojo360/uhg-azure-network/releases for the latest version.
  # source    = "git::https://github.com/dojo360/uhg-azure-network//profiles/azure-virtual-network-v1?ref=v114.1.1"
  source    = "git::https://github.com/dojo360/uhg-azure-network//profiles/azure-virtual-network-v1?ref=v112.0.3"
  name      = var.virtual_network.name
  namespace = var.namespace
  location  = var.location

  metadata = {
    azure_subscription_name = var.virtual_network.metadata.azure_subscription_name
    uhg_resource_group      = var.virtual_network.metadata.uhg_resource_group
  }
}
