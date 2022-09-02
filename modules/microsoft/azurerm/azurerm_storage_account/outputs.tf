output "id" {
  value = azurerm_storage_account.default.id
}
output "name" {
  value = azurerm_storage_account.default.name
}
output "identity" {
  value = azurerm_storage_account.default.identity
}
output "primary_blob_endpoint" {
  value = azurerm_storage_account.default.primary_blob_endpoint
}
output "primary_blob_host" {
  value = azurerm_storage_account.default.primary_blob_host
}
output "primary_access_key" {
  value = azurerm_storage_account.default.primary_access_key
}
output "primary_connection_string" {
  value = azurerm_storage_account.default.primary_connection_string
}
output "primary_blob_connection_string" {
  value = azurerm_storage_account.default.primary_blob_connection_string
}
output "secondary_blob_endpoint" {
  value = azurerm_storage_account.default.secondary_blob_endpoint == ""  || azurerm_storage_account.default.secondary_blob_endpoint == null ? azurerm_storage_account.default.primary_blob_endpoint : azurerm_storage_account.default.secondary_blob_endpoint
}
output "secondary_blob_host" {
  value = azurerm_storage_account.default.secondary_blob_host
}
output "secondary_access_key" {
  value = azurerm_storage_account.default.secondary_access_key
}
output "secondary_connection_string" {
  value = azurerm_storage_account.default.secondary_connection_string
}
output "secondary_blob_connection_string" {
  value = azurerm_storage_account.default.secondary_blob_connection_string
}