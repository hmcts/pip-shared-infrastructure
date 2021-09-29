variable "environment" {}
variable "location" {}
variable "support_email" {}
variable "ping_tests" {}
variable "builtFrom" {
  type        = string
  description = "Build pipeline"
}

variable "address_space" {}
variable "subnet_address_prefixes" {}
variable "apim_nsg_rules" {}
variable "apim_rules" {}
variable "log_analytics_workspace_name" {}
variable "log_analytics_workspace_rg" {}
variable "la_sub_id" {}

variable "route_table" {
  default = null
}

variable "sa_access_tier" {
  type    = string
  default = "Cool"
}
variable "sa_account_kind" {
  type    = string
  default = "StorageV2"
}
variable "sa_account_tier" {
  type    = string
  default = "Standard"
}
variable "sa_account_replication_type" {
  type    = string
  default = "RAGRS"
}