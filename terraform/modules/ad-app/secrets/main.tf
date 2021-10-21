
resource "azuread_application_password" "app_pwd" {
  application_object_id = var.object_id
  display_name          = var.display_name
}