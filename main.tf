terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=2.55.0"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg" {
  name     = var.resourceGroupName
  location = var.location
}

resource "azurerm_network_security_group" "web" {
  name                = var.publicSubnet.nsgName
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule { 
    name                       = "8080"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "8080"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "ssh"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule{
    name                       = "http"
    priority                   = 200
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  
  security_rule{
    name                       = "https"
    priority                   = 300
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_security_group" "data" {
  name                = var.privateSubnet.nsgName
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "postgre"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "5432"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "ssh"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule{
    name                       = "https"
    priority                   = 300
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_virtual_network" "vnet" {
  name                = var.vNet.name
  address_space       = [var.vNet.cidr]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "publicSubnet" {
  name                 = var.publicSubnet.name
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.publicSubnet.cidr]
}

resource "azurerm_subnet" "privateSubnet" {
  name                 = var.privateSubnet.name
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.privateSubnet.cidr]
}

resource "azurerm_subnet_network_security_group_association" "publicNsg" {
  subnet_id                 = azurerm_subnet.publicSubnet.id
  network_security_group_id = azurerm_network_security_group.web.id
}

resource "azurerm_subnet_network_security_group_association" "privateNsg" {
  subnet_id                 = azurerm_subnet.privateSubnet.id
  network_security_group_id = azurerm_network_security_group.data.id
}

resource "azurerm_public_ip" "ip" {
  name                = var.publicLb.ipName
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  allocation_method   = "Static"
  sku                 = "Standard"
}


resource "azurerm_network_interface" "web1nic" {
  name                = "web1nic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "web1conf"
    subnet_id                     = azurerm_subnet.publicSubnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_network_interface" "web2nic" {
  name                = "web2nic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "web2conf"
    subnet_id                     = azurerm_subnet.publicSubnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_network_interface" "data1nic" {
  name                = "data1nic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "data1conf"
    subnet_id                     = azurerm_subnet.privateSubnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_network_interface" "data2nic" {
  name                = "data2nic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "data2conf"
    subnet_id                     = azurerm_subnet.privateSubnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "web1" {
  name                = "web1"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = var.vmSize
  admin_username      = var.username
  admin_password      = var.password

  disable_password_authentication = false

  network_interface_ids = [
    azurerm_network_interface.web1nic.id,
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

resource "azurerm_linux_virtual_machine" "web2" {
  name                = "web2"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = var.vmSize
  admin_username      = var.username  
  admin_password      = var.password

  disable_password_authentication = false

  network_interface_ids = [
    azurerm_network_interface.web2nic.id,
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

resource "azurerm_linux_virtual_machine" "data1" {
  name                = "data1"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = var.vmSize
  admin_username      = var.username
  admin_password      = var.password

  disable_password_authentication = false
  
  network_interface_ids = [
    azurerm_network_interface.data1nic.id,
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

resource "azurerm_linux_virtual_machine" "data2" {
  name                = "data2"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = var.vmSize
  admin_username      = var.username
  admin_password      = var.password

  disable_password_authentication = false
  
  network_interface_ids = [
    azurerm_network_interface.data2nic.id,
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

resource "azurerm_lb" "publicLb" {
  name                = var.publicLb.name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "Standard"

  frontend_ip_configuration {
    name                 = var.publicLb.frontIpName
    public_ip_address_id = azurerm_public_ip.ip.id
  }
}

resource "azurerm_lb_backend_address_pool" "publicLbPool" {
  loadbalancer_id = azurerm_lb.publicLb.id
  name            = "frontEndAddressPool"
}

resource "azurerm_network_interface_backend_address_pool_association" "web1Pool" {
  network_interface_id    = azurerm_network_interface.web1nic.id
  ip_configuration_name   = azurerm_network_interface.web1nic.ip_configuration[0].name
  backend_address_pool_id = azurerm_lb_backend_address_pool.publicLbPool.id
}

resource "azurerm_network_interface_backend_address_pool_association" "web2Pool" {
  network_interface_id    = azurerm_network_interface.web2nic.id
  ip_configuration_name   = azurerm_network_interface.web2nic.ip_configuration[0].name
  backend_address_pool_id = azurerm_lb_backend_address_pool.publicLbPool.id
}

resource "azurerm_lb_outbound_rule" "publicLbOutbound" {
  resource_group_name     = azurerm_resource_group.rg.name
  loadbalancer_id         = azurerm_lb.publicLb.id
  name                    = "OutboundRule"
  protocol                = "Tcp"
  backend_address_pool_id = azurerm_lb_backend_address_pool.publicLbPool.id

  frontend_ip_configuration {
    name = azurerm_lb.publicLb.frontend_ip_configuration[0].name
  }
}

resource "azurerm_lb_probe" "publicLbProbe" {
  resource_group_name = azurerm_resource_group.rg.name
  loadbalancer_id     = azurerm_lb.publicLb.id
  name                = "8080-running-probe"
  port                = 8080
}

resource "azurerm_lb_rule" "publicLbRule" {
  resource_group_name            = azurerm_resource_group.rg.name
  loadbalancer_id                = azurerm_lb.publicLb.id
  name                           = "PublicLBRule"
  protocol                       = "Tcp"
  frontend_port                  = 8080
  backend_port                   = 8080
  disable_outbound_snat          = true
  frontend_ip_configuration_name = azurerm_lb.publicLb.frontend_ip_configuration[0].name
  backend_address_pool_id        = azurerm_lb_backend_address_pool.publicLbPool.id
  probe_id                       = azurerm_lb_probe.publicLbProbe.id
}

resource "azurerm_lb" "privateLb" {
  name                = var.privateLb.name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "Standard"

  frontend_ip_configuration {
    name                 = var.privateLb.frontIpName
    subnet_id = azurerm_subnet.privateSubnet.id
    private_ip_address_allocation = "Static"
    private_ip_address = var.privateLb.privateIp
  }
}

resource "azurerm_lb_backend_address_pool" "privateLbPool" {
  loadbalancer_id = azurerm_lb.privateLb.id
  name            = "backEndAddressPool"
}

resource "azurerm_network_interface_backend_address_pool_association" "data1Pool" {
  network_interface_id    = azurerm_network_interface.data1nic.id
  ip_configuration_name   = azurerm_network_interface.data1nic.ip_configuration[0].name
  backend_address_pool_id = azurerm_lb_backend_address_pool.privateLbPool.id
}

resource "azurerm_network_interface_backend_address_pool_association" "data2Pool" {
  network_interface_id    = azurerm_network_interface.data2nic.id
  ip_configuration_name   = azurerm_network_interface.data2nic.ip_configuration[0].name
  backend_address_pool_id = azurerm_lb_backend_address_pool.privateLbPool.id
}

resource "azurerm_lb_probe" "privateLbProbe" {
  resource_group_name = azurerm_resource_group.rg.name
  loadbalancer_id     = azurerm_lb.privateLb.id
  name                = "5432-running-probe"
  port                = 5432
}

resource "azurerm_lb_rule" "privateLbRule" {
  resource_group_name            = azurerm_resource_group.rg.name
  loadbalancer_id                = azurerm_lb.privateLb.id
  name                           = "privateLBRule"
  protocol                       = "Tcp"
  frontend_port                  = 5432
  backend_port                   = 5432
  frontend_ip_configuration_name = azurerm_lb.privateLb.frontend_ip_configuration[0].name
  backend_address_pool_id        = azurerm_lb_backend_address_pool.privateLbPool.id
  probe_id                       = azurerm_lb_probe.privateLbProbe.id
}