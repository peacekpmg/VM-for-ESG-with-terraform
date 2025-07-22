# Name of the Azure resource group
variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

# Azure region to deploy resources
variable "location" {
  description = "Azure region for all resources"
  type        = string
  default     = "East US"
}

# Admin username for the Windows VM
variable "vm_admin_username" {
  description = "Admin username for the Windows VM"
  type        = string
}

# Admin password for the Windows VM
variable "vm_admin_password" {
  description = "Admin password for the Windows VM"
  type        = string
  sensitive   = true
}

# VM size (SKU) for the Windows VM
variable "vm_size" {
  description = "Azure VM size"
  type        = string
  default     = "Standard_DS2_v2"
}

# Tags applied to all resources
variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {
    environment = "production"
    project     = "esg-platform"
  }
}
