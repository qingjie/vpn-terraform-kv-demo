variable "environment" {}
variable "location" {}
variable "resource_group_name" {}
variable "container_image" {}
variable "app_env_vars" {
  type = map(string)
  default = {}
}
variable "key_vault_id" {}
variable "secret_names" {
  type = map(string)
  default = {}
}
variable "uai_resource_id" {
  type = string
  default = ""
}
variable "log_workspace_id" {
  type = string
  default = ""
}
variable "log_shared_key" {
  type = string
  default = ""
}
variable "storage_account_name" {
  type = string
  default = ""
}
variable "storage_container_name" {
  type = string
  default = ""
}
