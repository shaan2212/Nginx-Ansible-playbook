# Configure the Azure Provider
provider "azurerm" {
  # whilst the `version` attribute is optional, we recommend pinning to a given version of the Provider
  subscription_id = "5ad2d8f0-59ab-47c6-915d-9b9f8ec9ff15"
  client_id       = "192488cb-7454-478f-9e34-021037ee9e05"
  client_secret   = ".3GGR_3RnHl2~0lrVJ-WzAM_tjUQt2gkey"
  tenant_id       = "daab0e3e-9169-4d5b-9786-240cce1d8e48"
  version         = "=2.0.0"
  features {}
}

# Create a resource group
resource "azurerm_resource_group" "example_rg" {
  name     = "${var.resource_prefix}-RG"
  location = var.ansiblenode_location
}

# Create a virtual network within the resource group
resource "azurerm_virtual_network" "example_vnet" {
  name                = "${var.resource_prefix}-vnet"
  resource_group_name = azurerm_resource_group.example_rg.name
  location            = var.ansiblenode_location
  address_space       = var.ansiblenode_address_space
}


# Create a subnets within the virtual network
resource "azurerm_subnet" "example_subnet" {
  name                 = "${var.resource_prefix}-subnet"
  resource_group_name  = azurerm_resource_group.example_rg.name
  virtual_network_name = azurerm_virtual_network.example_vnet.name
  address_prefix       = var.ansiblenode_address_prefix
}

# Create Linux Public IP 
resource "azurerm_public_ip" "example_public_ip" {
  count = var.ansiblenode_count
  name  = "${var.resource_prefix}-${format("%02d", count.index)}-PublicIP"
  #name                = "${var.resource_prefix}-PublicIP"
  location            = azurerm_resource_group.example_rg.location
  resource_group_name = azurerm_resource_group.example_rg.name
  allocation_method   = var.Environment == "Test" ? "Static" : "Dynamic"

  tags = {
    environment = "Test"
  }
}

# Create Network Interface
resource "azurerm_network_interface" "example_nic" {
  count = var.ansiblenode_count
  #name = "${var.resource_prefix}-NIC"
  name                = "${var.resource_prefix}-${format("%02d", count.index)}-NIC"
  location            = azurerm_resource_group.example_rg.location
  resource_group_name = azurerm_resource_group.example_rg.name
  #

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.example_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = element(azurerm_public_ip.example_public_ip.*.id, count.index)
    #public_ip_address_id          = azurerm_public_ip.example_public_ip.id
    #public_ip_address_id = azurerm_public_ip.example_public_ip.id
  }
}


# Creating resource NSG
resource "azurerm_network_security_group" "example_nsg" {

  name                = "${var.resource_prefix}-NSG"
  location            = azurerm_resource_group.example_rg.location
  resource_group_name = azurerm_resource_group.example_rg.name

  # Security rule can also be defined with resource azurerm_network_security_rule, here just defining it inline. 
  security_rule {
    name                       = "Inbound"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"

  }
  tags = {
    environment = "Test"
  }
}

# Subnet and NSG association 
resource "azurerm_subnet_network_security_group_association" "example_subnet_nsg_association" {
  subnet_id                 = azurerm_subnet.example_subnet.id
  network_security_group_id = azurerm_network_security_group.example_nsg.id

}

# Virtual Machine Creation - Linux
resource "azurerm_virtual_machine" "example_linux_vm" {
  count = var.ansiblenode_count
  name  = "${var.resource_prefix}-${format("%02d", count.index)}"
  #name                          = "${var.resource_prefix}-VM"
  location                      = azurerm_resource_group.example_rg.location
  resource_group_name           = azurerm_resource_group.example_rg.name
  network_interface_ids         = [element(azurerm_network_interface.example_nic.*.id, count.index)]
  vm_size                       = "Standard_A1_v2"
  delete_os_disk_on_termination = true


  storage_image_reference {
    publisher = "OpenLogic"
    offer     = "CentOS"
    sku       = "7.5"
    version   = "latest"
  }
  storage_os_disk {
    name              = "myosdisk-${count.index}"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "ansiblehost"
    admin_username = "shan"
    admin_password = "Password1234!"
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }

  #provisioner "remote-exec" {
  #  inline = [
  #    "echo ${var.pwd} | sudo -S yum install epel-release -y",
  ##    "sudo yum install ansible -y",
  # ]
  #}

  tags = {
    environment = "Test"
  }
}