provider "azurerm" {
  version = "2.0.0"
  features {}
}


resource "azurerm_resource_group" "test" {
 name     = "acctestrg"
 location = "West US 2"
}

resource "azurerm_virtual_network" "test" {
 name                = "acctvn"
 address_space       = ["10.0.0.0/16"]
 location            = azurerm_resource_group.test.location
 resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_subnet" "test" {
 name                 = "acctsub"
 resource_group_name  = azurerm_resource_group.test.name
 virtual_network_name = azurerm_virtual_network.test.name
 address_prefix       = "10.0.2.0/24"
}

resource "azurerm_public_ip" "test" {
 count                        = 2
 name                         = "publicIP${count.index}"
 location                     = azurerm_resource_group.test.location
 resource_group_name          = azurerm_resource_group.test.name
 allocation_method            = "Dynamic"
}


resource "azurerm_network_interface" "test" {
 count               = 2
 name                = "acctni${count.index}"
 location            = azurerm_resource_group.test.location
 resource_group_name = azurerm_resource_group.test.name

 ip_configuration {
   name                          = "testConfiguration"
   subnet_id                     = azurerm_subnet.test.id
   private_ip_address_allocation = "dynamic"
   public_ip_address_id          = "${azurerm_public_ip.test[count.index].id}"
 }
}



resource "azurerm_network_security_group" "nsg" {
    name                = "NetworkSecurityGroup"
    location            = azurerm_resource_group.test.location
    resource_group_name = azurerm_resource_group.test.name
    security_rule {
        name                       = "SSH"
        priority                   = 1001
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }
}


resource "azurerm_network_interface_security_group_association" "test" {
    count = length(azurerm_network_interface.test)
    network_interface_id      = "${azurerm_network_interface.test[count.index].id}"
    network_security_group_id = azurerm_network_security_group.nsg.id
}




resource "azurerm_virtual_machine" "test" {
 count                 = 2
 name                  = "acctvm${count.index}"
 location              = azurerm_resource_group.test.location
 resource_group_name   = azurerm_resource_group.test.name
 network_interface_ids = [element(azurerm_network_interface.test.*.id, count.index)]
 vm_size               = "Standard_DS1_v2"


 storage_image_reference {
   publisher = "Canonical"
   offer     = "UbuntuServer"
   sku       = "16.04-LTS"
   version   = "latest"
 }

 storage_os_disk {
   name              = "myosdisk${count.index}"
   caching           = "ReadWrite"
   create_option     = "FromImage"
   managed_disk_type = "Standard_LRS"
 }

 os_profile {
   computer_name  = "hashil-vm"
   admin_username = "testadmin"
   admin_password = "Password1234!"
 }

 os_profile_linux_config {
   disable_password_authentication = false
 }

 tags = {
   environment = "test"
 }
}
