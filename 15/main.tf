# Создаем сервисные аккаунты

resource "yandex_iam_service_account" "sa-admin" {
  name        = "sa-folder-adm"
  description = "Административный аккаунт для каталога"
  folder_id   = var.folder_id
}

resource "yandex_iam_service_account" "sa-vpc" {
  name        = "sa-folder-vpc"
  description = "Административный аккаунт для VPC"
  folder_id   = var.folder_id
}

resource "yandex_iam_service_account" "sa-compute" {
  name        = "sa-folder-compute"
  description = "Административный аккаунт для Compute"
  folder_id   = var.folder_id
}

resource "yandex_iam_service_account" "sa-hd-1" {
  name        = "sa-hd-1"
  description = "Аккаунт для тех пода"
  folder_id   = var.folder_id
}

resource "yandex_iam_service_account" "sa-hd-2" {
  name        = "sa-hd-2"
  description = "Аккаунт для тех пода"
  folder_id   = var.folder_id
}

# Создаем группу

resource "yandex_organizationmanager_group" "hd-group" {
   name            = "hd-group"
   description     = "Группа для пользователей hd"
   organization_id = var.org_id
}

# Добавляем в группу пользователей

resource "yandex_organizationmanager_group_membership" "group-members" {
   group_id = yandex_organizationmanager_group.hd-group.id
   members  = [
     yandex_iam_service_account.sa-hd-1.id,
     yandex_iam_service_account.sa-hd-2.id
   ]
}

# Назначим роли для сервисных аккуантов

resource "yandex_resourcemanager_folder_iam_member" "folder-admin" {
  folder_id = var.folder_id
  role      = "admin"
  member    = "serviceAccount:${yandex_iam_service_account.sa-admin.id}"
}

resource "yandex_resourcemanager_folder_iam_member" "folder-vpc" {
  folder_id = var.folder_id
  role      = "vpc.admin"
  member    = "serviceAccount:${yandex_iam_service_account.sa-vpc.id}"
}

resource "yandex_resourcemanager_folder_iam_member" "folder-compute" {
  folder_id = var.folder_id
  role      = "compute.admin"
  member    = "serviceAccount:${yandex_iam_service_account.sa-compute.id}"
}

resource "yandex_resourcemanager_folder_iam_member" "folder-group-vpc-hd" {
  folder_id = var.folder_id
  role      = "vpc.user"
  member    = "group:${yandex_organizationmanager_group.hd-group.id}"
}

resource "yandex_resourcemanager_folder_iam_member" "folder-group-compute-hd" {
  folder_id = var.folder_id
  role      = "compute.editor"
  member    = "group:${yandex_organizationmanager_group.hd-group.id}"
}

# Создание загрузочный диск для vm1
resource "yandex_compute_disk" "boot-disk-otus" {
  name     = "disk-2"
  type     = "network-hdd"
  zone     = var.zone
  size     = 20
  image_id = "fd85u0rct32prepgjlv0"
}

# Создадим ВМ для проверки

resource "yandex_compute_instance" "otus-vm" {
  name                      = "otus-vm"
  allow_stopping_for_update = true
  platform_id               = "standard-v3"
  zone                      = var.zone
  hostname                  = "otus-vm"

  resources {
    cores  = 2
    memory = 4
  }

  boot_disk {
    disk_id = yandex_compute_disk.boot-disk-otus.id
  }

  network_interface {
    subnet_id = var.vpc_id
    nat       = true
  }

  metadata = {
    user-data = file("${path.module}/cloud_config-vm.yaml")
    ssh-keys = "otus:${file("~/.ssh/id_ed25519.pub")}"
  }
}