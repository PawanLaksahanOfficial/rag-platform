variable "subscription_id" {
  description = "Azure subscription to deploy into"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
  default     = "centralindia"
}

variable "env" {
  description = "Environment name"
  type        = string

  validation {
    condition     = contains(["test", "prod"], var.env)
    error_message = "env must be test or prod."
  }
}

variable "openai_location" {
  type    = string
  default = "eastus"
}

variable "kv_purge_protection" {
  description = "Block permanent deletion of the Key Vault and its secrets during the retention period"
  type        = bool
  default     = true
}

variable "storage_replication" {
  description = "Replication type for the documents storage account"
  type        = string
  default     = "GRS"

  validation {
    condition     = contains(["LRS", "ZRS", "GRS", "GZRS"], var.storage_replication)
    error_message = "storage_replication must be LRS, ZRS, GRS or GZRS."
  }
}

variable "kubernetes_version" {
  description = "AKS Kubernetes minor version; patches are applied automatically"
  type        = string
  default     = "1.36"
}

variable "aks_sku_tier" {
  description = "AKS control plane tier. Standard has an uptime SLA; Free has none"
  type        = string
  default     = "Standard"

  validation {
    condition     = contains(["Free", "Standard"], var.aks_sku_tier)
    error_message = "aks_sku_tier must be Free or Standard."
  }
}

variable "aks_node_size" {
  description = "VM size for the AKS system node pool"
  type        = string
  default     = "Standard_D2ads_v5"
}
