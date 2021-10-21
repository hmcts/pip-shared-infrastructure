

resource "azuread_application_password" "otp_app_pwd" {
  provider              = azuread.otp_sub
  application_object_id = var.object_id
  display_name          = var.display_name
}