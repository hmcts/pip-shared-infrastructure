
## Loop secrets
resource "azurerm_key_vault_secret" "secret" {
  for_each        = { for secret in var.secrets : secret.name => secret }
  key_vault_id    = var.key_vault_id
  name            = each.value.name
  value           = each.value.value
  tags            = merge(var.tags, each.value.tags)
  content_type    = each.value.content_type
  expiration_date = timeadd(timestamp(), "8760h")
}
## Loop secrets with count - Use above method first. Only use this if cannot use for_each
resource "azurerm_key_vault_secret" "secrets" {
  count           = length(var.c_secrets)
  key_vault_id    = var.key_vault_id
  name            = var.c_secrets[count.index].name
  value           = var.c_secrets[count.index].value
  tags            = merge(var.tags, var.c_secrets[count.index].tags)
  content_type    = var.c_secrets[count.index].content_type
  expiration_date = timeadd(timestamp(), "8760h")
}
