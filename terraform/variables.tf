variable "project_id_prefix" {
  type = string
}

variable "folder_id" {
  type = string
}

variable "region" {
  type = string
}

variable "billing_account_id" {
  type = string
}

# Workload Identity Federation
variable "wif_pool_id" {
  type = string
}

variable "wif_provider_id" {
  type = string
}
