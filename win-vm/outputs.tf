#########################################
## Windows VM with Web Server - Output ##
#########################################

# Windows VM ID
output "windows_vm_id" {
  value = azurerm_windows_virtual_machine.windows-vm.id
}

# Windows VM Name
output "windows_vm_name" {
  value = azurerm_windows_virtual_machine.windows-vm.name
}

# Windows VM Public IP
output "windows_vm_public_ip" {
  value = azurerm_public_ip.windows-vm-ip.ip_address
}

# Windows VM Admin Username
output "vm_admin_username" {
  value = var.admin_username
}

# Windows VM Admin Password
output "vm_admin_password" {
  value = var.admin_password
}
