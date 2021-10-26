output "app_display_name" {
  value = data.azuread_application.app.display_name
}
output "app_object_id" {
  value = data.azuread_application.app.object_id
}
output "app_application_id" {
  value = data.azuread_application.app.application_id
}
output "pwd_display_name" {
  value = azuread_application_password.app_pwd.display_name
  sensitive=true
}
output "pwd_value" {
  value = azuread_application_password.app_pwd.value
  sensitive=true
}