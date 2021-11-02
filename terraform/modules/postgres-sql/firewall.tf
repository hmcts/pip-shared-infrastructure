data "azurerm_subnet" "subnets" {
  for_each             = { for subnet in var.subnet_names : subnet => subnet }
  name                 = each.value
  resource_group_name  = "ss-${var.environment}-network-rg"
  virtual_network_name = "ss-${var.environment}-vnet"
}

resource "azurerm_postgresql_virtual_network_rule" "postgres-vnet-rules" {
  for_each                             = { for subnet in data.azurerm_subnet.subnets : subnet.name => subnet }
  name                                 = each.value.name
  resource_group_name                  = var.resource_group_name
  server_name                          = var.server_name
  subnet_id                            = each.value.internal.id
  ignore_missing_vnet_service_endpoint = true
}