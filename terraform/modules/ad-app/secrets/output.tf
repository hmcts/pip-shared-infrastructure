output "app_display_name" {
  value = data.azuread_application.app.display_name
}
output "app_object_id" {
  value = data.azuread_application.app.object_id
}
output "app_application_id" {
  value = data.azuread_application.app.application_id
}
output "pw_display_name" {
  value = azuread_application_password.app_pw.display_name
}
output "pw_value" {
  value = azuread_application_password.app_pw.value
}