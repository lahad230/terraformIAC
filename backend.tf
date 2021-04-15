# terraform {
#   backend "azurerm" {
#     resource_group_name  = "terraProject"
#     storage_account_name = "stateAccount"
#     container_name       = "state"
#     key                  = "prod.terraform.tfstate"
#   }
# }

# resource "azurerm_storage_account" "storage_account" {
#   name                     = "stateAccount"
#   resource_group_name      = azurerm_resource_group.rg.name
#   location                 = azurerm_resource_group.rg.location
#   account_tier             = "Standard"
#   account_replication_type = "GRS"
#   account_kind             = "BlobStorage"
# }

# resource "azurerm_storage_container" "state" {
#   name                  = "state"
#   storage_account_name  = azurerm_storage_account.storage_account.name
# }