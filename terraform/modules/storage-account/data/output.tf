output "primary_access_key" {
  value = data.azurerm_storage_account.sa.primary_access_key
}
output "primary_connection_string" {
  value = data.azurerm_storage_account.sa.primary_connection_string
}