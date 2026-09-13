resource "azurerm_resource_group" "test" {
  name     = "rg-terraform-test"
  location = "Canada Central"
}
module "vnet" {
  source  = "Azure/avm-res-network-virtualnetwork/azurerm"
  version = "0.17.0"

  name      = "vnet-azure-migration"
  location  = azurerm_resource_group.test.location
  parent_id = azurerm_resource_group.test.id

  address_space = ["10.10.0.0/16"]

  subnets = {
    workload = {
      name             = "snet-workload"
      address_prefixes = ["10.10.1.0/24"]
    }
  }
}