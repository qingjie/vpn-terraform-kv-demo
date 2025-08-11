data "azurerm_key_vault_secret" "secrets" {
  for_each = var.secret_names
  name     = each.value
  key_vault_id = var.key_vault_id
}

resource "azurerm_container_app_environment" "env" {
  name                = "aca-env-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name

  app_logs {
    destination = "log-analytics"
    log_analytics_configuration {
      customer_id = var.log_workspace_id
      shared_key  = var.log_shared_key
    }
  }
}

resource "azurerm_container_app" "this" {
  name                         = "aca-${var.environment}"
  location                     = var.location
  resource_group_name          = var.resource_group_name
  container_app_environment_id = azurerm_container_app_environment.env.id
  revision_mode                = "Single"

  identity {
    type = "UserAssigned"
    identity_ids = var.uai_resource_id == "" ? [] : [var.uai_resource_id]
  }

  template {
    container {
      name  = "app"
      image = var.container_image
      resources {
        cpu    = 0.5
        memory = "1.0Gi"
      }

      env = [
        for k, v in var.app_env_vars :
        { name = k, value = v }
      ]

      # secret env refs - container apps reference secrets by name, we create secrets below
      dynamic "env_secret" {
        for_each = var.secret_names
        content {
          name       = env_secret.key
          secret_ref = env_secret.value
        }
      }

      volume_mount {
        name       = "storage-volume"
        mount_path = "/mnt/blob"
      }
    }

    volume {
      name = "storage-volume"
      storage_account {
        storage_account_name = var.storage_account_name
        share_name           = var.storage_container_name
        access_mode          = "ReadWrite"
      }
    }

    scale {
      min_replicas = 0
      max_replicas = 2
    }
  }

  depends_on = [azurerm_container_app_environment.env]
}

resource "azurerm_container_app_secret" "secrets" {
  for_each = var.secret_names
  name                         = each.value
  resource_group_name          = var.resource_group_name
  container_app_environment_id = azurerm_container_app_environment.env.id

  secret {
    name  = each.value
    value = data.azurerm_key_vault_secret.secrets[each.key].value
  }
}

output "container_app_id" {
  value = azurerm_container_app.this.id
}

output "container_app_fqdn" {
  value = azurerm_container_app.this.latest_revision_fqdn
}
