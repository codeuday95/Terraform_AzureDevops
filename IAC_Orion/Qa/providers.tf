terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.39.1"
    }
  }
        backend "azurerm" {
        resource_group_name  = "Azurecli-Qa-Rg"
        storage_account_name = "azurecliqastorageac"
        container_name       = "tfstate"
        key                  = "terraform.tfstate"
        access_key = "V/UtiMj2q3I0uCPwFsXXX"
        }
}
  




provider "azurerm" {
  features {}
  # subscription_id = "8748e8f0-0c2f-4XX"
  # client_id       = "3432d60c-7f96-4XXX"
  # client_secret   = "DLp8Q~vqfxrzZA.XXX"
  # tenant_id       = "7cc41e2c-db4e-XXX"
  
}