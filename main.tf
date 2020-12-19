terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = ">= 2.26"
    }
  }
}

provider "azurerm" {
  
  subscription_id = "fdc197e5-e589-473f-b7b2-12bd7cd2842a"
  client_id       = "bf0fe59d-8fa1-4d6d-86bc-9a2af68575ff"
  client_secret   = "h4OjIY.xs6EUTs-.zuLVNA-3O-JzoXm-yF"
  tenant_id       = "b1732512-60e5-48fb-92e8-8d6902ac1349"
  
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


resource "azurerm_virtual_machine" "devops" {
  name                = "virtual-machine"
  resource_group_name = azurerm_resource_group.devops.name
  location            = azurerm_resource_group.devops.location
  vm_size             = "Standard_DS1_v2"
  network_interface_ids = [
    azurerm_network_interface.devops.id,
  ]
  
  storage_os_disk {
    name = "OsDisk"
    caching       = "ReadWrite"
    create_option = "FromImage"
    managed_disk_type = "Premium_LRS"
  }
  
  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
  
 os_profile {
   computer_name  = "virtual-machine"
   admin_username = var.admin_username
   admin_password = var.admin_password
   }
  
  os_profile_linux_config {
    disable_password_authentication = false
    ssh_keys {
      path = "/home/david/.ssh/id_rsa.pub"
      key_data = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCnqOz6mp0AgNYpR1SMSOBHGYoFBrZXtN6HIDkd/uwwRv2mlL6qfq+NpkdogzZJn9I4V+J/8+XSXejO9zO2KgZ6L0QmqkkXj/J2pEV6Het2afkrXacrJafWOPY79qbQEkuXCV02hEqMUDNDqMwRzex6gMyCm+IYn/JcTFF1FQsWKQ76LhE0XJOC1X67PvRdE8JoGnGWNHJdP40/PsuFS/jlBAbzusbK3ay/qMTSs5/wEaY5YgLeaFMuApfZ011J2ad4XGKM8N2o7mT52POPXYAkOCLPo0GlOZJFbI8087jBRWosM0beyTytN4atKNkJkkJ5Y/sMpTefuQl0tCAWzSTX"
      }
    }
  
  }

variable "admin_username" {
  type = string
  default = "devOpsUser"
  }

variable "admin_password" {
  type = string
  default = "G0odh890iohASWE"
  }
