resource "azurerm_virtual_machine" "devtier" {
  name                  = "${var.vm_name}-vm-${count.index}"
  location              = "${azurerm_resource_group.rg.location}"
  resource_group_name   = "${azurerm_resource_group.rg.name}"
  availability_set_id   = azurerm_availability_set.applicationavset.id
  network_interface_ids = ["${element(azurerm_network_interface.main.*.id, count.index)}"]
  vm_size               = "Standard_DS1_v2"
  count                 = 3

 
  delete_os_disk_on_termination = true

  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-datacenter-azure-edition"
    version   = "latest"
  }

  storage_os_disk {
    name              = "devdisk-${count.index}"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "devvm"
    admin_username = var.admin_user
    admin_password = var.admin_password
  }
  os_profile_windows_config {
  }
}