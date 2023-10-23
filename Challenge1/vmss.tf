resource "azurerm_resource_group" "devwebtierrg" {
 name     = "dev_webrg"
 location = "eastus"
}

resource "random_string" "fqdn" {
 length  = 6
 special = false
 upper   = false
 numeric  = false
}

resource "azurerm_virtual_network" "vmss" {
 name                = "dev_webappvnet"
 address_space       = ["10.1.0.0/16"]
 location            = "eastus"
 resource_group_name = azurerm_resource_group.devwebtierrg.name
 
}

resource "azurerm_subnet" "vmss" {
 name                 = "dev_webappsubnet"
 resource_group_name  = azurerm_resource_group.devwebtierrg.name
 virtual_network_name = azurerm_virtual_network.vmss.name
 address_prefixes       = ["10.1.2.0/24"]
}

resource "azurerm_public_ip" "vmss" {
 name                         = "vmss-public-ip"
 location                     = "eastus"
 resource_group_name          = azurerm_resource_group.devwebtierrg.name
 allocation_method            = "Static"
 domain_name_label            = random_string.fqdn.result
 
}

resource "azurerm_lb" "vmss" {
 name                = "devweblb"
 location            = azurerm_resource_group.devwebtierrg.location
 resource_group_name = azurerm_resource_group.devwebtierrg.name

 frontend_ip_configuration {
   name                 = "PublicIPAddress"
   public_ip_address_id = azurerm_public_ip.vmss.id
 }
}

resource "azurerm_lb_backend_address_pool" "bpepool" {
 loadbalancer_id     = azurerm_lb.vmss.id
 name                = "BackEndAddressPool"
}

resource "azurerm_lb_probe" "vmss" {
 loadbalancer_id     = azurerm_lb.vmss.id
 name                = "ssh-running-probe"
 port                = "22"
}

resource "azurerm_lb_rule" "lbnatrule" {
   loadbalancer_id                = azurerm_lb.vmss.id
   name                           = "http"
   protocol                       = "Tcp"
   frontend_port                  = "80"
   backend_port                   = "80"
   backend_address_pool_ids        = [azurerm_lb_backend_address_pool.bpepool.id]
   frontend_ip_configuration_name = "PublicIPAddress"
   probe_id                       = azurerm_lb_probe.vmss.id
}

resource "azurerm_virtual_machine_scale_set" "vmss" {
 name                = "devwebapp"
 location            = "eastus"
 resource_group_name = azurerm_resource_group.devwebtierrg.name
 upgrade_policy_mode = "Manual"

 sku {
   name     = "Standard_DS1_v2"
   tier     = "Standard"
   capacity = 2
 }

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
 }

 os_profile {
   computer_name_prefix = "webapp"
   admin_username       = var.admin_user
   admin_password       = var.admin_password
   
 }

 os_profile_linux_config {
   disable_password_authentication = false
 }

 network_profile {
   name    = "terraformnetworkprofile"
   primary = true

   ip_configuration {
     name                                   = "IPConfiguration"
     subnet_id                              = azurerm_subnet.vmss.id
     load_balancer_backend_address_pool_ids = [azurerm_lb_backend_address_pool.bpepool.id]
     primary = true
   }
 }
}