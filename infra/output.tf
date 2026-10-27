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

output "docs_storage_account" {
  value = azurerm_storage_account.docs.name
}

output "key_vault_name" {
  value = azurerm_key_vault.main.name
}

output "key_vault_uri" {
  value = azurerm_key_vault.main.vault_uri
}
