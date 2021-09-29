# Generic locals
locals {
  common_tags                      = module.ctags.common_tags
  resource_group_name              = "${var.product}-sharedservices-${var.environment}-rg"
  key_vault_name                   = "${var.product}-shared-kv-${var.environment}"
  shared_storage_name              = "pipsharedinfrasa"
  shared_infra_resource_group_name = "pip-sharedinfra-${var.environment}-rg"
}

module "ctags" {
  source      = "git::https://github.com/hmcts/terraform-module-common-tags.git?ref=master"
  environment = var.environment
  product     = "pip"
  builtFrom   = var.builtFrom
}

resource "azurerm_resource_group" "rg" {
  name     = local.resource_group_name
  location = var.location
  tags     = local.common_tags
}

data "azurerm_client_config" "current" {}
module "kv" {
  source                  = "git::https://github.com/hmcts/cnp-module-key-vault?ref=master"
  name                    = local.key_vault_name
  product                 = var.product
  env                     = var.environment
  object_id               = data.azurerm_client_config.current.tenant_id
  resource_group_name     = local.resource_group_name
  product_group_name      = var.active_directory_group
  common_tags             = local.common_tags
  create_managed_identity = true
}
