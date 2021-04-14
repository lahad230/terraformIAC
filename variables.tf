variable "vmSize" {
  description = "size of both web vms and db vms."
  type        = string
  default     = "Standard_B2s"
}

variable "location" {
  description = "location of all the resources. eg-> Germany West Central"
  type        = string
}

variable "username" {
  description = "all vms username. eg-> myUsername"
  type        = string
}

variable "password" {
  description = "all vms passwords. eg->sTRongPasswoRd"
  type        = string
}

variable "resourceGroupName" {
  description = "main resource group name."
  type        = string
}

variable "vNet" {
  description = "name and cidr for Vnet. eg-> name = 'Vnet' cidr = '10.0.0.0/16'" 
  type        = map
}

variable "publicSubnet" {
  description = "public subnet cidr, name and associated nsg name. eg-> name ='mysubenet' cidr = '10.0.1.0/28' nsgName = 'nsgForsubnet'"
  type        = map
}

variable "privateSubnet" {
  description = "private subnet cidr, name and associated nsg name."
  type        = map
}

variable "privateNat" {
  description = "name for private subnet nat gateway."
  type        = string
}

variable "natPublicIpName" {
  description = "name for the public ip for the private subnet nat gateway."
  type        = string
}

variable "publicLb" {
  description = "public load balancer details (name, front ip name and public ip name). eg-> name = 'publicLb' ipName = 'lbIp' frontIpName = 'lbForntIp'"
  type        = map
}

variable "privateLb" {
  description = "private load balancer details (name, front ip name, private ip[remember: private ip depandes on the private subnet cidr] eg-> name = 'privateLb' frontIpName = 'privateFront' privateIp = '10.0.1.10')."
  type        = map
}