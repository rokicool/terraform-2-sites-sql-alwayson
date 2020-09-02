resource "azurerm_virtual_machine_extension" "join-domain" {
    name                 = "join-domain"
    virtual_machine_id   = azurerm_virtual_machine.win-vm-sql.id
    #location             = var.vm_location
    #resource_group_name  = var.vm_rg_name
    #virtual_machine_name = azurerm_virtual_machine.win-vm-sql.name
    publisher            = "Microsoft.Compute"
    type                 = "JsonADDomainExtension"
    type_handler_version = "1.3"
# What the settings mean: https://docs.microsoft.com/en-us/windows/desktop/api/lmjoin/nf-lmjoin-netjoindomain
    settings = <<SETTINGS
       {
        "Name": "${var.active_directory_domain}",
        "OUPath": "${var.active_directory_oupath}",
        "User": "${var.admin_username}@${var.active_directory_domain}",
        "Restart": "true",
        "Options": "3"
        }
    SETTINGS
    protected_settings = <<PROTECTED_SETTINGS
        {
        "Password": "${var.admin_password}"
        }
    PROTECTED_SETTINGS

    depends_on = [azurerm_virtual_machine.win-vm-sql]
}