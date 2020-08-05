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


