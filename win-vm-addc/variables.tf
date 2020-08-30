

##############
## OS Image ##
##############

# Windows Server 2019 SKU used to build VMs
variable "windows-2019-sku" {
  type        = string
  description = "Windows Server 2019 SKU used to build VMs"
  default     = "2019-Datacenter"
}

# Windows Server 2016 SKU used to build VMs
variable "windows-2016-sku" {
  type        = string
  description = "Windows Server 2016 SKU used to build VMs"
  default     = "2016-Datacenter"
}

# Windows Server 2012 R2 SKU used to build VMs
variable "windows-2012-sku" {
  type        = string
  description = "Windows Server 2012 R2 SKU used to build VMs"
  default     = "2012-R2-Datacenter"
}


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

variable "vm_private_ip_address" {
  type = string
  description = "Private IP address"
}

variable "dns_servers" {
  description = "List of DNS servers"
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

variable "active_directory_domain" {
  description = "The name of the Active Directory domain, for example `consoto.local`"
}

variable "active_directory_netbios_name" {
  description = "The netbios name of the Active Directory domain, for example `consoto`"
}

variable "ad_create" {
  description = "Boolean var to create or join the AD doman"
}