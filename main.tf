terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = ">= 2.26"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "devops" {
  name     = "devops_2020"
  location = "West Europe"
}

resource "azurerm_virtual_network" "devops" {
  name                = "network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.devops.location
  resource_group_name = azurerm_resource_group.devops.name
}

resource "azurerm_subnet" "devops" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.devops.name
  virtual_network_name = azurerm_virtual_network.devops.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_network_interface" "devops" {
  name                = "network-interface"
  location            = azurerm_resource_group.devops.location
  resource_group_name = azurerm_resource_group.devops.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.devops.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "tls_private_key" "example_ssh" {
  algorithm = "RSA"
  rsa_bits = 4096
}

output "tls_private_key" { value = tls_private_key.example_ssh.private_key_pem }

resource "azurerm_linux_virtual_machine" "devops" {
  name                = "virtual-machine"
  resource_group_name = azurerm_resource_group.devops.name
  location            = azurerm_resource_group.devops.location
  size                = "Standard_F2"
  admin_username      = "adminuser"
  network_interface_ids = [
    azurerm_network_interface.devops.id,
  ]

  admin_ssh_key {
    username   = "adminuser"
    public_key = tls_private_key.example_ssh.private_key_pem 
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
}
