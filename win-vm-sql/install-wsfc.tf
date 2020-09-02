resource "azurerm_virtual_machine_extension" "install-wsfc" {
  name                 = "install-wsfc-cluster"
  virtual_machine_id   = azurerm_virtual_machine.win-vm-sql.id
  # resource_group_name  = var.vm_rg_name
  # location             = var.vm_location
  # virtual_machine_name = azurerm_virtual_machine.win-vm-sql.name
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.9"

  settings = <<SETTINGS
    { 
      "commandToExecute": "powershell Install-WindowsFeature -Name Failover-Clustering -IncludeManagementTools"
    } 
SETTINGS

  depends_on = [azurerm_virtual_machine_extension.join-domain]
}