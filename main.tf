resource "azurerm_resource_group" "RG_1011" {
  name     = "database-rgg"
  location = "japaneast"
}

resource "azurerm_virtual_network" "vnet_1011" {
  name                = "database1-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.RG_1011.location
  resource_group_name = azurerm_resource_group.RG_1011.name
}

resource "azurerm_subnet" "subnet_1011" {
  name                 = "database1_net"
  resource_group_name  = azurerm_resource_group.RG_1011.name
  virtual_network_name = azurerm_virtual_network.vnet_1011.name
  address_prefixes     = ["10.0.2.0/24"]
depends_on = [ azurerm_virtual_network.vnet_1011 ]
}
resource "azurerm_public_ip" "pip_1011" {
  name                = "database1_ip"
  resource_group_name = azurerm_resource_group.RG_1011.name
  location            = azurerm_resource_group.RG_1011.location
  allocation_method   = "Static"
}
resource "azurerm_network_interface" "NIC_1011" {
  name                = "database1-nic"
  location            = azurerm_resource_group.RG_1011.location
  resource_group_name = azurerm_resource_group.RG_1011.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet_1011.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.pip_1011.id
  }
}

resource "azurerm_linux_virtual_machine" "vm_1011" {
  name                = "database1-machine"
  resource_group_name = azurerm_resource_group.RG_1011.name
  location            = azurerm_resource_group.RG_1011.location
  size                = "Standard_F2"
  admin_username      = "adminuser"
  admin_password = "Admin@123456"
  disable_password_authentication = false
  network_interface_ids = [
    azurerm_network_interface.NIC_1011.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
}