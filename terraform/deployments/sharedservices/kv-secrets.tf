module "shared_storage" {
  source = "../../modules/storage-account/data"

  storage_account_name = "${local.shared_storage_name}${var.environment}"
  resource_group_name  = local.shared_infra_resource_group_name
}

module "pipdtu" {
  source = "../../modules/storage-account/data"

  storage_account_name = "pipdtu${var.environment}"
  resource_group_name  = local.shared_infra_resource_group_name
}

resource "random_password" "pact_db_password" {
  length      = 20
  min_upper   = 2
  min_lower   = 2
  min_numeric = 2
  min_special = 2
}
data "azurerm_application_insights" "appin" {
  name                = "pip-sharedinfra-appins-${var.environment}"
  resource_group_name = local.shared_infra_resource_group_name
}

module "keyvault_secrets" {
  source = "../../modules/key-vault/secret"

  key_vault_id = module.kv.key_vault_id
  tags         = local.common_tags
  secrets = [
    {
      name         = "appins-instrumentation-key"
      value        = data.azurerm_application_insights.appin.instrumentation_key
      tags         = {}
      content_type = ""
    },
    {
      name         = "${local.shared_storage_name}-storageaccount-key"
      value        = module.shared_storage.primary_access_key
      tags         = {}
      content_type = ""
    },
    {
      name         = "${local.shared_storage_name}-storageaccount-name"
      value        = local.shared_storage_name
      tags         = {}
      content_type = ""
    },
    {
      name         = "dtu-storage-account-key"
      value        = module.pipdtu.primary_access_key
      tags         = {}
      content_type = ""
    },
    {
      name  = "pact-db-password"
      value = random_password.pact_db_password.result
      tags = {
        "file-encoding" = "utf-8"
        "purpose"       = "pactbrokerdb"
      }
      content_type = ""
    },
    {
      name  = "pact-db-user"
      value = "pactadmin"
      tags = {
        "file-encoding" = "utf-8"
        "purpose"       = "pactbrokerdb"
      }
      content_type = ""
    }
  ]

}