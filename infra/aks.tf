resource "azurerm_container_registry" "main" {
  #checkov:skip=CKV_AZURE_139:Accepted risk, see issue 10. Private access needs the Premium SKU and private networking. Pulls still need Entra ID.
  #checkov:skip=CKV_AZURE_163:Covered by Trivy in CI, which blocks HIGH and CRITICAL images before push. Defender for Containers is paid, see issue 10.
  #checkov:skip=CKV_AZURE_164:Planned, see issue 10. Image signing with Notation or cosign in CI.
  #checkov:skip=CKV_AZURE_165:Not required. Single region deployment, and geo replication needs the Premium SKU.
  #checkov:skip=CKV_AZURE_166:Premium SKU only, see issue 10. Trivy in CI scans every image before push.
  #checkov:skip=CKV_AZURE_167:Premium SKU only. The test registry is destroyed after each session.
  #checkov:skip=CKV_AZURE_233:Premium SKU only, see issue 10.
  #checkov:skip=CKV_AZURE_237:Premium SKU only, see issue 10.
  name                = "acrrag${var.env}${random_string.suffix.result}"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  sku                 = "Basic"
  admin_enabled       = false
  tags                = local.tags
}

resource "azurerm_user_assigned_identity" "aks" {
  name                = "id-aks-rag-${var.env}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  tags                = local.tags
}

resource "azurerm_role_assignment" "aks_network" {
  scope                = azurerm_subnet.aks.id
  role_definition_name = "Network Contributor"
  principal_id         = azurerm_user_assigned_identity.aks.principal_id
}

resource "azurerm_kubernetes_cluster" "main" {
  #checkov:skip=CKV_AZURE_6:Accepted risk, see issue 10. GitHub hosted runners use changing IPs. Local accounts are off, so access needs Entra ID and Azure RBAC.
  #checkov:skip=CKV_AZURE_115:Accepted risk, see issue 10. A private API server needs a VPN or a runner inside the VNet.
  #checkov:skip=CKV_AZURE_4:Planned with the monitoring work, see issue 10.
  #checkov:skip=CKV_AZURE_117:Not required. Platform managed keys are enough and no regulation requires customer managed keys.
  #checkov:skip=CKV_AZURE_232:Accepted for test, see issue 10. The 4 vCPU quota allows one node pool, so system and app pods share it.
  name                      = "aks-rag-${var.env}"
  location                  = azurerm_resource_group.main.location
  resource_group_name       = azurerm_resource_group.main.name
  node_resource_group       = "rg-rag-${var.env}-aks-nodes"
  dns_prefix                = "aks-rag-${var.env}"
  kubernetes_version        = var.kubernetes_version
  sku_tier                  = var.aks_sku_tier
  automatic_upgrade_channel = "patch"
  node_os_upgrade_channel   = "NodeImage"
  local_account_disabled    = true
  oidc_issuer_enabled       = true
  workload_identity_enabled = true
  azure_policy_enabled      = true
  tags                      = local.tags

  default_node_pool {
    name                        = "system"
    vm_size                     = var.aks_node_size
    node_count                  = 1
    max_pods                    = 110
    os_disk_type                = "Ephemeral"
    os_disk_size_gb             = 64
    host_encryption_enabled     = true
    vnet_subnet_id              = azurerm_subnet.aks.id
    temporary_name_for_rotation = "systemtmp"

    upgrade_settings {
      max_surge = "1"
    }
  }

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.aks.id]
  }

  azure_active_directory_role_based_access_control {
    tenant_id          = data.azurerm_client_config.current.tenant_id
    azure_rbac_enabled = true
  }

  network_profile {
    network_plugin      = "azure"
    network_plugin_mode = "overlay"
    network_data_plane  = "cilium"
    network_policy      = "cilium"
    pod_cidr            = "10.244.0.0/16"
    service_cidr        = "10.0.0.0/16"
    dns_service_ip      = "10.0.0.10"
    load_balancer_sku   = "standard"
    outbound_type       = "loadBalancer"
  }

  key_vault_secrets_provider {
    secret_rotation_enabled = true
  }

  depends_on = [azurerm_role_assignment.aks_network]
}

resource "azurerm_role_assignment" "aks_acr_pull" {
  scope                            = azurerm_container_registry.main.id
  role_definition_name             = "AcrPull"
  principal_id                     = azurerm_kubernetes_cluster.main.kubelet_identity[0].object_id
  skip_service_principal_aad_check = true
}

resource "azurerm_role_assignment" "me_aks_admin" {
  scope                = azurerm_kubernetes_cluster.main.id
  role_definition_name = "Azure Kubernetes Service RBAC Cluster Admin"
  principal_id         = data.azurerm_client_config.current.object_id
}
