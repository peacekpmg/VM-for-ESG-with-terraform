terraform {
  required_version = ">= 1.3.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }

  # Configure remote backend for Terraform state storage with better naming
  backend "azurerm" {
    resource_group_name  = "infra-state-rg"
    storage_account_name = "infraStateStorage"
    container_name       = "terraform-state"
    key                  = "esg-platform-infra.tfstate"
  }
}

provider "azurerm" {
  features {}
}

# Create the Azure resource group for all resources
resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

# Create a virtual network for the VM environment
resource "azurerm_virtual_network" "vnet" {
  name                = "${var.resource_group_name}-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  tags                = var.tags
}

# Create a subnet within the virtual network
resource "azurerm_subnet" "subnet" {
  name                 = "${var.resource_group_name}-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Define a network security group to restrict inbound traffic
resource "azurerm_network_security_group" "nsg" {
  name                = "${var.resource_group_name}-nsg"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  # Allow RDP access only from the virtual network subnet
  security_rule {
    name                       = "RDP"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "10.0.0.0/24"
    destination_address_prefix = "*"
  }
}

# Create a network interface attached to the subnet and NSG
resource "azurerm_network_interface" "nic" {
  name                = "${var.resource_group_name}-nic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
  }

  network_security_group_id = azurerm_network_security_group.nsg.id
  tags                      = var.tags
}

# Provision a Windows VM attached to the network interface
resource "azurerm_windows_virtual_machine" "vm" {
  name                  = "${var.resource_group_name}-vm"
  resource_group_name   = azurerm_resource_group.rg.name
  location              = azurerm_resource_group.rg.location
  size                  = var.vm_size
  admin_username        = var.vm_admin_username
  admin_password        = var.vm_admin_password
  network_interface_ids = [azurerm_network_interface.nic.id]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  # Configure Windows VM agent and automatic updates
  os_profile_windows_config {
    provision_vm_agent       = true
    enable_automatic_updates = true
  }

  tags = var.tags
}

# Create a Log Analytics workspace for monitoring diagnostics
resource "azurerm_log_analytics_workspace" "law" {
  name                = "${var.resource_group_name}-law"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
  tags                = var.tags
}

# Enable diagnostic logging from the VM to the Log Analytics workspace
resource "azurerm_monitor_diagnostic_setting" "vm_diagnostics" {
  name                       = "${var.resource_group_name}-diag"
  target_resource_id         = azurerm_windows_virtual_machine.vm.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.law.id

  log {
    category = "Administrative"
    enabled  = true

    retention_policy {
      enabled = true
      days    = 30
    }
  }
}
