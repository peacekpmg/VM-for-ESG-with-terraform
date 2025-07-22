# Output the resource group name
output "resource_group_name" {
  description = "The name of the resource group"
  value       = azurerm_resource_group.rg.name
}

# Output the public/private IP addresses (private here)
output "vm_private_ip" {
  description = "Private IP address of the VM"
  value       = azurerm_network_interface.nic.private_ip_address
}

# Output the VM name
output "vm_name" {
  description = "The Windows VM name"
  value       = azurerm_windows_virtual_machine.vm.name
}

# Output the Log Analytics Workspace ID
output "log_analytics_workspace_id" {
  description = "ID of the Log Analytics workspace"
  value       = azurerm_log_analytics_workspace.law.id
}
