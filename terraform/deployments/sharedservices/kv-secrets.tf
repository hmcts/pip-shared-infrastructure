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
resource "random_password" "session_string" {
  length      = 20
  min_upper   = 2
  min_lower   = 2
  min_numeric = 2
  min_special = 2
  special     = true
}

module "keyvault_secrets" {
  source = "../../modules/key-vault/secret"

  key_vault_id = module.kv.key_vault_id
  tags         = local.common_tags
  secrets = [
    {
      name  = "otp-tenant-id"
      value = var.opt_tenant_id
      tags = {
        "source" : "OTP Tenant"
      }
      content_type = ""
    },
    {
      name         = "${local.shared_storage_name}-storageaccount-key"
      value        = module.shared_storage.primary_access_key
      tags         = {}
      content_type = ""
    },
    {
      name         = "${local.shared_storage_name}-storageaccount-connection-string"
      value        = module.shared_storage.primary_connection_string
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
      name         = "dtu-storageaccount-key"
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
    },
    {
      name  = "session-key"
      value = random_password.session_string.result
      tags = {
        "purpose" = "opt-session"
      }
      content_type = ""
    }
  ]

}

module "keyvault_ado_secrets" {
  source = "../../modules/key-vault/secret"

  key_vault_id = module.kv.key_vault_id
  tags         = local.common_tags
  secrets = [
    for secret in var.secrets_arr : {
      name  = secret.name
      value = secret.value
      tags = {
        "source" : "ado library"
      }
      content_type = ""
    }
  ]
}

module "otp_apps" {
  for_each = var.otp_app_names
  source = "../../modules/ad-app/secrets"
  providers = {
    azuread = azuread.otp_sub
  }
  app_name = each.value
}

module "keyvault_otp_id_secrets" {
  source = "../../modules/key-vault/secret"

  key_vault_id = module.kv.key_vault_id
  tags         = local.common_tags
  secrets = [
    for otp_app in module.otp_apps : {
      name  = lower("otp-app-${otp_app.app_display_name}-id")
      value = otp_app.app_application_id
      tags = {
        "source" : "OTP Tenant"
      }
      content_type = ""
    }
  ]
}
module "keyvault_otp_id_pwds" {
  source = "../../modules/key-vault/secret"

  key_vault_id = module.kv.key_vault_id
  tags         = local.common_tags
  secrets = [
    for otp_app_pwd in module.otp_apps : {
      name  = lower("otp-app-${otp_app_pwd.pwd_display_name}")
      value = otp_app_pwd.pwd_value
      tags = {
        "source" : "OTP Tenant"
      }
      content_type = ""
    }
  ]
}