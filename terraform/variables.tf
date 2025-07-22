# Name of the Azure resource group
variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

# Azure region to deploy resources
variable "location" {
  description = "Azure location"
  type        = string
  default     = "East US"
}

# Admin username for the Windows VM
variable "vm_admin_username" {
  description = "Admin username for VM"
  type        = string
}

# Admin password for the Windows VM (marked sensitive)
variable "vm_admin_password" {
  description = "Admin password for VM"
  type        = string
  sensitive   = true
}

# Size of the VM instance
variable "vm_size" {
