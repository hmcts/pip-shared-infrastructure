
locals {
  storage_account_name = "pipsharedinfrasa${var.env}"
}

module "sa" {
  source = "git::https://github.com/hmcts/cnp-module-storage-account.git?ref=master"

  env = var.env

  storage_account_name = local.storage_account_name
  common_tags          = var.common_tags

  resource_group_name = var.resource_group_name
  location            = var.location

  account_tier             = var.sa_account_tier
  account_kind             = var.sa_account_kind
  account_replication_type = var.sa_account_replication_type
  access_tier              = var.sa_access_tier

  team_name    = "PIP DevOps"
  team_contact = "#vh-devops"
}

resource "azurerm_storage_table" "example" {
  name                 = "distributionlist"
  storage_account_name = azurerm_storage_account.example.name
}