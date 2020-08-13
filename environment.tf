variable "subscription_id" {}
variable "tenant_id" {}

variable "environment" {
  type = string
  description = "Something like test, dev or prod to add to the names of objects"
}


variable "project_id" {
  type = string
  description = "Just a substring to add to created objects to make them uniquie"
}

# Windows sql VM Admin User
variable "admin_username" {
  type        = string
  description = "Windows VM Admin User"
}

# Windows VM Admin Password
variable "admin_password" {
  type        = string
  description = "Windows VM Admin Password"
}


variable "sql_username" {
  type = string
  description = "The username of SQL admin user"
}

variable "sql_password" {
  type = string
  description = "The password of SQL admin user"
}


# Configure the Azure Provider
provider "azurerm" {
  subscription_id = var.subscription_id
  tenant_id       = var.tenant_id

  features {}
}

# Make RG in Central US
resource "azurerm_resource_group" "resource-group-one" {
  name     = "rgp-central-${var.project_id}-${var.environment}"
  location = "Central US"
}

# Create a virtual network within the resource group
resource "azurerm_virtual_network" "vnet_test" {
  name                = "vnet-${var.project_id}-${var.environment}"
  resource_group_name = azurerm_resource_group.resource-group-one.name
  location            = azurerm_resource_group.resource-group-one.location
  address_space       = ["10.50.0.0/16"]

  tags = {
    environment = "${var.environment}"
  }
}

resource "azurerm_subnet" "sql-subnet" {
  name                 = "SqlSubnet"
  resource_group_name  = azurerm_resource_group.resource-group-one.name
  virtual_network_name = azurerm_virtual_network.vnet_test.name
  address_prefixes     = ["10.50.2.0/24"]
  
}

/*
# Create Network Security Group to Access web VM from Internet
resource "azurerm_network_security_group" "web-windows-vm-nsg" {
  name                = "nsg-web-windows-vm-${var.project_id}-${var.environment}"
  location            = azurerm_resource_group.resource-group-one.location
  resource_group_name = azurerm_resource_group.resource-group-one.name

  security_rule {
    name                       = "allow-rdp"
    description                = "allow-rdp from any internal network"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "10.0.0.0/8"
    destination_address_prefix = "*" 
  }

security_rule {
    name                       = "allow-rdp-chicago-roki"
    description                = "allow-rdp-chicago-roki"
    priority                   = 101
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "76.229.200.36/32"
    destination_address_prefix = "*" 
  }


  tags = {
   # application = var.app_name
    environment = var.environment 
  }
}


module "win-vm" {
  source = "./win-vm"

  vm_name     = "windows-one"
  vm_rg_name  = azurerm_resource_group.resource-group-one.name 
  vm_location = azurerm_resource_group.resource-group-one.location
  vm_subnet_id= azurerm_subnet.sql-subnet.id
  vm_storage_type = "StandardSSD_LRS"
  environment = var.environment
  vm_size     = "Standard_B1s"
  project_id  = var.project_id
  admin_username = var.admin_username
  admin_password = var.admin_password
  network_security_group_id = azurerm_network_security_group.web-windows-vm-nsg.id

}
*/

# Create Network Security Group to Access web VM from Internet
resource "azurerm_network_security_group" "sql-windows-vm-nsg" {
  name                = "nsg-sql-win-vm-${var.project_id}-${var.environment}"
  location            = azurerm_resource_group.resource-group-one.location
  resource_group_name = azurerm_resource_group.resource-group-one.name

  security_rule {
    name                       = "allow-rdp"
    description                = "allow-rdp from any internal network"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "10.0.0.0/8"
    destination_address_prefix = "*" 
  }

security_rule {
    name                       = "allow-rdp-chicago-roki"
    description                = "allow-rdp-chicago-roki"
    priority                   = 105
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "76.229.200.36/32"
    destination_address_prefix = "*" 
  }


security_rule {
    name                       = "allow-sql-chicago-roki"
    description                = "allow-sql-chicago-roki"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "1433"
    source_address_prefix      = "76.229.200.36/32"
    destination_address_prefix = "*" 
  }

  tags = {
   # application = var.app_name
    environment = var.environment 
  }
}

module "win-vm-sql" {
  source = "./win-vm-sql"

  win_vm_sql_name  = "win-one-sql"
  vm_rg_name       = azurerm_resource_group.resource-group-one.name 
  vm_location      = azurerm_resource_group.resource-group-one.location
  vm_subnet_id     = azurerm_subnet.sql-subnet.id
  environment      = var.environment

  vm_storage_type  = "StandardSSD_LRS"

  os_image_publisher = "MicrosoftSQLServer"
  os_image_offer   = "SQL2017-WS2016"
  os_image_sku     = "SQLDEV"
  os_image_version = "latest"

  sql_username = var.sql_username
  sql_password = var.sql_password

  os_profile_windows_timezone = "Pacific Standard Time"

  vm_size     = "Standard_B2ms"
  project_id  = var.project_id

  admin_username = var.admin_username
  admin_password = var.admin_password
  network_security_group_id = azurerm_network_security_group.sql-windows-vm-nsg.id
}