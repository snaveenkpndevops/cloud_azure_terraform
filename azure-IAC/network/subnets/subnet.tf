

# ##########################################################################################################
# Konwn issue: Vnet CIRD will be assigned during terraform apply and module subnet expects CIDR 
#Hence, Decouple the configuration of the Virtual Network from its subnets and manage them through separate deployment processes.

data "azurerm_subscription" "current" {}

data azurerm_virtual_network "my_uhg_azure_vnet" {
  name                = var.virtual_network_name
  resource_group_name = var.resource_group_name
}

module "rcm_udp_nextgen_subnets" {
  for_each = var.nextgen_subnets
  # Go to https://github.com/dojo360/uhg-azure-network/releases for the latest version.
  source = "git::https://github.com/dojo360/uhg-azure-network//profiles/azure-subnet-v1?ref=v112.0.3"

  name           = each.value.name
  address_prefix = each.value.address_prefix
  metadata       = each.value.metadata

  # Reference the VNet created in the previous step
  # Using the first location from the locations list
  virtual_network = {
    name = data.azurerm_virtual_network.my_uhg_azure_vnet.name
    # resource_group_name is now optional (defaults to pc-managed-networking)
  }

  network_security_rules = lookup(each.value, "network_security_rules", [])

  # Optional service delegation
  service_delegation = lookup(each.value, "service_delegation", null)

  # Timeouts
  timeouts = lookup(each.value, "timeouts", {
    create = "60m"
    update = "60m"
    delete = "60m"
  })
}
