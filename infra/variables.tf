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

 