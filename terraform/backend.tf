# backend.tf is templated; terraform init should pass backend-config with environment and region
terraform {
  backend "azurerm" {
    resource_group_name  = "rg-terraform-backend"
    storage_account_name = "tfstate${var.environment}${var.region}"
    container_name       = "tfstate"
    key                  = "${var.environment}.terraform.tfstate"
  }
}
