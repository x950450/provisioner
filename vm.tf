variable "prefix" {
  default = "tobedeletedd"
}

resource "azurerm_resource_group" "tobedeleted" {
  name     = "${var.prefix}-resources"
  location = "West US 2"
}


resource "azurerm_virtual_network" "avnet" {
  name                = "${var.prefix}-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.tobedeleted.location
  resource_group_name = azurerm_resource_group.tobedeleted.name
}

resource "azurerm_subnet" "inteasubnetrnal" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.tobedeleted.name
  virtual_network_name = azurerm_virtual_network.avnet.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_public_ip" "pips" {
  name                = "acceptanceTestPublicIp1"
  resource_group_name = azurerm_resource_group.tobedeleted.name
  location            = azurerm_resource_group.tobedeleted.location
  allocation_method   = "Static"

  tags = {
    environment = "Production"
  }
}

resource "azurerm_network_interface" "anic" {
  name                = "${var.prefix}-nic"
  location            = azurerm_resource_group.tobedeleted.location
  resource_group_name = azurerm_resource_group.tobedeleted.name

  ip_configuration {
    name                          = "testconfiguration1"
    subnet_id                     = azurerm_subnet.inteasubnetrnal.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.pips.id
  }
}

resource "azurerm_virtual_machine" "avm" {
  name                  = "${var.prefix}-vm"
  location              = azurerm_resource_group.tobedeleted.location
  resource_group_name   = azurerm_resource_group.tobedeleted.name
  network_interface_ids = [azurerm_network_interface.anic.id]
  vm_size               = "Standard_DS1_v2"

  # Uncomment this line to delete the OS disk automatically when deleting the VM
  # delete_os_disk_on_termination = true

  # Uncomment this line to delete the data disks automatically when deleting the VM
  # delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
  storage_os_disk {
    name              = "myosdisk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "hostname"
    admin_username = "testadmin"
    admin_password = "Warrior@1234"
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
  tags = {
    environment = "staging"
  }

provisioner "file" {
  source      = "myscript.sh"
  destination = "/tmp/myscript.sh"

  connection {
    type     = "ssh"
    user     = "testadmin"
    password = "Warrior@1234"
    host     = azurerm_public_ip.pips.ip_address
  }

}

  


}

resource "null_resource" "myscript" {

provisioner "remote-exec" {
    inline = [
      "sudo bash /tmp/myscript.sh",
    ]
  }
  connection {
    type     = "ssh"
    user     = "testadmin"
    password = "Warrior@1234"
    host     = azurerm_public_ip.pips.ip_address
  }

  }



resource "null_resource" "samplefile" {

provisioner "file" {
  source      = "sample.txt"
  destination = "/tmp/sample.txt"

  connection {
    type     = "ssh"
    user     = "testadmin"
    password = "Warrior@1234"
    host     = azurerm_public_ip.pips.ip_address
  }

}

  }


variable "storagenames"{
type = list
default = ["storagesilver1", "storagesilver2", "storagesilver3"]
}

locals{

    images = {
for name in var.storagenames : name => name

    }
}

resource "azurerm_storage_account" "asa" {
for_each = local.images


  name                     = "${each.key}"
  location            = azurerm_resource_group.tobedeleted.location
  resource_group_name = azurerm_resource_group.tobedeleted.name
  account_tier             = "Standard"
  account_replication_type = "GRS"

  tags = {
    environment = "staging"
  }
}
