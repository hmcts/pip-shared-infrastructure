locals {
  product                  = "pip"
  common_tags              = module.ctags.common_tags
  resource_group_name      = "pip-sharedinfra-${var.environment}-rg"
  storage_account_name     = "pipsharedinfrasa${var.environment}"
  dtu_storage_account_name = "pipdtu${var.environment}"
  team_name                = "PIP DevOps"
  team_contact             = "#vh-devops"
  env_long_name            = var.environment == "sbox" ? "sandbox" : var.environment == "stg" ? "staging" : var.environment
  postgresql_user          = "pipdbadmin"
  postgresql_prefix        = "postgre"
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

#tfsec:ignore:azure-storage-default-action-deny
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
locals {
  tables = ["distributionlist", "courts", "artefact"]
}
resource "azurerm_storage_table" "sa_tables" {
  for_each             = { for table in local.tables : table => table }
  name                 = each.value
  storage_account_name = local.storage_account_name
  depends_on = [
    module.sa
  ]
}

#tfsec:ignore:azure-storage-default-action-deny
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

data "azurerm_subnet" "postgres" {
  name                 = "iaas"
  resource_group_name  = "ss-${var.env}-network-rg"
  virtual_network_name = "ss-${var.env}-vnet"
}

module "databases" {
  for_each           = { for database in var.databases : database => database }
  source             = "git::https://github.com/hmcts/cnp-module-postgres.git?ref=postgresql_tf"
  product            = local.product
  component          = "shared-infra"
  subnet_id          = data.azurerm_subnet.postgres.id
  location           = var.location
  env                = local.env_long_name
  postgresql_user    = local.postgresql_user
  database_name      = each.value
  common_tags        = local.common_tags
  subscription       = local.env_long_name
  business_area      = "SDS"
  postgresql_version = 10

  key_vault_rg   = "genesis-rg"
  key_vault_name = "dtssharedservices${var.environment}kv"
}

data "azurerm_key_vault" "ss_kv" {
  name                = "${local.product}-shared-kv-${var.environment}"
  resource_group_name = "${local.product}-sharedservices-${var.environment}-rg"
}
module "keyvault_postgre_secrets" {
  for_each = { for database in module.databases : database.name => database }
  source   = "../../modules/key-vault/secret"

  key_vault_id = data.azurerm_key_vault.ss_kv.id
  tags         = local.common_tags
  secrets = [
    {
      name  = "${local.postgresql_prefix}-${each.value.postgresql_database}-host"
      value = each.value.host_name
      tags = {
        "source" : "PostgreSQL"
      }
      content_type = ""
    },
    {
      name  = "${local.postgresql_prefix}-${each.value.postgresql_database}-port"
      value = each.value.postgresql_listen_port
      tags = {
        "source" : "PostgreSQL"
      }
      content_type = ""
    },
    {
      name  = "${local.postgresql_prefix}-${each.value.postgresql_database}-user"
      value = each.value.user_name
      tags = {
        "source" : "PostgreSQL"
      }
      content_type = ""
    },
    {
      name  = "${local.postgresql_prefix}-${each.value.postgresql_database}-pwd"
      value = each.value.postgresql_password
      tags = {
        "source" : "PostgreSQL"
      }
      content_type = ""
    },
    {
      name  = "${local.postgresql_prefix}-${each.value.postgresql_database}-name"
      value = each.value.postgresql_database
      tags = {
        "source" : "PostgreSQL"
      }
      content_type = ""
    }
  ]
}