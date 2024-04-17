# ==================================
# Terraform & Provider Configuration
# ==================================

terraform {
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.13"
}

provider "yandex" {
  service_account_key_file = var.service_account_key_file
  #token     = var.yc_token
  cloud_id  = var.cloud_id
  zone = "ru-central1-d"
  folder_id = var.folder_id
}