variable "resource_group_name" {
  type        = string
  description = "Resource Group Name to deploy to"
}
variable "location" {
  type    = string
  default = "Deployment Location"
}
variable "common_tags" {
  type = map(any)
}
variable "product" {
  type        = string
  description = "Application product prefix"
}
variable "environment" {
  type        = string
  description = "Environment name"
}


variable "server_name" {
  type        = string
  description = "PostgresSQL Server Name"
}
variable "postgresql_user" {}

## Server Defaults
variable "subnet_names" {
  type        = list(string)
  description = "List of SDS VNet Subnets to add to firewall"
  default     = ["iaas", "aks-00", "aks-01"]
}
variable "postgresql_listen_port" {
  default = "5432"
}
variable "sku_name" {
  default = "GP_Gen5_2"
}
variable "sku_tier" {
  default = "GeneralPurpose"
}
variable "sku_capacity" {
  default = "2"
}
variable "postgresql_version" {
  default = "10"
}
variable "storage_mb" {
  default = "51200"
}
variable "backup_retention_days" {
  default = "35"
}
variable "georedundant_backup" {
  default = "true"
}


variable "database_names" {
  type        = list(string)
  description = "List of Database names to add"
}

## Database Defaults
variable "charset" {
  default = "utf8"
}
variable "collation" {
  default = "en-GB"
}
