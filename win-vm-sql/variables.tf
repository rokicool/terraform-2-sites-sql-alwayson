#######################################
## Windows VM   SQL    Server - Main ##
#######################################


variable "win_vm_sql_name" {
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

variable "os_image_publisher" {
  type = string
  description = "Storage image publisher"
  default = "MicrosoftSQLServer"
}

variable "os_image_offer" {
  type = string
  description = "Storage image Offer"
}

variable "os_image_sku" {
  type = string
  description = "Storage image SKU"
}

variable "os_image_version" {
  type = string
  description = "Storage image version"
}

variable "os_profile_windows_timezone" {
  type = string
  description = "Timezone of the win sql server"
  # "Pacific Standard Time"
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

variable "sql_username" {
  type = string
  description = "The username of SQL admin user"
}

variable "sql_password" {
  type = string
  description = "The password of SQL admin user"
}

variable "dns_servers" {
  description = "List of DNS servers"
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


variable "active_directory_oupath" {
  description = "The name of the OU to put the machine to, for example `OU=Servers,DC=consoto,DC=local`"
}