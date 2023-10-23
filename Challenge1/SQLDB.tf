resource "azurerm_resource_group" "sqldb" {
  name     = "dev_databaseRG"
  location = "eastus"
}

resource "azurerm_sql_server" "sqlserver" {
  name                         = "devsqlserverdatabase20230033"
  resource_group_name          = azurerm_resource_group.sqldb.name
  location                     = azurerm_resource_group.sqldb.location
  version                      = "12.0"
  administrator_login          = var.admin_user
  administrator_login_password = var.admin_password


}


resource "azurerm_sql_database" "database2121" {
  name                = "productiondb"
  resource_group_name = azurerm_resource_group.sqldb.name
  location            = azurerm_resource_group.sqldb.location
  server_name         = azurerm_sql_server.sqlserver.name

}