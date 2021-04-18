terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=2.46.0"
    }
  }
}

#######Rg,Vnets, subnets and nsgs#######

module "projBase" {
  source = "./modules/projBase"
  resourceGroupName = var.resourceGroupName
  location          = var.location
  vNet              = var.vNet 
  publicSubnet      = var.publicSubnet
  privateSubnet     = var.privateSubnet  
}

#public subnet's nsg:
resource "azurerm_network_security_group" "web" {
  name                = var.publicNsg
  location            = module.projBase.rg_location
  resource_group_name = module.projBase.rg_name

  security_rule { 
    name                       = "ports"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_ranges    = var.webNsgPorts
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

#public subnet nsg association:
resource "azurerm_subnet_network_security_group_association" "publicNsg" {
  subnet_id                 = module.projBase.public_subnet_id
  network_security_group_id = azurerm_network_security_group.web.id
}

#private subnet's nsg:
resource "azurerm_network_security_group" "data" {
  name                = var.privateNsg
  location            = module.projBase.rg_location
  resource_group_name = module.projBase.rg_name

  security_rule {
    name                       = "ports"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_ranges    = var.dataNsgPorts
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

#private subnet nsg association:
resource "azurerm_subnet_network_security_group_association" "privateNsg" {
  subnet_id                 = module.projBase.private_subnet_id
  network_security_group_id = azurerm_network_security_group.data.id
}

##########Public ips##########

#public load balancer ip:
resource "azurerm_public_ip" "ip" {
  count               = var.numOfIps
  name                = "ip${count.index}"
  resource_group_name = module.projBase.rg_name
  location            = module.projBase.rg_location
  allocation_method   = "Static"
  sku                 = "Standard"
}

#######Nat gateways##########

#Private subnet's nat gateway:
resource "azurerm_nat_gateway" "nat" {
  name                    = var.privateNat
  location                = module.projBase.rg_location
  resource_group_name     = module.projBase.rg_name
}

#Nat gateway and public ip association:
resource "azurerm_nat_gateway_public_ip_association" "ipForNat" {
  nat_gateway_id       = azurerm_nat_gateway.nat.id
  public_ip_address_id = azurerm_public_ip.ip[0].id
}

#Nat gateway and private subnet association:
resource "azurerm_subnet_nat_gateway_association" "natForSubnet" {
  subnet_id      = module.projBase.private_subnet_id
  nat_gateway_id = azurerm_nat_gateway.nat.id
}

######VMs and NICs######
#VMs and nics hosting web application:
module "web" {
  source        = "./modules/linuxVm"
  count         = var.numOfPublicVms
  vm_name       = "web${count.index}"
  rg_name       = module.projBase.rg_name
  rg_location   = module.projBase.rg_location
  vm_size       = var.vmSize
  vm_username   = var.username
  vm_password   = var.password
  nic_name      = "webNic${count.index}"
  nic_conf_name = "webConf${count.index}"
  subnet_id     = module.projBase.public_subnet_id
}
 
#VMs and nics hosting database:
module "data" {
  source        = "./modules/linuxVm"
  count         = var.numOfPrivateVms
  vm_name       = "data${count.index}"
  rg_name       = module.projBase.rg_name
  rg_location   = module.projBase.rg_location
  vm_size       = var.vmSize
  vm_username   = var.username
  vm_password   = var.password
  nic_name      = "dataNic${count.index}"
  nic_conf_name = "dataConf${count.index}"
  subnet_id     = module.projBase.private_subnet_id
}

###########Load balancers, probes, pools and rules############

#public load balancer:
resource "azurerm_lb" "publicLb" {
  name                = var.publicLb.name
  location            = module.projBase.rg_location
  resource_group_name = module.projBase.rg_name
  sku                 = "Standard"

  frontend_ip_configuration {
    name                 = var.publicLb.frontIpName
    public_ip_address_id = azurerm_public_ip.ip[1].id
  }
}

#public load balancer backend pool:
resource "azurerm_lb_backend_address_pool" "publicLbPool" {
  loadbalancer_id = azurerm_lb.publicLb.id
  name            = "frontEndAddressPool"
}

#public load balancer pool associations:
resource "azurerm_network_interface_backend_address_pool_association" "web1Pool" {
  network_interface_id    = module.web[0].nic_id
  ip_configuration_name   = module.web[0].nic_if_conf_name
  backend_address_pool_id = azurerm_lb_backend_address_pool.publicLbPool.id
}

resource "azurerm_network_interface_backend_address_pool_association" "web2Pool" {
  network_interface_id    = module.web[1].nic_id
  ip_configuration_name   = module.web[1].nic_if_conf_name
  backend_address_pool_id = azurerm_lb_backend_address_pool.publicLbPool.id
}

#public load balancer outbound rule:
resource "azurerm_lb_outbound_rule" "publicLbOutbound" {
  resource_group_name     = module.projBase.rg_name
  loadbalancer_id         = azurerm_lb.publicLb.id
  name                    = "OutboundRule"
  protocol                = "Tcp"
  backend_address_pool_id = azurerm_lb_backend_address_pool.publicLbPool.id

  frontend_ip_configuration {
    name = azurerm_lb.publicLb.frontend_ip_configuration[0].name
  }
}

#public load balancer probe(health checks):
resource "azurerm_lb_probe" "publicLbProbe" {
  resource_group_name = module.projBase.rg_name
  loadbalancer_id     = azurerm_lb.publicLb.id
  name                = "8080-running-probe"
  port                = var.frontPort
}

#public load balancer load balancing rule:
resource "azurerm_lb_rule" "publicLbRule" {
  resource_group_name            = module.projBase.rg_name
  loadbalancer_id                = azurerm_lb.publicLb.id
  name                           = "PublicLBRule"
  protocol                       = "Tcp"
  frontend_port                  = var.frontPort
  backend_port                   = var.frontPort
  disable_outbound_snat          = true
  frontend_ip_configuration_name = azurerm_lb.publicLb.frontend_ip_configuration[0].name
  backend_address_pool_id        = azurerm_lb_backend_address_pool.publicLbPool.id
  probe_id                       = azurerm_lb_probe.publicLbProbe.id
}

#private load balancer:
resource "azurerm_lb" "privateLb" {
  name                = var.privateLb.name
  location            = module.projBase.rg_location
  resource_group_name = module.projBase.rg_name
  sku                 = "Standard"

  frontend_ip_configuration {
    name                          = var.privateLb.frontIpName
    subnet_id                     = module.projBase.private_subnet_id
    private_ip_address_allocation = "Static"
    private_ip_address            = var.privateLb.privateIp
  }
}

#private load balancer backend pool:
resource "azurerm_lb_backend_address_pool" "privateLbPool" {
  loadbalancer_id = azurerm_lb.privateLb.id
  name            = "backEndAddressPool"
}

#private load balancer pool associations:
resource "azurerm_network_interface_backend_address_pool_association" "data1Pool" {
  network_interface_id    = module.data[0].nic_id
  ip_configuration_name   = module.data[0].nic_if_conf_name
  backend_address_pool_id = azurerm_lb_backend_address_pool.privateLbPool.id
}

resource "azurerm_network_interface_backend_address_pool_association" "data2Pool" {
  network_interface_id    = module.data[1].nic_id
  ip_configuration_name   = module.data[1].nic_if_conf_name
  backend_address_pool_id = azurerm_lb_backend_address_pool.privateLbPool.id
}

#private load balancer probe(health checks):
resource "azurerm_lb_probe" "privateLbProbe" {
  resource_group_name = module.projBase.rg_name
  loadbalancer_id     = azurerm_lb.privateLb.id
  name                = "5432-running-probe"
  port                = var.backPort
}

#private load balancer load balancing rule:
resource "azurerm_lb_rule" "privateLbRule" {
  resource_group_name            = module.projBase.rg_name
  loadbalancer_id                = azurerm_lb.privateLb.id
  name                           = "privateLBRule"
  protocol                       = "Tcp"
  frontend_port                  = var.backPort
  backend_port                   = var.backPort
  frontend_ip_configuration_name = azurerm_lb.privateLb.frontend_ip_configuration[0].name
  backend_address_pool_id        = azurerm_lb_backend_address_pool.privateLbPool.id
  probe_id                       = azurerm_lb_probe.privateLbProbe.id
}