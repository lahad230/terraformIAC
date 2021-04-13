vmSize = "Standard_B2s"
location = "Germany West Central"
username = "lahad230"
password = "8426Rl6248"
resourceGroupName = "terraProject"
vNet = {
    name = "vNet"
    cidr = "10.0.0.0/16"
}
publicSubnet = {
    name = "publicSubnet"
    cidr = "10.0.0.0/28"
    nsgName = "webNsg"
}
privateSubnet = {
    name = "privateSubnet"
    cidr = "10.0.1.0/28"
    nsgName = "dataNsg"
}
natPublicIpName = "NatPublicIp"
privateNat = "privateNat"
publicLb = {
    name = "publicLb"
    ipName = "public_lb_ip"
    frontIpName = "publicLbFront"
}
privateLb = {
    name = "privateLb"
    frontIpName = "privateLbFront"
    privateIp = "10.0.1.10"
}