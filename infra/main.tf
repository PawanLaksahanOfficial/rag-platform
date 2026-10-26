locals {
  tags = {
    project = "rag"
    env     = var.env
    owner   = "pawan"
  }
}

resource "random_string" "suffix" {
  length  = 5
  upper   = false
  special = false
}

resource "azurerm_resource_group" "main" {
  name     = "rg-rag-${var.env}"
  location = var.location
  tags     = local.tags
}
