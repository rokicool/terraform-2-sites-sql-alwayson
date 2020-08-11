


# Get a Dynamic Public IP 
resource "azurerm_public_ip" "win-vm-sql-ip" {
  name                = "${var.win_vm_sql_name}-win-vm-ip"
  location            = var.vm_location
  resource_group_name = var.vm_rg_name
  allocation_method   = "Dynamic"
  
  tags = { 
    environment = var.environment 
  }
}


# Create Network Card for VM 
resource "azurerm_network_interface" "win-vm-sql-nic" {
  depends_on=[azurerm_public_ip.win-vm-sql-ip]

  name                      = "${var.win_vm_sql_name}-vm-nic-${var.project_id}-${var.environment}"
  location                  = var.vm_location
  resource_group_name       = var.vm_rg_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.vm_subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.win-vm-sql-ip.id
  }

  tags = { 
    #application = var.app_name
    environment = var.environment 
  }
}

resource "azurerm_network_interface_security_group_association" "vm-nsg-association" {
  network_interface_id      = azurerm_network_interface.win-vm-sql-nic.id
  network_security_group_id = var.network_security_group_id
}

resource "azurerm_virtual_machine" "win-vm-sql" {
  name                  = "${var.win_vm_sql_name}-vm-${var.project_id}-${var.environment}"
  location              = var.vm_location
  resource_group_name   = var.vm_rg_name
  network_interface_ids = [azurerm_network_interface.win-vm-sql-nic.id]
  vm_size               = var.vm_size



  #storage_image_reference {
  #  publisher = "MicrosoftSQLServer"
  #  offer     = "SQL2017-WS2016"
  #  sku       = "SQLDEV"
  #  version   = "laexample"
  #}

  storage_image_reference {
    publisher = var.os_image_publisher
    offer     = var.os_image_offer
    sku       = var.os_image_sku
    version   = var.os_image_version
  }

  storage_os_disk {
    name              = "${var.win_vm_sql_name}-vm-${var.project_id}-${var.environment}-OSDisk"
    caching           = "ReadOnly"
    create_option     = "FromImage"
    managed_disk_type = var.vm_storage_type
  }

  os_profile {
    computer_name  = var.win_vm_sql_name
    admin_username = var.admin_username
    admin_password = var.admin_password
  }

  os_profile_windows_config {
    timezone                  = var.os_profile_windows_timezone 
    provision_vm_agent        = true
    enable_automatic_upgrades = true
  }
}

resource "azurerm_mssql_virtual_machine" "win-vm-sql" {
  virtual_machine_id = azurerm_virtual_machine.win-vm-sql.id
  sql_license_type   = "PAYG" #??
}