terraform {
  required_version = ">=0.14.10"
}

resource "azurerm_network_interface" "nic" {
  name                = var.nic_name
  location            = var.rg_location
  resource_group_name = var.rg_name

  ip_configuration {
    name                          = var.nic_conf_name
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "Vm" {
  name                = var.vm_name
  resource_group_name = var.rg_name
  location            = var.rg_location
  size                = var.vm_size
  admin_username      = var.vm_username
  admin_password      = var.vm_password

  disable_password_authentication = false
  
  network_interface_ids = [
    azurerm_network_interface.nic.id
  ]

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

  provisioner "file" {
    source      = "../../../scripts/front.sh"
    destination = "/tmp/front.sh"

    connection {
      type     = "ssh"
      user     = var.vm_name
      password = var.vm_password
      host     = var.host
    }
  }

  provisioner "remote-exec" {
    inline = [
      "bash /tmp/front.sh"
    ]
    connection {
      type     = "ssh"
      user     = var.vm_name
      password = var.vm_password
      host     = var.host
    }
  }
}