
data "azuread_application" "app" {
  display_name = var.app_name
}

resource "azuread_application_password" "app_pw" {
  application_object_id = data.azuread_application.app.object_id
  display_name          = "${var.app_name}-pwd"
}