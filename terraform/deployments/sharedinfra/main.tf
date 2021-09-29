locals {
  product                  = "pip"
  common_tags              = module.ctags.common_tags
  resource_group_name      = "pip-sharedinfra-${var.environment}-rg"
  storage_account_name     = "pipsharedinfrasa${var.environment}"
  dtu_storage_account_name = "pipdtu${var.environment}"
  team_name                = "PIP DevOps"
  team_contact             = "#vh-devops"
}

module "ctags" {
  source      = "git::https://github.com/hmcts/terraform-module-common-tags.git?ref=master"
  environment = var.environment
  product     = local.product
  builtFrom   = var.builtFrom
}

module "network" {
  source                        = "../../modules/network"
  environment                   = var.environment
  resource_group                = local.resource_group_name
  product                       = local.product
  location                      = var.location
  address_space                 = var.address_space
  subnet_address_prefixes       = var.subnet_address_prefixes
  apim_nsg_rules                = var.apim_nsg_rules
  apim_rules                    = var.apim_rules
  route_table                   = var.route_table
  tags                          = local.common_tags
  log_analytics_workspace_name  = var.log_analytics_workspace_name
  log_analytics_workspace_rg    = var.log_analytics_workspace_rg
  log_analytics_subscription_id = var.la_sub_id
}

module "postgresql" {
  source         = "../../modules/postgresql"
  environment    = var.environment
  resource_group = local.resource_group_name
  location       = var.location
  product        = local.product
  tags           = local.common_tags
  subnet_id      = module.network.apim_subnet_id
}

module "app-insights" {
  source         = "../../modules/app-insights"
  environment    = var.environment
  resource_group = local.resource_group_name
  location       = var.location
  product        = local.product
  support_email  = var.support_email
  ping_tests     = var.ping_tests
  tags           = local.common_tags
}

module "sa" {
  source = "git::https://github.com/hmcts/cnp-module-storage-account.git?ref=master"

  env = var.environment

  storage_account_name = local.storage_account_name
  common_tags          = local.common_tags

  default_action = "Allow"

  resource_group_name = local.resource_group_name
  location            = var.location

  account_tier             = var.sa_account_tier
  account_kind             = var.sa_account_kind
  account_replication_type = var.sa_account_replication_type
  access_tier              = var.sa_access_tier

  team_name    = local.team_name
  team_contact = local.team_contact
}

resource "azurerm_storage_table" "distributionlist" {
  name                 = "distributionlist"
  storage_account_name = local.storage_account_name
  depends_on = [
    module.sa
  ]
}

module "dtu_sa" {
  source = "git::https://github.com/hmcts/cnp-module-storage-account.git?ref=master"

  env = var.environment

  storage_account_name = local.dtu_storage_account_name
  common_tags          = local.common_tags

  default_action = "Allow"

  resource_group_name = local.resource_group_name
  location            = var.location

  account_tier             = var.sa_account_tier
  account_kind             = var.sa_account_kind
  account_replication_type = "LRS"
  access_tier              = "Hot"

  team_name    = local.team_name
  team_contact = local.team_contact
}