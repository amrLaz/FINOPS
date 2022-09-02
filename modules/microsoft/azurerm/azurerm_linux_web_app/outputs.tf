output "id" {
  value = azurerm_linux_web_app.default.id
}
output "name" {
  value = azurerm_linux_web_app.default.name
}
output "identity" {
  sensitive = true
  value     = azurerm_linux_web_app.default.identity
}
output "default_hostname" {
  value = azurerm_linux_web_app.default.default_hostname
}