resource "azurerm_resource_group" "this" {
  for_each = var.resource_groups

  name     = each.value.name
  location = var.location
  tags     = each.value.tags
}