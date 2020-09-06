#########################################
## Windows VM with SQL Server - Output ##
#########################################

# Windows VM ID
output "win-vm-sql-id" {
  value = azurerm_virtual_machine.win-vm-sql.id
}

# Windows VM Name
output "win-vm-sql-name" {
  value = azurerm_virtual_machine.win-vm-sql.name
}

# Windows VM Public IP
output "win_vm_sql_public_ip" {
  value = azurerm_public_ip.win-vm-sql-ip.ip_address
}


# Windows VM NIC ID
output "win-vm-sql-nic-id" {
  value = azurerm_network_interface.win-vm-sql-nic.id
}


# Windows VM NIC ip config name
output "win-vm-sql-nic-ip-conf-name" {
  value = azurerm_network_interface.win-vm-sql-nic.ip_configuration[0].name
}

# Windows VM Admin Username
output "vm_admin_username" {
  value = var.admin_username
}

# Windows VM Admin Password
output "vm_admin_password" {
  value = var.admin_password
}
