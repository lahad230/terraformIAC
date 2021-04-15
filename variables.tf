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
  description = "public subnet cidr and name. eg-> name ='mysubenet' cidr = '10.0.1.0/28'"
  type        = map
}

variable "privateSubnet" {
  description = "private subnet cidr and name. eg-> name ='mysubenet' cidr = '10.0.1.0/28'"
  type        = map
}

variable "privateNsg" {
  description = "name of the nsg associated with private subnet"
  type = string
}

variable "publicNsg" {
  description = "name of the nsg associated with public subnet"
  type = string
}

variable "privateNat" {
  description = "name for private subnet nat gateway."
  type        = string
}

variable "publicLb" {
  description = "public load balancer details (name and front ip name). eg-> name = 'publicLb' frontIpName = 'lbForntIp'"
  type        = map
}

variable "privateLb" {
  description = "private load balancer details (name, front ip name, private ip[remember: private ip depandes on the private subnet cidr] eg-> name = 'privateLb' frontIpName = 'privateFront' privateIp = '10.0.1.10')."
  type        = map
}

variable "numOfIps" {
  description = "number of public ips for the project"
  type = number
}

variable "numOfPublicVms" {
  description = "number of vms on the public subnet"
  type        = number
}

variable "numOfPrivateVms" {
  description = "number of vms on the private subnet"
  type        = number
}

variable "webNsgPorts" {
  description = "list of ports open on the public subnet's nsg"
  type = list
}

variable "dataNsgPorts" {
  description = "list of ports open on the private subnet's nsg"
  type = list
}