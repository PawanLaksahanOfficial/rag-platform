data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "main" {
  #checkov:skip=CKV_AZURE_189:Accepted risk until private networking, see issue 8. Access still needs Entra ID and RBAC.
  #checkov:skip=CKV_AZURE_109:Accepted risk until private networking, see issue 8. The firewall comes with the private endpoint.
  #checkov:skip=CKV2_AZURE_32:Accepted risk until private networking, see issue 8.
  name                          = "kv-rag-${var.env}-${random_string.suffix.result}"
  location                      = azurerm_resource_group.main.location
  resource_group_name           = azurerm_resource_group.main.name
  tenant_id                     = data.azurerm_client_config.current.tenant_id
  sku_name                      = "standard"
  rbac_authorization_enabled    = true
  soft_delete_retention_days    = 7
  purge_protection_enabled      = var.kv_purge_protection
  public_network_access_enabled = true
  tags                          = local.tags
}

resource "azurerm_role_assignment" "me_kv_secrets_officer" {
  scope                = azurerm_key_vault.main.id
  role_definition_name = "Key Vault Secrets Officer"
  principal_id         = data.azurerm_client_config.current.object_id
}
