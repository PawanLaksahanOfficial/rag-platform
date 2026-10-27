output "resource_group_name" {
  value = azurerm_resource_group.main.name
}

output "suffix" {
  value = random_string.suffix.result
}

output "vnet_id" {
  value = azurerm_virtual_network.main.id
}

output "aks_subnet_id" {
  value = azurerm_subnet.aks.id
}
