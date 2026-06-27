# data azurerm_virtual_network "my_uhg_azure_vnet" {
#   name                = var.virtual_network_name
#   resource_group_name = var.managed_resource_group_name
# }

# data "azurerm_subnet" "adf_subnet" {
#   name                 = var.subnet_name
#   virtual_network_name = data.azurerm_virtual_network.my_uhg_azure_vnet.name
#   resource_group_name  = var.managed_resource_group_name

# }

# resource "azurerm_network_interface" "main" {       // Network interface for vm using subnet which is created above.
#   name                        = var.vm_nic_name
#   resource_group_name         = data.azurerm_resource_group.quantam.name
#   location                    = var.location

#   ip_configuration {
#     name                          = var.ip_nic_name
#     subnet_id                     = data.azurerm_subnet.adf_subnet.id
#     private_ip_address_allocation = "Dynamic"
#   }
#   tags     = module.optum_tags.tags
# }

# data "azurerm_shared_image_version" "ir_vm" {   // Here we will pull the image version.
#   #name                = "2025.08.25" 
#   name                = "latest"                        // Version of Golden Image
#   image_name          = "Windows_2022_G2"                         // Type of Golden Image
#   gallery_name        = "prod_golden_image_azu_gallery"
#   resource_group_name = "prod_golden_image_azu_gallery"
#   provider            = azurerm.HCC_Azure_GoldenImages
# }


# resource "azurerm_windows_virtual_machine" "windows-vm" {
#   name                        = var.vm_name
#   bypass_platform_safety_checks_on_user_schedule_enabled = true
#   resource_group_name         = data.azurerm_resource_group.quantam.name
#   location                    = var.location
#   tags                        = module.optum_tags.tags
#   enable_automatic_updates    = true
#   allow_extension_operations  = true
#   hotpatching_enabled         = false
#   size                        = "Standard_D4as_v5"
#   admin_username              = var.vm_admin_user
#   admin_password              = var.vm_admin_password
#   network_interface_ids       = [azurerm_network_interface.main.id]


#   os_disk {
#     caching                   = "ReadWrite"
#     storage_account_type      = "Standard_LRS"
#      disk_size_gb             = 128
#   }

#   identity {
#     type                      = "SystemAssigned"
#   }



# source_image_id               = data.azurerm_shared_image_version.ir_vm.id

# lifecycle {
#     prevent_destroy = true   # prevents accidental VM deletion
#     ignore_changes = [       # optional: stop TF from forcing a recreate on benign changes
#       #source_image_id,       # image version bumps (if you don’t want forced replace)
#       os_disk,               # size/type mismatches if you don’t intend to change
#     ]
#   }
# }

 
