module "azurerm_storage_account" {
  source = "../../Buildtemplates/azurerm_storage_account"
  azurerm_resource_group = var.azurerm_resource_group
  location            = var.location
  azurerm_storage_account  = var.azurerm_storage_account
} 
