terraform {
  required_version = ">=0.14.10"
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
    var.nic_id
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
}