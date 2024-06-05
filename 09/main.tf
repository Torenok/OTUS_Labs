locals {
  registry_name = "todo-registry"
}

provider "yandex" {
  service_account_key_file = var.service_account_key_file
  #token     = var.yc_token
  cloud_id  = var.cloud_id
  zone = "ru-central1-d"
  folder_id = var.folder_id
}
