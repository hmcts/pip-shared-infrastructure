
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

