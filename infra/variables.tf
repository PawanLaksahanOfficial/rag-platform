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
 