resource "azurerm_storage_account" "docs" {
  #checkov:skip=CKV_AZURE_59:Accepted risk until private networking, see issue 8. Shared keys are off, so access needs Entra ID.
  #checkov:skip=CKV2_AZURE_33:Accepted risk until private networking, see issue 8.
  #checkov:skip=CKV_AZURE_33:Not applicable. This account holds blobs only and has no queues.
  #checkov:skip=CKV2_AZURE_1:Not required. Microsoft managed keys are enough and no regulation requires customer managed keys.
  name                            = "stragdocs${random_string.suffix.result}"
  resource_group_name             = azurerm_resource_group.main.name
  location                        = azurerm_resource_group.main.location
  account_tier                    = "Standard"
  account_replication_type        = var.storage_replication
  min_tls_version                 = "TLS1_2"
  shared_access_key_enabled       = false
  allow_nested_items_to_be_public = false

  blob_properties {
    versioning_enabled = true
    delete_retention_policy {
      days = 7
    }
  }

  tags = local.tags
}

resource "azurerm_storage_container" "documents" {
  #checkov:skip=CKV2_AZURE_21:Planned. Blob read logging through diagnostic settings, see issue 8.
  name                  = "documents"
  storage_account_id    = azurerm_storage_account.docs.id
  container_access_type = "private"
}

resource "azurerm_role_assignment" "me_blob_contributor" {
  scope                = azurerm_storage_account.docs.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = data.azurerm_client_config.current.object_id
}
