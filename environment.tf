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

variable "ad_domain" {
  type = string
  description = "AD Domain name"
  default = "alwayson.azure"
}

variable "ad_domain_netbios" {
  type = string
  description = "AD Domain netbios name"
  default = "alwayson"
}

variable "ad_sql_ou_path" {
  type = string
  description = "OU Path of SQL Servers"
  #default = "OU=SQLServers,DC=alwayson,DC=azure"
  default = ""
}


# Configure the Azure Provider
provider "azurerm" {
  subscription_id = var.subscription_id
  tenant_id       = var.tenant_id

  features {}
}

/* -----------------------------------------------------------------------
-
Storage accout for the Cloud Witness 
-
*/

resource "azurerm_resource_group" "rgp-witness" {
  name     = "rgp-east2-${var.project_id}-${var.environment}"
  location = "East US2"
}

resource "azurerm_storage_account" "witness-storage-account" {
  name                     = "saeast2${var.project_id}${var.environment}"
  resource_group_name      = azurerm_resource_group.rgp-witness.name
  location                 = azurerm_resource_group.rgp-witness.location
  account_tier             = "Standard"
  account_replication_type = "GRS"

  tags = {
    environment = var.environment
  }
}


/* -----------------------------------------------------------------------
-
Infrastructure in US Central
-
*/

# Make RG in Central US
resource "azurerm_resource_group" "resource-group-one" {
  name     = "rgp-central-${var.project_id}-${var.environment}"
  location = "Central US"
}

# Create a virtual network within the resource group
resource "azurerm_virtual_network" "vnet_one" {
  name                = "vnet-${var.project_id}-${var.environment}"
  resource_group_name = azurerm_resource_group.resource-group-one.name
  location            = azurerm_resource_group.resource-group-one.location
  address_space       = ["10.50.0.0/16"]

  tags = {
    environment = var.environment
  }
}

resource "azurerm_subnet" "def-subnet-one" {
  name                 = "def-subnet-one"
  resource_group_name  = azurerm_resource_group.resource-group-one.name
  virtual_network_name = azurerm_virtual_network.vnet_one.name
  address_prefixes     = ["10.50.2.0/24"]
  
}


resource "azurerm_subnet" "webapp-subnet-one" {
  name                 = "webapp-subnet-one"
  resource_group_name  = azurerm_resource_group.resource-group-one.name
  virtual_network_name = azurerm_virtual_network.vnet_one.name
  address_prefixes     = ["10.50.3.0/24"]

  delegation {
    name = "webapp-delegation"

    service_delegation {
      name    = "Microsoft.Web/serverFarms"
      actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
    }
  }
  
}


# Create Network Security Group to Access Win VM One from Internet
resource "azurerm_network_security_group" "nsg-win-vm-one" {
  name                = "nsg-win-vm-one-${var.project_id}-${var.environment}"
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


# Create Network Security Group to Access SQL VM 
resource "azurerm_network_security_group" "nsg-sql-win-vm-one" {
  name                = "nsg-sql-win-vm-one-${var.project_id}-${var.environment}"
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
/*
security_rule {
    name                       = "allow-sql-web-one"
    description                = "allow-sql-web-one"
    priority                   = 115
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "1433"
    source_address_prefixes      = split(",", azurerm_app_service.app_service_one.outbound_ip_addresses)
    destination_address_prefix = "*" 
  }


security_rule {
    name                       = "allow-sql-web-two"
    description                = "allow-sql-web-two"
    priority                   = 120
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "1433"
    source_address_prefixes      = split(",", azurerm_app_service.app_service_two.outbound_ip_addresses)
    destination_address_prefix = "*" 
  }
*/
  tags = {
   # application = var.app_name
    environment = var.environment 
  }
}

/* -----------------------------------------------------------------------
-
Load Balancer for SQL Server One
-
*/

/*
resource "azurerm_lb" "lb-sql-one" {
  name                = "lb-sql-one-${var.project_id}-${var.environment}"
  location            = azurerm_resource_group.resource-group-one.location
  resource_group_name = azurerm_resource_group.resource-group-one.name

  frontend_ip_configuration {

    name              = "lb-sql-one-ip"
    subnet_id         = azurerm_subnet.def-subnet-one.id
    private_ip_address = "10.50.2.240"
    private_ip_address_allocation = "Static"
  }

  tags = {
   # application = var.app_name
    environment = var.environment 
  }
}

resource "azurerm_lb_probe" "lb-sql-one-hp" {
  resource_group_name = azurerm_resource_group.resource-group-one.name
  loadbalancer_id     = azurerm_lb.lb-sql-one.id
  name                = "sql-server-access-probe"
  port                = 1433
}

resource "azurerm_lb_rule" "lb-sql-one-rule" {
  resource_group_name            = azurerm_resource_group.resource-group-one.name
  loadbalancer_id                = azurerm_lb.lb-sql-one.id
  name                           = "lb-sql-one-rule"
  protocol                       = "Tcp"
  frontend_port                  = 1433
  backend_port                   = 1433
  frontend_ip_configuration_name = "lb-sql-one-ip"

  #frontend_ip_configuration_name = "private"
  backend_address_pool_id        = azurerm_lb_backend_address_pool.lb-sql-one-address-pool.id
  probe_id                       = azurerm_lb_probe.lb-sql-one-hp.id
}


resource "azurerm_lb_backend_address_pool" "lb-sql-one-address-pool" {
  resource_group_name = azurerm_resource_group.resource-group-one.name
  loadbalancer_id     = azurerm_lb.lb-sql-one.id
  name                = "lb-sql-one-address-pool"
}

resource "azurerm_network_interface_backend_address_pool_association" "lb-sql-one-address-pool-ass" {
  network_interface_id    = module.win-one-sql.win-vm-sql-nic-id
  ip_configuration_name   = module.win-one-sql.win-vm-sql-nic-ip-conf-name
  backend_address_pool_id = azurerm_lb_backend_address_pool.lb-sql-one-address-pool.id
}
*/


module "win-vm-addc-one" {
  source = "./win-vm-addc"

  vm_name     = "windows-one"
  vm_rg_name  = azurerm_resource_group.resource-group-one.name 
  vm_location = azurerm_resource_group.resource-group-one.location
  vm_subnet_id= azurerm_subnet.def-subnet-one.id
  vm_storage_type = "StandardSSD_LRS"
  environment = var.environment
  vm_size     = "Standard_B2s"
  project_id  = var.project_id
  admin_username = var.admin_username
  admin_password = var.admin_password
  network_security_group_id = azurerm_network_security_group.nsg-win-vm-one.id
  
  dns_servers    = [ "10.50.2.254", "10.51.2.254"]
  #dns_servers    = [ "10.50.2.254", "10.51.2.254", "168.63.129.16"]

  vm_private_ip_address = "10.50.2.254"
  active_directory_domain = var.ad_domain
  active_directory_netbios_name = var.ad_domain_netbios
  ad_create = true
}

/* -----------------------------------------------------------------------
-
Infrastructure in US East
-
*/


# Make RG in East US
resource "azurerm_resource_group" "resource-group-two" {
  name     = "rgp-east-${var.project_id}-${var.environment}"
  location = "East US"
}

# Create a virtual network within the resource group
resource "azurerm_virtual_network" "vnet_two" {
  name                = "vnet-${var.project_id}-${var.environment}"
  resource_group_name = azurerm_resource_group.resource-group-two.name
  location            = azurerm_resource_group.resource-group-two.location
  address_space       = ["10.51.0.0/16"]

  tags = {
    environment = var.environment
  }
}

resource "azurerm_subnet" "def-subnet-two" {
  name                 = "def-subnet-two"
  resource_group_name  = azurerm_resource_group.resource-group-two.name
  virtual_network_name = azurerm_virtual_network.vnet_two.name
  address_prefixes     = ["10.51.2.0/24"]
  
}

resource "azurerm_subnet" "webapp-subnet-two" {
  name                 = "webapp-subnet-two"
  resource_group_name  = azurerm_resource_group.resource-group-two.name
  virtual_network_name = azurerm_virtual_network.vnet_two.name
  address_prefixes     = ["10.51.3.0/24"]

  delegation {
    name = "webapp-delegation"

    service_delegation {
      name    = "Microsoft.Web/serverFarms"
      actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
    }
  }
  
}

# Create Network Security Group to Access Win VM two from Internet
resource "azurerm_network_security_group" "nsg-win-vm-two" {
  name                = "nsg-win-vm-two-${var.project_id}-${var.environment}"
  location            = azurerm_resource_group.resource-group-two.location
  resource_group_name = azurerm_resource_group.resource-group-two.name

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


# Create Network Security Group to Access SQL VM 
resource "azurerm_network_security_group" "nsg-sql-win-vm-two" {
  name                = "nsg-sql-win-vm-two-${var.project_id}-${var.environment}"
  location            = azurerm_resource_group.resource-group-two.location
  resource_group_name = azurerm_resource_group.resource-group-two.name

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
/*
security_rule {
    name                       = "allow-sql-web-one"
    description                = "allow-sql-web-one"
    priority                   = 115
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "1433"
    source_address_prefixes      = split(",", azurerm_app_service.app_service_one.outbound_ip_addresses)
    destination_address_prefix = "*" 
  }


security_rule {
    name                       = "allow-sql-web-two"
    description                = "allow-sql-web-two"
    priority                   = 120
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "1433"
    source_address_prefixes      = split(",", azurerm_app_service.app_service_two.outbound_ip_addresses)
    destination_address_prefix = "*" 
  }
*/
  tags = {
   # application = var.app_name
    environment = var.environment 
  }
}


/* -----------------------------------------------------------------------
-
Load Balancer for SQL Server Two
-



resource "azurerm_lb" "lb-sql-two" {
  name                = "lb-sql-two-${var.project_id}-${var.environment}"
  location            = azurerm_resource_group.resource-group-two.location
  resource_group_name = azurerm_resource_group.resource-group-two.name

  frontend_ip_configuration {

    name              = "lb-sql-two-ip"
    subnet_id         = azurerm_subnet.def-subnet-two.id
    private_ip_address = "10.51.2.240"
    private_ip_address_allocation = "Static"
  }

  tags = {
   # application = var.app_name
    environment = var.environment 
  }
}

resource "azurerm_lb_probe" "lb-sql-two-hp" {
  resource_group_name = azurerm_resource_group.resource-group-two.name
  loadbalancer_id     = azurerm_lb.lb-sql-two.id
  name                = "sql-server-access-probe"
  port                = 1433
}

resource "azurerm_lb_rule" "lb-sql-two-rule" {
  resource_group_name            = azurerm_resource_group.resource-group-two.name
  loadbalancer_id                = azurerm_lb.lb-sql-two.id
  name                           = "lb-sql-two-rule"
  protocol                       = "Tcp"
  frontend_port                  = 1433
  backend_port                   = 1433
  frontend_ip_configuration_name = "lb-sql-two-ip"

  #frontend_ip_configuration_name = "private"
  backend_address_pool_id        = azurerm_lb_backend_address_pool.lb-sql-two-address-pool.id
  probe_id                       = azurerm_lb_probe.lb-sql-two-hp.id
}


resource "azurerm_lb_backend_address_pool" "lb-sql-two-address-pool" {
  resource_group_name = azurerm_resource_group.resource-group-two.name
  loadbalancer_id     = azurerm_lb.lb-sql-two.id
  name                = "lb-sql-two-address-pool"
}

resource "azurerm_network_interface_backend_address_pool_association" "lb-sql-two-address-pool-ass" {
  network_interface_id    = module.win-two-sql.win-vm-sql-nic-id
  ip_configuration_name   = module.win-two-sql.win-vm-sql-nic-ip-conf-name
  backend_address_pool_id = azurerm_lb_backend_address_pool.lb-sql-two-address-pool.id
}

*/

module "win-vm-addc-two" {

  depends_on=[module.win-vm-addc-one]

  source = "./win-vm-addc"

  vm_name     = "windows-two"
  vm_rg_name  = azurerm_resource_group.resource-group-two.name 
  vm_location = azurerm_resource_group.resource-group-two.location
  vm_subnet_id= azurerm_subnet.def-subnet-two.id
  vm_storage_type = "StandardSSD_LRS"
  environment = var.environment
  vm_size     = "Standard_B2s"
  project_id  = var.project_id
  admin_username = var.admin_username
  admin_password = var.admin_password
  network_security_group_id = azurerm_network_security_group.nsg-win-vm-two.id

  #dns_servers    = ["10.50.2.254", "10.51.2.254", "168.63.129.16"]
  dns_servers    = ["10.50.2.254", "10.51.2.254"]

  vm_private_ip_address = "10.51.2.254"
  active_directory_domain = var.ad_domain
  active_directory_netbios_name = var.ad_domain_netbios
  ad_create = false
}

/* 
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


resource "azurerm_app_service_plan" "app-service-plan-one" {
  name                = "app_service_plan-one-${var.project_id}-${var.environment}"
  location            = azurerm_resource_group.resource-group-one.location
  resource_group_name = azurerm_resource_group.resource-group-one.name

  sku {
    tier = "Standard"
    size = "S1"
  }
}

resource "azurerm_app_service" "app_service_one" {
  name                = "app-service-one-rokicool-2020"
  location            =  azurerm_resource_group.resource-group-one.location
  resource_group_name = azurerm_resource_group.resource-group-one.name
  app_service_plan_id = azurerm_app_service_plan.app-service-plan-one.id

  app_settings = {
    "SOME_KEY" = "some-value"
    "WEBSITE_DNS_SERVER"     = "10.50.2.254"
    "WEBSITE_DNS_ALT_SERVER" = "10.51.2.254"
  }

  connection_string {
    name  = "Database"
    type  = "SQLServer"
        value = "Data Source=10.50.2.4;Initial Catalog=DonNetAppSqlDb;User ID=${var.sql_username};Password=${var.sql_password}"
  }
}

resource "azurerm_app_service_virtual_network_swift_connection" "net_app_one" {
  app_service_id = azurerm_app_service.app_service_one.id
  subnet_id      = azurerm_subnet.webapp-subnet-one.id
}


resource "azurerm_app_service_plan" "app-service-plan-two" {
  name                = "app_service_plan-two-${var.project_id}-${var.environment}"
  location            = azurerm_resource_group.resource-group-two.location
  resource_group_name = azurerm_resource_group.resource-group-two.name

  sku {
    tier = "Standard"
    size = "S1"
  }
}

resource "azurerm_app_service" "app_service_two" {
  name                = "app-service-two-rokicool-2020"
  location            =  azurerm_resource_group.resource-group-two.location
  resource_group_name = azurerm_resource_group.resource-group-two.name
  app_service_plan_id = azurerm_app_service_plan.app-service-plan-two.id


  app_settings = {
    "SOME_KEY" = "some-value"
    "WEBSITE_DNS_SERVER"     = "10.51.2.254"
    "WEBSITE_DNS_ALT_SERVER" = "10.50.2.254"
  }

  connection_string {
    name  = "Database"
    type  = "SQLServer"
    value = "Data Source=10.51.2.4;Initial Catalog=DonNetAppSqlDb;User ID=${var.sql_username};Password=${var.sql_password}"
  }
}


resource "azurerm_app_service_virtual_network_swift_connection" "net_app_two" {
  app_service_id = azurerm_app_service.app_service_two.id
  subnet_id      = azurerm_subnet.webapp-subnet-two.id
}



/*

# Create Traffic Manager API Profile
resource "azurerm_traffic_manager_profile" "traffic-manager" {
  name                   = "tm-global-${var.project_id}-${var.environment}"
  resource_group_name    = azurerm_resource_group.resource-group-one.name
  traffic_routing_method = "Performance"

  dns_config {
    relative_name = "tm-global-${var.project_id}-${var.environment}"
    ttl           = 100
  }

  monitor_config {
    protocol = "http"
    port     = 80
    path     = "/"
  }
}

# Create Traffic Manager - East End Point
resource "azurerm_traffic_manager_endpoint" "tm-endpoint-one" {
  name                = "Gateway One"
  resource_group_name = azurerm_resource_group.resource-group-one.name
  profile_name        = azurerm_traffic_manager_profile.traffic-manager.name
  type                = "externalEndpoints"
  target              = "app-service-one-rokicool-2020.azurewebsites.net"
  endpoint_location   = azurerm_resource_group.resource-group-one.location
}

# Create Traffic Manager - East End Point
resource "azurerm_traffic_manager_endpoint" "tm-endpoint-two" {
  name                = "Gateway two"
  resource_group_name = azurerm_resource_group.resource-group-one.name
  profile_name        = azurerm_traffic_manager_profile.traffic-manager.name
  type                = "externalEndpoints"
  target              = "app-service-two-rokicool-2020.azurewebsites.net"
  endpoint_location   = azurerm_resource_group.resource-group-one.location
}
*/

/* -----------------------------------------------------------------------
-
VNet Peering
-
*/


# enable global peering between the two virtual network
resource "azurerm_virtual_network_peering" "peering-one-two" {
  name                         = "peering-one-to-two-${var.project_id}-${var.environment}"
  resource_group_name          = azurerm_resource_group.resource-group-one.name
  virtual_network_name         = azurerm_virtual_network.vnet_one.name
  remote_virtual_network_id    = azurerm_virtual_network.vnet_two.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = false

  # `allow_gateway_transit` must be set to false for vnet Global Peering
  allow_gateway_transit = false
}


# enable global peering between the two virtual network
resource "azurerm_virtual_network_peering" "peering-two-one" {
  name                         = "peering-two-to-one-${var.project_id}-${var.environment}"
  resource_group_name          = azurerm_resource_group.resource-group-two.name
  virtual_network_name         = azurerm_virtual_network.vnet_two.name
  remote_virtual_network_id    = azurerm_virtual_network.vnet_one.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = false

  # `allow_gateway_transit` must be set to false for vnet Global Peering
  allow_gateway_transit = false
}

/* -----------------------------------------------------------------------
-
SQL Servers
-
*/


module "win-one-sql" {
  depends_on=[module.win-vm-addc-one]
  source = "./win-vm-sql"

  win_vm_sql_name  = "win-one-sql"
  vm_rg_name       = azurerm_resource_group.resource-group-one.name 
  vm_location      = azurerm_resource_group.resource-group-one.location
  vm_subnet_id     = azurerm_subnet.def-subnet-one.id
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

  dns_servers    = ["10.50.2.254", "10.51.2.254"]

  admin_username = var.admin_username
  admin_password = var.admin_password
  network_security_group_id = azurerm_network_security_group.nsg-sql-win-vm-one.id

  active_directory_domain = var.ad_domain
  active_directory_oupath = var.ad_sql_ou_path
}


module "win-two-sql" {
  depends_on=[module.win-vm-addc-one]
  source = "./win-vm-sql"

  win_vm_sql_name  = "win-two-sql"
  vm_rg_name       = azurerm_resource_group.resource-group-two.name 
  vm_location      = azurerm_resource_group.resource-group-two.location
  vm_subnet_id     = azurerm_subnet.def-subnet-two.id
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

  dns_servers    = ["10.51.2.254", "10.50.2.254"]

  admin_username = var.admin_username
  admin_password = var.admin_password
  network_security_group_id = azurerm_network_security_group.nsg-sql-win-vm-two.id

  active_directory_domain = var.ad_domain

  active_directory_oupath = var.ad_sql_ou_path
}

output "SQL-one-IP" {
  value = module.win-one-sql.win_vm_sql_public_ip
}


output "SQL-two-IP" {
  value = module.win-two-sql.win_vm_sql_public_ip 
} 


# Windows VM Public IP
output "win-vm-addc-one_public_ip" {
  value = module.win-vm-addc-one.win_vm_public_ip
}

# Windows VM Public IP
output "win-vm-addc-two_public_ip" {
  value = module.win-vm-addc-two.win_vm_public_ip
}

#
output "witness-storage-account-key" {
  value = azurerm_storage_account.witness-storage-account.primary_access_key
}

#
output "witness-storage-account-primary_blob_connection_string" {
  value = azurerm_storage_account.witness-storage-account.primary_blob_connection_string
}