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

resource "azurerm_lb" "mellb" {
    name = "mellb"
    location = "${azurerm_resource_group.melrg.location}"
    resource_group_name = "${azurerm_virtual_network.melvnetprod.resource_group_name}"
    frontend_ip_configuration = {
        name = "melfront"
        public_ip_address_id = "${azurerm_public_ip.melpip.id}"
    }
}

resource "azurerm_lb_rule" "webrule" {
    name = "webrule"
    loadbalancer_id = "${azurerm_lb.mellb.id}"
    backend_port = 80
    frontend_ip_configuration_name = "melfront"
    frontend_port = 80
    protocol = "tcp"
    resource_group_name = "${azurerm_virtual_network.melvnetprod.resource_group_name}"
}

resource "azurerm_public_ip" "melpip" {
    name = "melpip"
    location = "${azurerm_resource_group.melrg.location}"
    resource_group_name = "${azurerm_virtual_network.melvnetprod.resource_group_name}"
    allocation_method = "Dynamic"
}

resource "azurerm_network_security_group" "melnsg" {
    name = "melnsg"
    resource_group_name = "${azurerm_resource_group.melrg.name}"
    location = "${azurerm_resource_group.melrg.location}"
}

resource "azurerm_network_security_rule" "melhttprule" {
    name = "melhttprule"
    resource_group_name = "${azurerm_resource_group.melrg.name}"
    direction = "inbound"
    destination_port_range = "80"
    access = "allow"
    destination_address_prefix = "*"
    source_address_prefix = "*"
    source_port_range = "*"
    protocol = "tcp"
    priority = "310"
    network_security_group_name = "${azurerm_network_security_group.melnsg.name}"
}

resource "azurerm_lb_backend_address_pool" "melback" {
    loadbalancer_id = "${azurerm_lb.mellb.id}"
    name = "melback"
    resource_group_name = "${azurerm_resource_group.melrg.name}"
}

resource "azurerm_virtual_machine_scale_set" "melvmss" {
    name = "melvmss"
    resource_group_name = "${azurerm_resource_group.melrg.name}"
    location = "${azurerm_resource_group.melrg.location}"
    os_profile = {
        admin_username = "${local.username}"
        admin_password = "${local.password}"
        computer_name_prefix = "melvmss"
    }
    sku = {
        name = "Standard_D1"
        capacity = 2
    }
    upgrade_policy_mode = "Automatic"

    storage_profile_image_reference {
        publisher = "Canonical"
        offer     = "UbuntuServer"
        sku       = "16.04-LTS"
        version   = "latest"
    }
    storage_profile_os_disk {
        name              = ""
        caching           = "ReadWrite"
        create_option     = "FromImage"
        managed_disk_type = "Standard_LRS"
        os_type = "linux"
    }
    network_profile = {
        name = "ipconfig1"
        primary = true
        ip_configuration = {
            primary = true
            name = "ipconfigc1"
            subnet_id = "${azurerm_subnet.melprodsub1.id}"
            load_balancer_backend_address_pool_ids = ["${azurerm_lb_backend_address_pool.melback.id}"]
        }
        
    }
    os_profile_linux_config {
        disable_password_authentication = false
    }
    
    extension = {
        name = "melext1"
        type = "CustomScript"
        publisher = "Microsoft.Azure.Extensions"
        type_handler_version = "2.0"
        auto_upgrade_minor_version = true
        settings = <<SETTINGS
        {
            "fileUris": [
                "https://raw.githubusercontent.com/Azure-Samples/compute-automation-configurations/master/automate_nginx.sh"
            ],
            "commandToExecute": "bash automate_nginx.sh"
        }
SETTINGS
    }
}

resource "azurerm_lb_nat_pool" "melnat" {
        name = "melnat"
        resource_group_name = "${azurerm_resource_group.melrg.name}"
        protocol = "Tcp"
        backend_port = 80
        frontend_port_start = 80
        frontend_port_end = 81
        frontend_ip_configuration_name = "melfront"
        loadbalancer_id = "${azurerm_lb.mellb.id}"
}

resource "azurerm_lb_probe" "lb_probe" {
  resource_group_name = "${azurerm_resource_group.melrg.name}"
  loadbalancer_id     = "${azurerm_lb.mellb.id}"
  name                = "tcpProbe"
  protocol            = "tcp"
  port                = 80
  interval_in_seconds = 5
  number_of_probes    = 2
}