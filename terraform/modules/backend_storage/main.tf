resource "azurerm_resource_group" "backend_rg" {
  name     = "rg-terraform-backend-${var.region}"
  location = var.region
}

resource "azurerm_virtual_network" "backend_vnet" {
  name                = "vnet-backend-${var.region}"
  resource_group_name = azurerm_resource_group.backend_rg.name
  location            = var.region
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "backend_subnet" {
  name                 = "snet-backend"
  resource_group_name  = azurerm_resource_group.backend_rg.name
  virtual_network_name = azurerm_virtual_network.backend_vnet.name
  address_prefixes     = ["10.0.1.0/24"]
  service_endpoints    = ["Microsoft.Storage"]
}

resource "azurerm_storage_account" "backend_sa" {
  name                     = lower(replace("tfstate${var.environment}${var.region}", "-", ""))
  resource_group_name      = azurerm_resource_group.backend_rg.name
  location                 = var.region
  account_tier             = "Standard"
  account_replication_type = "LRS"
  allow_blob_public_access = false

  network_rules {
    default_action             = "Deny"
    bypass                    = ["AzureServices"]
    virtual_network_subnet_ids = [azurerm_subnet.backend_subnet.id]
  }
}

resource "azurerm_storage_container" "backend_container" {
  name                  = "tfstate"
  storage_account_name  = azurerm_storage_account.backend_sa.name
  container_access_type = "private"
}

resource "azurerm_private_endpoint" "storage_pe" {
  name                = "pe-storage-tfstate-${var.environment}"
  location            = var.region
  resource_group_name = azurerm_resource_group.backend_rg.name
  subnet_id           = azurerm_subnet.backend_subnet.id

  private_service_connection {
    name                           = "tfstate-storage-psc-${var.environment}"
    private_connection_resource_id = azurerm_storage_account.backend_sa.id
    subresource_names              = ["blob"]
    is_manual_connection           = false
  }
}

resource "azurerm_private_dns_zone" "storage_dns" {
  name                = "privatelink.blob.core.windows.net"
  resource_group_name = azurerm_resource_group.backend_rg.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "dns_link" {
  name                  = "link-to-vnet-${var.environment}"
  resource_group_name   = azurerm_resource_group.backend_rg.name
  private_dns_zone_name = azurerm_private_dns_zone.storage_dns.name
  virtual_network_id    = azurerm_virtual_network.backend_vnet.id
  registration_enabled  = false
}

resource "azurerm_private_dns_a_record" "storage_dns_record" {
  name                = azurerm_storage_account.backend_sa.name
  zone_name           = azurerm_private_dns_zone.storage_dns.name
  resource_group_name = azurerm_resource_group.backend_rg.name
  ttl                 = 300
  records             = [azurerm_private_endpoint.storage_pe.private_ip_address]
}

output "resource_group_name" {
  value = azurerm_resource_group.backend_rg.name
}

output "storage_account_name" {
  value = azurerm_storage_account.backend_sa.name
}
