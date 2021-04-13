output "vmPassword" {
    description = "admin password for the vms"
    value       = azurerm_linux_virtual_machine.web1.admin_password
}