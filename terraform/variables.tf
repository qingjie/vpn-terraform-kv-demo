variable "environment" {
  description = "Environment: dev/qa/prod"
  type        = string
}

variable "region" {
  description = "Azure region"
  type        = string
  default     = "eastus"
}

variable "resource_group_name" {
  description = "Resource group name prefix"
  type        = string
  default     = "rg-aca"
}
