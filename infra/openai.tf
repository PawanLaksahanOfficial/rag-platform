resource "azurerm_cognitive_account" "ai" {
  #checkov:skip=CKV_AZURE_134:Accepted risk until private networking, see issue 8. Local keys are off, so access needs Entra ID.
  #checkov:skip=CKV2_AZURE_22:Not required. Microsoft managed keys are enough and no regulation requires customer managed keys.
  name                          = "aif-rag-${var.env}-${random_string.suffix.result}"
  location                      = var.openai_location
  resource_group_name           = azurerm_resource_group.main.name
  kind                          = "AIServices"
  sku_name                      = "S0"
  custom_subdomain_name         = "aif-rag-${var.env}-${random_string.suffix.result}"
  local_auth_enabled            = false
  public_network_access_enabled = true
  tags                          = local.tags

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_cognitive_deployment" "chat" {
  name                 = "chat"
  cognitive_account_id = azurerm_cognitive_account.ai.id

  model {
    format  = "OpenAI"
    name    = "gpt-5.4-mini"
    version = "2026-03-17"
  }

  sku {
    name     = "GlobalStandard"
    capacity = 10
  }
}

resource "azurerm_cognitive_deployment" "embed" {
  name                 = "embed"
  cognitive_account_id = azurerm_cognitive_account.ai.id

  model {
    format  = "OpenAI"
    name    = "text-embedding-3-small"
    version = "1"
  }

  sku {
    name     = "GlobalStandard"
    capacity = 10
  }

  depends_on = [azurerm_cognitive_deployment.chat]
}

resource "azurerm_role_assignment" "me_openai_user" {
  scope                = azurerm_cognitive_account.ai.id
  role_definition_name = "Cognitive Services OpenAI User"
  principal_id         = data.azurerm_client_config.current.object_id
}
