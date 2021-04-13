variable "vmSize" {
  type    = string
  default = "Standard_B2s"
  description = "size of both web vms and db vms."
}

variable "location" {
  type    = string
  default = "Germany West Central"
  description = "location of all the resources."
}

variable "username" {
  type    = string
  default = "lahad230"
  description = "all vms username."
}

variable "password" {
  type    = string
  default = "8426Rl6248"
  description = "all vms passwords."
}

variable "resourceGroupName" {
  type    = string
  default = "terraProject"
  description = "main resource group name."
}

variable "vNet" {
  default = {
      name = "vNet"
      cidr = "10.0.0.0/16"
  } 
  description = "name and cidr for Vnet."
}

variable "publicSubnet" {

  default = {
      name = "publicSubnet"
      cidr = "10.0.0.0/28"
      nsgName = "webNsg"
  }
  description = "public subnet cidr, name and associated nsg name."
}

variable "privateSubnet" {
  default = {
      name = "privateSubnet"
      cidr = "10.0.1.0/28"
      nsgName = "dataNsg"
  }
  description = "private subnet cidr, name and associated nsg name."
}

variable "natPublicIpName" {
  type = string
  description = "name for the public ip for the private subnet nat gateway."
  default = "NatPublicIp"
}

variable "privateNat" {
  type = string
  description = "name for private subnet nat gateway."
  default = "privateNat"
}

variable "publicLb" {
  default = {
      name = "publicLb"
      ipName = "public_lb_ip"
      frontIpName = "publicLbFront"
  }
  description = "public load balancer details (name, front ip name and public ip name)."
}

variable "privateLb" {
  default = {
      name = "privateLb"
      frontIpName = "privateLbFront"
      privateIp = "10.0.1.10"
  }
  description = "private load balancer details (name, front ip name, private ip[remember: private ip depandes on the private subnet cidr])."
}