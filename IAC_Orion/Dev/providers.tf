terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.39.1"
    }
  }
        backend "azurerm" {
        resource_group_name  = "Azurecli-Dev-Rg"
        storage_account_name = "azureclidevstorageac"
        container_name       = "tfstate"
        key                  = "terraform.tfstate"
        access_key = "h9HxIGAtqoxXXslXXX"
        }
}
  

provider "azurerm" {
  features {}
  # subscription_id = "8748e8f0-0c2f-XXX"
  # client_id       = "9ab7e300-e8d0-XXX"
  # client_secret   = "zsV8Q~cXqgeC8~XXX"
  # tenant_id       = "7cc41e2c-db4e-XXX"
  # }
  
}


# export ARM_SUBSCRIPTION_ID="8748e8f0-0c2f-XXX"
# export ARM_TENANT_ID="7cc41e2c-XXX"
# export ARM_CLIENT_ID="9ab7e300-XXX"
# export ARM_CLIENT_SECRET="zsV8Q~XXX"
# export ARM_ACCESS_KEY="gSZrTeAYb/W0rnskyXXX