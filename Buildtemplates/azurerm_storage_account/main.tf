resource "azurerm_storage_account" "azurerm_storage_account_tfname" {
  name                     = var.azurerm_storage_account
  resource_group_name      = var.azurerm_resource_group
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    environment = "staging"
  }
}