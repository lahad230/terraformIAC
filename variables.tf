variable "vmSize" {
  type        = string
  description = "size of both web vms and db vms."
}

variable "location" {
  type        = string
  description = "location of all the resources."
}

variable "username" {
  type        = string
  description = "all vms username."
}

variable "password" {
  type        = string
  description = "all vms passwords."
}

variable "resourceGroupName" {
  type        = string
  description = "main resource group name."
}

variable "vNet" {
  type        = map
  description = "name and cidr for Vnet."
}

variable "publicSubnet" {
  type        = map
  description = "public subnet cidr, name and associated nsg name."
}

variable "privateSubnet" {
  type        = map
  description = "private subnet cidr, name and associated nsg name."
}

variable "natPublicIpName" {
  type        = string
  description = "name for the public ip for the private subnet nat gateway."
}

variable "privateNat" {
  type        = string
  description = "name for private subnet nat gateway."
}

variable "publicLb" {
  type        = map
  description = "public load balancer details (name, front ip name and public ip name)."
}

variable "privateLb" {
  type        = map
  description = "private load balancer details (name, front ip name, private ip[remember: private ip depandes on the private subnet cidr])."
}