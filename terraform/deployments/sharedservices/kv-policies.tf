data "azurerm_user_assigned_identity" "aks_mi" {
  provider            = azurerm.ptl
  name                = "aks-${var.environment}-mi"
  resource_group_name = "genesis-rg"
}
data "azurerm_user_assigned_identity" "jenkins_ptl_mi" {
  provider            = azurerm.ptl
  name                = "jenkins-ptl-mi"
  resource_group_name = "managed-identities-ptl-rg"
}

data "azuread_application" "cft_client" {
  display_name = "cft-client"
}

module "keyvault-policy" {
  source = "../../modules/key-vault/access-policy"

  key_vault_id = module.kv.key_vault_id

  policies = {
    "cft-client" = {
      tenant_id               = data.azurerm_client_config.current.tenant_id
      object_id               = data.azuread_application.cft_client.object_id
      key_permissions         = []
      secret_permissions      = ["get"]
      certificate_permissions = []
      storage_permissions     = []
    },
    "jenkins-ptl-mi" = {
      tenant_id               = data.azurerm_client_config.current.tenant_id
      object_id               = data.azurerm_user_assigned_identity.jenkins_ptl_mi.principal_id
      key_permissions         = []
      secret_permissions      = ["Get", "List", "Set", "Delete", "Recover", "Backup", "Restore"]
      certificate_permissions = []
      storage_permissions     = []
    },
    "aks-${var.environment}-mi" = {
      tenant_id               = data.azurerm_client_config.current.tenant_id
      object_id               = data.azurerm_user_assigned_identity.aks_mi.principal_id
      key_permissions         = []
      secret_permissions      = ["Get", "List", "Set", "Delete", "Recover", "Backup", "Restore"]
      certificate_permissions = []
      storage_permissions     = []
    }
  }
}
