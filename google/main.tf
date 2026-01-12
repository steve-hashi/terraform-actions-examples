terraform {
//  required_version = "~> v1.14.0"
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
    }
  }
  cloud { 
    organization = "team-tf-actions-test-org" 
    workspaces { 
      name = "steve-azurerm-demo" 
    } 
  } 
}

provider "azurerm" {
  features {
  virtual_machine {
      detach_implicit_data_disk_on_deletion = false
      delete_os_disk_on_deletion            = true
      skip_shutdown_and_force_delete        = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "steve-demo"
  location = "eastus"
}

resource "azurerm_virtual_network" "test" {
  name                = "steve-demo"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_subnet" "test" {
  name                 = "steve-demo"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_network_interface" "example" {
  name                = "example"
  resource_group_name = azurerm_resource_group.test.name
  location            = "eastus"
  ip_configuration {
    name                          = "steve-demo"
    subnet_id                     = azurerm_subnet.test.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "example"  {
  name                = "example-machine"
  resource_group_name = azurerm_resource_group.test.name
  location            = "eastus"
  size                = "Standard_F2"
  admin_username      = "adminuser"
  admin_password      = "P@ssw0rd1234!"
  network_interface_ids = [
    azurerm_network_interface.example.id,
  ]
  disable_password_authentication = false

/*  admin_ssh_key {
    username   = "adminuser"
    public_key = file("~/.ssh/id_rsa.pub")
  } */
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
  lifecycle {
    action_trigger {
      events  = [after_create]
      actions = [action.azurerm_virtual_machine_power.stop]
    }
  }
}

action "azurerm_virtual_machine_power" "stop" {
  config {
    virtual_machine_id = azurerm_linux_virtual_machine.example.id
    power_action       = "power_off"
  }
}

action "azurerm_virtual_machine_power" "start" {
  config {
    virtual_machine_id = azurerm_linux_virtual_machine.example.id
    power_action       = "power_on"
  }
}

action "azurerm_virtual_machine_power" "restart" {
  config {
    virtual_machine_id = azurerm_linux_virtual_machine.example.id
    power_action       = "restart"
  }
}