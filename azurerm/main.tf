terraform {
  required_version = "~> v1.14.0"
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "4.45.1"
    }
  }
}


resource "azurerm_linux_virtual_machine" "example"  {
  name                = "example-machine"
  resource_group_name = "ex-rg"
  location            = "ex-loc"
  size                = "Standard_F2"
  admin_username      = "adminuser"
  network_interface_ids = [
    azurerm_network_interface.example.id,
  ]
  admin_ssh_key {
    username   = "adminuser"
    public_key = file("~/.ssh/id_rsa.pub")
  }
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
}

resource "azurerm_network_interface" "example" {
  name                = "example"
  resource_group_name = "ex-rg"
  location            = "ex-loc"
  ip_configuration {
    name                          = "internal"
    subnet_id                     = "sn-id"
    private_ip_address_allocation = "Dynamic"
  }
}

resource "terraform_data" "example" {
  input = azurerm_network_interface.example.private_ip_address
  lifecycle {
    action_trigger {
      events  = [after_update]
      actions = [action.azurerm_virtual_machine_power.example]
    }
  }
}

action "azurerm_virtual_machine_power" "example" {
  config {
    virtual_machine_id = azurerm_linux_virtual_machine.example.id
    power_action       = "restart"
  }
}