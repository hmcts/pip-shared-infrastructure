


resource "random_password" "password" {
  length  = 16
  special = true
  upper   = true
  lower   = true
  number  = true
}

resource "azurerm_postgresql_server" "postgres-paas" {
  name                = var.server_name
  location            = var.location
  resource_group_name = var.resource_group_name

  administrator_login          = var.postgresql_user
  administrator_login_password = random_password.password.result

  sku_name   = var.sku_name
  version    = var.postgresql_version
  storage_mb = var.storage_mb

  backup_retention_days            = var.backup_retention_days
  geo_redundant_backup_enabled     = var.georedundant_backup
  ssl_enforcement_enabled          = true
  ssl_minimal_tls_version_enforced = "TLS1_2"
  public_network_access_enabled    = true

  tags = var.common_tags
}

locals {
  is_prod     = length(regexall(".*(prod).*", var.environment)) > 0
  admin_group = local.is_prod ? "DTS Platform Operations SC" : "DTS Platform Operations"
  # psql needs spaces escaped in user names
  escaped_admin_group = replace(local.admin_group, " ", "\\ ")
}

data "azurerm_client_config" "current" {}

data "azuread_group" "db_admin" {
  display_name     = local.admin_group
  security_enabled = true
}

resource "azurerm_postgresql_active_directory_administrator" "admin" {
  for_each            = { for database in azurerm_postgresql_database.postgres-dbs : database.server_name => database }
  server_name         = each.value.server_name
  resource_group_name = var.resource_group_name
  login               = local.admin_group
  tenant_id           = data.azurerm_client_config.current.tenant_id
  object_id           = data.azuread_group.db_admin.object_id
}


resource "azurerm_postgresql_database" "postgres-dbs" {
  for_each            = { for database in var.database_names : database => database }
  name                = replace(each.value, "-", "")
  resource_group_name = var.resource_group_name
  server_name         = azurerm_postgresql_server.postgres-paas.name
  charset             = var.charset
  collation           = var.collation
}


## Add details to Key Vault
locals {
  postgresql_prefix = "postgre"
}
data "azurerm_key_vault" "ss_kv" {
  name                = "${var.product}-shared-kv-${var.environment}"
  resource_group_name = "${var.product}-sharedservices-${var.environment}-rg"
}
module "keyvault_postgre_secrets" {
  source = "../key-vault/secret"

  key_vault_id = data.azurerm_key_vault.ss_kv.id
  tags         = var.common_tags
  secrets = [
    {
      name  = "${local.postgresql_prefix}-host"
      value = "${azurerm_postgresql_server.postgres-paas.name}.postgres.database.azure.com"
      tags = {
        "source" : "PostgreSQL"
      }
      content_type = ""
    },
    {
      name  = "${local.postgresql_prefix}-port"
      value = var.postgresql_listen_port
      tags = {
        "source" : "PostgreSQL"
      }
      content_type = ""
    },
    {
      name  = "${local.postgresql_prefix}-user"
      value = var.postgresql_user
      tags = {
        "source" : "PostgreSQL"
      }
      content_type = ""
    },
    {
      name  = "${local.postgresql_prefix}-pwd"
      value = random_password.password.result
      tags = {
        "source" : "PostgreSQL"
      }
      content_type = ""
    }
  ]
}
