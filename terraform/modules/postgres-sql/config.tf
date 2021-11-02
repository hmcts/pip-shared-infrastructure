locals {
  settings_on  = ["log_checkpoints", "connection_throttling", "log_connections"]
  settings_off = []
}
resource "azurerm_postgresql_configuration" "config_on" {
  for_each            = { for settings_on in local.settings_on : settings_on => settings_on }
  name                = each.value
  resource_group_name = var.resource_group_name
  server_name         = azurerm_postgresql_server.postgres-paas.name
  value               = "on"
}
resource "azurerm_postgresql_configuration" "config_off" {
  for_each            = { for settings_off in local.settings_off : settings_off => settings_off }
  name                = each.value
  resource_group_name = var.resource_group_name
  server_name         = azurerm_postgresql_server.postgres-paas.name
  value               = "off"
}