namespace = "tst"
location = "centralus"
virtual_network_name = "pcm-network-cus-quantam-vnet-tst"
resource_group_name = "pc-managed-networking"
subscription_id = "14b710f0-0020-4b63-887d-22a232c0324c"

###########################################################################################################
#Konwn issue: Vnet CIRD will be assigned during terraform apply and module subnet expects CIDR cannot be left empty 
#Hence, Decouple the configuration of the Virtual Network from its subnets and manage them through separate deployment processes.
#so comment the subnet module,variable and vars create the Vnet and then uncomment the subnet module,variable and vars to create subnets with assigned CIDR from Vnet deployment.

nextgen_subnets = {
  pep = {
    name           = "snet-quantam-pep-centralus-tst"
    address_prefix = "6.76.185.0/25" # Update with your desired CIDR block
    metadata = {
      uhg_resource_group = "quantam-cloud-c7ffa72" ## Must match VNet metadata ref apply
    }
    network_security_rules = [
      {
        name                       = "allow-https-inbound"
        access                     = "Allow"
        direction                  = "Inbound"
        priority                   = 200
        protocol                   = "Tcp"
        source_address_prefix      = "VirtualNetwork"
        source_port_range          = "443"
        destination_address_prefix = "VirtualNetwork"
        destination_port_range     = "443"
      },
      {
        name                       = "allow-https-outbound"
        access                     = "Allow"
        direction                  = "Outbound"
        priority                   = 201
        protocol                   = "Tcp"
        source_address_prefix      = "VirtualNetwork"
        source_port_range          = "*"
        destination_address_prefix = "*"
        destination_port_range     = "443"
      }
    ]
    timeouts = {
      create = "60m"
      update = "60m"
      delete = "60m"
    }
  }

  webapp = {
    name           = "snet-quantam-app-centralus-tst"
    address_prefix = "6.76.185.128/25" # Update with your desired CIDR block
    metadata = {
      uhg_resource_group = "quantam-cloud-c7ffa72" # Must match VNet metadata
    }
    network_security_rules = [
      {
        name                       = "allow-https-inbound"
        access                     = "Allow"
        direction                  = "Inbound"
        priority                   = 200
        protocol                   = "Tcp"
        source_address_prefix      = "VirtualNetwork"
        source_port_range          = "443"
        destination_address_prefix = "VirtualNetwork"
        destination_port_range     = "443"
      },
      {
        name                       = "allow-https-outbound"
        access                     = "Allow"
        direction                  = "Outbound"
        priority                   = 201
        protocol                   = "Tcp"
        source_address_prefix      = "VirtualNetwork"
        source_port_range          = "*"
        destination_address_prefix = "*"
        destination_port_range     = "443"
      }
    ]
    service_delegation = {
      name = "Microsoft.Web/serverFarms"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/action",
        "Microsoft.Network/virtualNetworks/subnets/join/action",
        "Microsoft.Network/virtualNetworks/subnets/prepareNetworkPolicies/action",
        "Microsoft.Network/virtualNetworks/subnets/unprepareNetworkPolicies/action"
      ]
    }
    timeouts = {
      create = "60m"
      update = "60m"
      delete = "60m"
    }
  }

  db = {
    name           = "snet-quantam-db-centralus-tst"
    address_prefix = "6.76.186.0/25" # Update with your desired CIDR block 
    metadata = {
      uhg_resource_group = "quantam-cloud-c7ffa72" # Must match VNet metadata
    }
    network_security_rules = [
      {
        name                       = "allow-sql-inbound"
        access                     = "Allow"
        direction                  = "Inbound"
        priority                   = 200
        protocol                   = "Tcp"
        source_address_prefix      = "VirtualNetwork"
        source_port_range          = "1433"
        destination_address_prefix = "VirtualNetwork"
        destination_port_range     = "1433"
      },
      {
        name                       = "allow-sql-outbound"
        access                     = "Allow"
        direction                  = "Outbound"
        priority                   = 201
        protocol                   = "Tcp"
        source_address_prefix      = "VirtualNetwork"
        source_port_range          = "1433"
        destination_address_prefix = "VirtualNetwork"
        destination_port_range     = "1433"
      }
    ]

    service_delegation = {
      name = "Microsoft.Sql/managedInstances"
      actions = [
        "Microsoft.Network/networkinterfaces/*",
        "Microsoft.Network/virtualNetworks/read",
        "Microsoft.Network/virtualNetworks/subnets/join/action",
        "Microsoft.Network/virtualNetworks/subnets/prepareNetworkPolicies/action",
        "Microsoft.Network/virtualNetworks/subnets/unprepareNetworkPolicies/action"
      ]
    }

    timeouts = {
      create = "60m"
      update = "60m"
      delete = "60m"
    }
  }


  adf = {
    name           = "snet-quantam-adf-centralus-tst"
    address_prefix = "6.76.186.128/25" # Update with your desired CIDR block
    metadata = {
      uhg_resource_group = "quantam-cloud-c7ffa72" ## Must match VNet metadata ref apply
    }
    network_security_rules = [
      {
        name                       = "allow-ssis-ir-inbound"
        access                     = "Allow"
        direction                  = "Inbound"
        priority                   = 240
        protocol                   = "Tcp"
        source_address_prefix      = "AzureCloud"
        source_port_range          = "*"
        destination_address_prefix = "VirtualNetwork"
        destination_port_range     = "29876-29877"
      },
      {
        name                       = "allow-ssis-ir-https-inbound"
        access                     = "Allow"
        direction                  = "Inbound"
        priority                   = 250
        protocol                   = "Tcp"
        source_address_prefix      = "AzureCloud"
        source_port_range          = "*"
        destination_address_prefix = "*"
        destination_port_range     = "443"
      },
      {
        name                       = "allow-ssis-ir-adf-outbound"
        access                     = "Allow"
        direction                  = "Outbound"
        priority                   = 260
        protocol                   = "Tcp"
        source_address_prefix      = "VirtualNetwork"
        source_port_range          = "*"
        destination_address_prefix = "DataFactoryManagement"
        destination_port_range     = "443"
      }
    ]
    service_delegation = {
      name = "Microsoft.Batch/batchAccounts"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/action"
      ]
    }
    timeouts = {
      create = "60m"
      update = "60m"
      delete = "60m"
    }
  }
}
 
