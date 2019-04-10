locals {
  username = "contosoadmin"
  password = "P@ssw0rd2018"
}

provider "random" {

}

provider "azurerm" {
  
}

resource "random_string" "rnd1" {
    length = 12
    special = false
}

resource "random_string" "rnd2" {
    length = 12
    special = false
}

resource "random_string" "rnd3" {
    length = 12
    special = false
}


resource "azurerm_resource_group" "melrg" {
    name = "RGMELCONTOSO"
    location = "australiasoutheast"
}

resource "azurerm_resource_group" "sydrg" {
    name = "RGSYDCONTOSO"
    location = "australiaeast"
}

resource "azurerm_virtual_network" "melvnetprod" {
    name = "melvnetprod"
    resource_group_name = "${azurerm_resource_group.melrg.name}"
    location = "${azurerm_resource_group.melrg.location}"
    address_space = ["12.0.0.0/24"]
}

resource "azurerm_subnet" "melprodsub1" {
    name = "subnet1"
    address_prefix = "12.0.0.0/25"
    virtual_network_name = "${azurerm_virtual_network.melvnetprod.name}"
    resource_group_name = "${azurerm_virtual_network.melvnetprod.resource_group_name}"
    
}

resource "azurerm_virtual_network" "sydvnetprod" {
    name = "sydvnetprod"
    resource_group_name = "${azurerm_resource_group.sydrg.name}"
    location = "${azurerm_resource_group.sydrg.location}"
    address_space = ["14.0.0.0/24"]
}

resource "azurerm_subnet" "sydprodsub1" {
    name = "subnet1"
    address_prefix = "14.0.0.0/25"
    virtual_network_name = "${azurerm_virtual_network.sydvnetprod.name}"
    resource_group_name = "${azurerm_virtual_network.sydvnetprod.resource_group_name}"
    
}

resource "azurerm_virtual_network" "melvnetdev" {
    name = "melvnetdev"
    resource_group_name = "${azurerm_resource_group.melrg.name}"
    location = "${azurerm_resource_group.melrg.location}"
    address_space = ["13.0.0.0/24"]
}

resource "azurerm_subnet" "meldevsub1" {
    name = "subnet1"
    address_prefix = "13.0.0.0/25"
    virtual_network_name = "${azurerm_virtual_network.melvnetdev.name}"
    resource_group_name = "${azurerm_virtual_network.melvnetdev.resource_group_name}"
    
}

resource "azurerm_network_security_group" "melprodnsg" {
    name = "melprodnsg"
    resource_group_name = "${azurerm_resource_group.melrg.name}"
    location = "${azurerm_resource_group.melrg.location}"
}

resource "azurerm_network_security_rule" "sshmp" {
    name = "sshin"
    resource_group_name = "${azurerm_resource_group.melrg.name}"
    direction = "inbound"
    destination_port_range = "22"
    access = "allow"
    destination_address_prefix = "*"
    source_address_prefix = "*"
    source_port_range = "*"
    protocol = "tcp"
    priority = "310"
    network_security_group_name = "${azurerm_network_security_group.melprodnsg.name}"
}

resource "azurerm_network_security_group" "sydprodnsg" {
    name = "melprodnsg"
    resource_group_name = "${azurerm_resource_group.sydrg.name}"
    location = "${azurerm_resource_group.sydrg.location}"
}

resource "azurerm_network_security_rule" "sshsp" {
    name = "sshin"
    resource_group_name = "${azurerm_resource_group.sydrg.name}"
    direction = "inbound"
    destination_port_range = "22"
    access = "allow"
    destination_address_prefix = "*"
    source_address_prefix = "*"
    source_port_range = "*"
    protocol = "tcp"
    priority = "310"
    network_security_group_name = "${azurerm_network_security_group.sydprodnsg.name}"
}

resource "azurerm_network_security_group" "meldevnsg" {
    name = "meldevnsg"
    resource_group_name = "${azurerm_resource_group.melrg.name}"
    location = "${azurerm_resource_group.melrg.location}"
}

resource "azurerm_network_security_rule" "sshmd" {
    name = "sshin"
    resource_group_name = "${azurerm_resource_group.melrg.name}"
    direction = "inbound"
    destination_port_range = "22"
    access = "allow"
    destination_address_prefix = "*"
    source_address_prefix = "*"
    source_port_range = "*"
    protocol = "tcp"
    priority = "310"
    network_security_group_name = "${azurerm_network_security_group.meldevnsg.name}"
}

resource "azurerm_public_ip" "sydprodip" {
    name = "sydprodip"
    resource_group_name = "${azurerm_resource_group.sydrg.name}"
    location = "${azurerm_resource_group.sydrg.location}"
    allocation_method = "Dynamic"
}

resource "azurerm_public_ip" "melprodip" {
    name = "melprodip"
    resource_group_name = "${azurerm_resource_group.melrg.name}"
    location = "${azurerm_resource_group.melrg.location}"
    allocation_method = "Dynamic"
}

resource "azurerm_public_ip" "meldevip" {
    name = "meldevip"
    resource_group_name = "${azurerm_resource_group.melrg.name}"
    location = "${azurerm_resource_group.melrg.location}"
    allocation_method = "Dynamic"
}

resource "azurerm_network_interface" "melprdnic" {
    name = "melprodnic"
    location = "${azurerm_resource_group.melrg.location}"
    resource_group_name = "${azurerm_resource_group.melrg.name}"
    ip_configuration = {
        name = "ipconfig1"
        private_ip_address_allocation = "Dynamic"
        public_ip_address_id = "${azurerm_public_ip.melprodip.id}"
        subnet_id = "${azurerm_subnet.melprodsub1.id}"
    }
    
}

resource "azurerm_network_interface" "meldevnic" {
    name = "meldevnic"
    location = "${azurerm_resource_group.melrg.location}"
    resource_group_name = "${azurerm_resource_group.melrg.name}"
    ip_configuration = {
        name = "ipconfig1"
        private_ip_address_allocation = "Dynamic"
        public_ip_address_id = "${azurerm_public_ip.meldevip.id}"
        subnet_id = "${azurerm_subnet.meldevsub1.id}"
    }
    
}

resource "azurerm_network_interface" "sydprdnic" {
    name = "sydprodnic"
    location = "${azurerm_resource_group.sydrg.location}"
    resource_group_name = "${azurerm_resource_group.sydrg.name}"
    ip_configuration = {
        name = "ipconfig1"
        private_ip_address_allocation = "Dynamic"
        public_ip_address_id = "${azurerm_public_ip.sydprodip.id}"
        subnet_id = "${azurerm_subnet.sydprodsub1.id}"
    }
    
}

resource "azurerm_virtual_machine" "melvm1" {
    name = "VMMELPROD"
    location = "${azurerm_resource_group.melrg.location}"
    resource_group_name = "${azurerm_resource_group.melrg.name}"
    network_interface_ids = ["${azurerm_network_interface.melprdnic.id}"]
    storage_os_disk = {
        create_option = "FromImage"
        os_type = "Windows"
        name = "${random_string.rnd1.result}"
        managed_disk_type = "Standard_LRS"
    }
    os_profile = {
        admin_username = "${local.username}"
        admin_password = "${local.password}"
        computer_name = "VMMELPROD"
    }
    storage_image_reference {
        publisher = "MicrosoftWindowsServer"
        offer     = "WindowsServer"
        sku       = "2019-Datacenter"
        version   = "latest"
    }
    vm_size = "Standard_D1"
    os_profile_windows_config = {
        provision_vm_agent = true
    }


}

resource "azurerm_virtual_machine" "melvm2" {
    name = "VMMELDEV"
    location = "${azurerm_resource_group.melrg.location}"
    resource_group_name = "${azurerm_resource_group.melrg.name}"
    network_interface_ids = ["${azurerm_network_interface.meldevnic.id}"]
    storage_os_disk = {
        create_option = "FromImage"
        os_type = "Windows"
        name = "${random_string.rnd2.result}"
        managed_disk_type = "Standard_LRS"
    }
    os_profile = {
        admin_username = "${local.username}"
        admin_password = "${local.password}"
        computer_name = "VMMELDEV"
    }
    storage_image_reference {
        publisher = "MicrosoftWindowsServer"
        offer     = "WindowsServer"
        sku       = "2019-Datacenter"
        version   = "latest"
    }
    vm_size = "Standard_D1" 
    os_profile_windows_config = {
        provision_vm_agent = true
    }

}

resource "azurerm_virtual_machine" "sydvm1" {
    name = "VMSYDPROD"
    location = "${azurerm_resource_group.sydrg.location}"
    resource_group_name = "${azurerm_resource_group.sydrg.name}"
    network_interface_ids = ["${azurerm_network_interface.sydprdnic.id}"]
    storage_os_disk = {
        create_option = "FromImage"
        os_type = "Windows"
        name = "${random_string.rnd3.result}"
        managed_disk_type = "Standard_LRS"
    }
    os_profile = {
        admin_username = "${local.username}"
        admin_password = "${local.password}"
        computer_name = "VMSYDPROD"
    }
    storage_image_reference {
        publisher = "MicrosoftWindowsServer"
        offer     = "WindowsServer"
        sku       = "2019-Datacenter"
        version   = "latest"
    }
    vm_size = "Standard_D1" 
    os_profile_windows_config = {
        provision_vm_agent = true
    }

}

resource "azurerm_virtual_network_peering" "melsyd" {
    name = "melsyd"
    resource_group_name = "${azurerm_resource_group.melrg.name}"
    virtual_network_name = "${azurerm_virtual_network.melvnetprod.name}"
    remote_virtual_network_id = "${azurerm_virtual_network.sydvnetprod.id}"
}

resource "azurerm_virtual_network_peering" "sydmel" {
    name = "sydmel"
    resource_group_name = "${azurerm_resource_group.sydrg.name}"
    virtual_network_name = "${azurerm_virtual_network.sydvnetprod.name}"
    remote_virtual_network_id = "${azurerm_virtual_network.melvnetprod.id}"
}

resource "azurerm_subnet_network_security_group_association" "melprdsga" {
    subnet_id                 = "${azurerm_subnet.melprodsub1.id}"
    network_security_group_id = "${azurerm_network_security_group.melprodnsg.id}"
}

resource "azurerm_subnet_network_security_group_association" "sydprdsga" {
    subnet_id                 = "${azurerm_subnet.sydprodsub1.id}"
    network_security_group_id = "${azurerm_network_security_group.sydprodnsg.id}"
}

resource "azurerm_subnet_network_security_group_association" "meldevsga" {
    subnet_id                 = "${azurerm_subnet.meldevsub1.id}"
    network_security_group_id = "${azurerm_network_security_group.meldevnsg.id}"
}


