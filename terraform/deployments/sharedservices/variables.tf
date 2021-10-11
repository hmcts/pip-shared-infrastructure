variable "environment" {
  type        = string
  description = "Deployment Environment"
}
variable "product" {
  type        = string
  description = "Product Name"
  default     = "pip"
}
variable "builtFrom" {
  type        = string
  description = "Source of deployment"
  default     = "local"
}

variable "location" {
  type        = string
  description = "Resource Location"
}

variable "active_directory_group" {
  type        = string
  description = "Active Directory Group Name"
  default     = "DTS SDS Developers"
}

## Secrets
variable "secrets_arr" {
  type = list(object({
    name  = string
    value = string
  }))
  description = "Key Vault Secrets from AzDO Library"
  #sensitive   = true
  default = []
}

## OTP Subscription
variable "opt_tenant_id" {
  type        = string
  description = "PIP One Time Password Tenant ID"
}
variable "otp_app_names" {
  type        = list(string)
  description = "List of Applications in OTP"
}