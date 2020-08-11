#######################################
## Windows VM          Server - Main ##
#######################################


variable "vm_name" {
  description = "Name of the Win machinet. Must be unique."
  type = string
}

variable "vm_rg_name" {
  type = string
  description = "Name of the Resource Group"
}

variable "vm_location" {
  type = string
  description = "Location of the vm"
}

variable "vm_subnet_id" {
  type = string
  description = "Id of the subnet"
}

variable "vm_storage_type" {
  type = string
  description = "Storage account type to use for disk. Standard_LRS, StandardSSD_LRS, Premium_LRS or UltraSSD_LRS."

}

variable "environment" {
  type = string
  description = "The environment for the machine to run"
}

variable "vm_size" {
  type = string
  description = "Size of the machine"
}

variable "admin_username" {
  type = string
  description = "The username of admin user"
}

variable "admin_password" {
  type = string
  description = "The password of the admin user"
}

variable "project_id" {
  type = string
  description = "Name of the project"
}

variable "network_security_group_id" {
  type = string
  description = "network_security_group_id to associate with interface"
}

# Get a Static Public IP 
resource "azurerm_public_ip" "windows-vm-ip" {
  name                = "win-vm-ip"
  location            = var.vm_location
  resource_group_name = var.vm_rg_name
  allocation_method   = "Static"
  
  tags = { 
    environment = var.environment 
  }
}

# Create Network Card for web VM buyusa
resource "azurerm_network_interface" "windows-vm-nic" {
  depends_on=[azurerm_public_ip.windows-vm-ip]

  name                      = "${var.vm_name}-vm-nic-${var.project_id}-${var.environment}"
  location                  = var.vm_location
  resource_group_name       = var.vm_rg_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.vm_subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.windows-vm-ip.id
  }

  tags = { 
    #application = var.app_name
    environment = var.environment 
  }
}

# Create Windows Server
resource "azurerm_windows_virtual_machine" "windows-vm" {
  depends_on=[azurerm_network_interface.windows-vm-nic]

  name                  = "${var.vm_name}-vm-${var.project_id}-${var.environment}"
  location              = var.vm_location
  resource_group_name   = var.vm_rg_name
  size                  = var.vm_size
  network_interface_ids = [azurerm_network_interface.windows-vm-nic.id]
  
  computer_name         = var.vm_name
  admin_username        = var.admin_username
  admin_password        = var.admin_password

  os_disk {
    name                 = "${var.vm_name}-vm-os-disk-${var.project_id}-${var.environment}"
    caching              = "ReadWrite"
    storage_account_type = var.vm_storage_type
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = var.windows-2016-sku
    version   = "latest"
  }

  enable_automatic_updates = false
  provision_vm_agent       = true

  tags = {
    #application = var.app_name
    environment = var.environment 
  }
}

resource "azurerm_network_interface_security_group_association" "vm-nsg-association" {
  network_interface_id      = azurerm_network_interface.windows-vm-nic.id
  network_security_group_id = var.network_security_group_id
}
