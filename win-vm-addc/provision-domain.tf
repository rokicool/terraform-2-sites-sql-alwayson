// the `exit_code_hack` is to keep the VM Extension resource happy
locals {

  import_command       = "Import-Module ADDSDeployment"
  password_command     = "$password = ConvertTo-SecureString ${var.admin_password} -AsPlainText -Force"
  
  credentials_command_join  = "$User = '${var.admin_username}@${var.active_directory_domain}'; $Cred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $User, $password"
  credentials_command  = "${var.ad_create ? "" : local.credentials_command_join}"

  install_ad_command   = "Add-WindowsFeature -name ad-domain-services -IncludeManagementTools"
  # configure_ad_command = "Install-ADDSForest -CreateDnsDelegation:$false -DomainName ${var.active_directory_domain} -DomainNetbiosName ${var.active_directory_netbios_name} -ForestMode Win2012R2 -InstallDns:$true -SafeModeAdministratorPassword $password -Force:$true"
  configure_ad_command_create = "Install-ADDSForest -CreateDnsDelegation:$false -DomainName ${var.active_directory_domain} -DomainNetbiosName ${var.active_directory_netbios_name} -InstallDns:$true -SafeModeAdministratorPassword $password -Force:$true"
  configure_ad_command_join = "Start-Sleep -Second 240; Install-ADDSDomainController -DomainName ${var.active_directory_domain} -InstallDns:$true -SafeModeAdministratorPassword $password -Force:$true -Credential $Cred"
  configure_ad_command = "${var.ad_create ? local.configure_ad_command_create : local.configure_ad_command_join}"
  
  shutdown_command     = "shutdown -r -t 10"
  exit_code_hack       = "exit 0"
  powershell_command   = "${local.import_command}; ${local.password_command}; ${local.credentials_command}; ${local.install_ad_command}; ${local.configure_ad_command}; ${local.shutdown_command}; ${local.exit_code_hack}"
}

resource "azurerm_virtual_machine_extension" "create-active-directory-forest" {
  name                 = "create-active-directory-forest"
  virtual_machine_id   = azurerm_windows_virtual_machine.win-vm.id
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.9"

  settings = <<SETTINGS
    {
        "commandToExecute": "powershell.exe -Command \"${local.powershell_command}\""
    }
SETTINGS
}