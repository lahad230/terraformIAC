output "vmPassword" {
    description = "admin password for the vms"
    value       = azurerm_linux_virtual_machine.Vm.admin_password
}