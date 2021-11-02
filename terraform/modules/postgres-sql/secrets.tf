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
