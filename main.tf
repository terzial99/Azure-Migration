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
resource "azurerm_network_security_group" "workload" {
  name                = "nsg-workload"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
resource "azurerm_subnet_network_security_group_association" "workload" {
  subnet_id                 = module.vnet.subnets["workload"].resource_id
  network_security_group_id = azurerm_network_security_group.workload.id
}
resource "azurerm_network_security_rule" "ad_tcp" {
  name                        = "Allow-AD-TCP"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_ranges     = ["53", "88", "135", "389", "445", "464", "636", "3268", "3269", "49152-65535"]
  source_address_prefix       = "VirtualNetwork"
  destination_address_prefix  = "VirtualNetwork"
  resource_group_name         = azurerm_resource_group.test.name
  network_security_group_name = azurerm_network_security_group.workload.name
}

resource "azurerm_network_security_rule" "ad_udp" {
  name                        = "Allow-AD-UDP"
  priority                    = 110
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Udp"
  source_port_range           = "*"
  destination_port_ranges     = ["53", "88", "123", "389", "464"]
  source_address_prefix       = "VirtualNetwork"
  destination_address_prefix  = "VirtualNetwork"
  resource_group_name         = azurerm_resource_group.test.name
  network_security_group_name = azurerm_network_security_group.workload.name
}
resource "azurerm_network_security_rule" "sql" {
  name                        = "Allow-SQL"
  priority                    = 120
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "1433"
  source_address_prefix       = "VirtualNetwork"
  destination_address_prefix  = "VirtualNetwork"
  resource_group_name         = azurerm_resource_group.test.name
  network_security_group_name = azurerm_network_security_group.workload.name
}
resource "azurerm_network_security_rule" "smb" {
  name                        = "Allow-SMB"
  priority                    = 130
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "445"
  source_address_prefix       = "VirtualNetwork"
  destination_address_prefix  = "VirtualNetwork"
  resource_group_name         = azurerm_resource_group.test.name
  network_security_group_name = azurerm_network_security_group.workload.name
}