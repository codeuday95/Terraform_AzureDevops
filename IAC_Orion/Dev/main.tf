module "azurerm_storage_account" {
  source = "../../Buildtemplates/azurerm_storage_account"
  azurerm_resource_group = var.azurerm_resource_group
  location            = var.location
  azurerm_storage_account  = var.azurerm_storage_account
} 

module "windowsservers" {
  source              = "Azure/compute/azurerm"
  resource_group_name = var.azurerm_resource_group
  vm_size             = "Standard_B2s"
  nb_instances        = 1
  nb_data_disk        = 0
  delete_data_disks_on_termination = true
  delete_os_disk_on_termination = true
  is_windows_image    = true
  vm_hostname         = "azureclivm" // line can be removed if only one VM module per resource group
  admin_password      = "ComplxP@ssw0rd!"
  vm_os_simple        = "WindowsServer"
  public_ip_dns       = ["azureclivm"] // change to a unique name per datacenter region
  remote_port         = "3389"
  vnet_subnet_id      = "/subscriptions/XXX/resourceGroups/OMEGA-RG-DEV/providers/Microsoft.Network/virtualNetworks/OMEGA-RG-DEV-vnet/subnets/default"
  vm_extensions       = [ { 
    name = "Custom_Configuration"
    publisher                  = "Microsoft.Compute"
    type                       = "CustomScriptExtension"
    type_handler_version       = "1.8"
    auto_upgrade_minor_version = true
    automatic_upgrade_enabled = false
    #failure_suppression_enabled = optional(bool, false) 
    #settings = optional(string) 
    protected_settings = <<SETTINGS
  {
     "commandToExecute": "powershell -encodedCommand ${textencodebase64(file("install.ps1"), "UTF-16LE")}"
  }
  SETTINGS
    #protected_settings_from_key_vault = optional(object({ secret_url = string source_vault_id = string })) }))

}]                      

  depends_on = [var.azurerm_resource_group]
}