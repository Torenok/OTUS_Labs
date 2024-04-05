# Создаем vpc

resource "yandex_vpc_network" "vpc-0" {
  name        = "vpc-0"
  description = "vpc-0 для лабы"
}

# Создаем подсеть
resource "yandex_vpc_subnet" "vpc0-subnet" {
  name           = "vpc0-subnet"
  description    = "frontend"
  v4_cidr_blocks = ["192.168.0.0/24"]
  zone           = var.zone
  network_id     = "${yandex_vpc_network.vpc-0.id}"
}

# Создание загрузочный диск для vm1
resource "yandex_compute_disk" "boot-disk-vm1" {
  name     = "disk-1"
  type     = "network-hdd"
  zone     = var.zone
  size     = 20
  image_id = "fd85u0rct32prepgjlv0"
}

# Создание загрузочный диск для vm2
resource "yandex_compute_disk" "boot-disk-vm2" {
  name     = "disk-2"
  type     = "network-hdd"
  zone     = var.zone
  size     = 20
  image_id = "fd85u0rct32prepgjlv0"
}

# Создаем диски HDD, SSD, NRSSD, а также файловое хранилище
# HDD
resource "yandex_compute_disk" "hdd-disk" {
  name       = "hdd-disk"
  type       = "network-hdd"
  zone       = var.zone
  size       = 5
}

# SSD
resource "yandex_compute_disk" "ssd-disk" {
  name       = "ssd-disk"
  type       = "network-ssd"
  zone       = var.zone
  size       = 6
}

#NRSSD
resource "yandex_compute_disk" "nrssd-disk" {
  name       = "nrssd-disk"
  type       = "network-ssd-nonreplicated"
  zone       = var.zone
  size       = 93
}

# Файловое хранилище
resource "yandex_compute_filesystem" "fs" {
  name   = "fs"
  type   = "network-hdd"
  zone   = var.zone
  size   = 10
}

# Создание виртуальных машин
resource "yandex_compute_instance" "vm1" {
  name                      = "vm1"
  allow_stopping_for_update = true
  platform_id               = "standard-v3"
  zone                      = var.zone
  hostname                  = "vm1"

  resources {
    cores  = 2
    memory = 4
  }

  boot_disk {
    disk_id = yandex_compute_disk.boot-disk-vm1.id
  }

  secondary_disk {
    disk_id = yandex_compute_disk.hdd-disk.id
    device_name = "hdd"
  }

  secondary_disk {
    disk_id = yandex_compute_disk.ssd-disk.id
    device_name = "ssd"
  }

  secondary_disk {
    disk_id = yandex_compute_disk.nrssd-disk.id
    device_name = "nrssd"
  }

  filesystem {
    filesystem_id = yandex_compute_filesystem.fs.id
    device_name = "fsdisk"
  }

  network_interface {
    subnet_id = "${yandex_vpc_subnet.vpc0-subnet.id}"
    nat       = true
  }

  metadata = {
    user-data = file("${path.module}/cloud_config-vm1.yaml")
    ssh-keys = "otus:${file("~/.ssh/id_ed25519.pub")}"
  }
}

resource "yandex_compute_instance" "vm2" {
  name                      = "vm2"
  allow_stopping_for_update = true
  platform_id               = "standard-v3"
  zone                      = var.zone
  hostname                  = "vm2"

  resources {
    cores  = 2
    memory = 4
  }

  boot_disk {
    disk_id = yandex_compute_disk.boot-disk-vm2.id
  }

  filesystem {
    filesystem_id = yandex_compute_filesystem.fs.id
    device_name = "fsdisk"
  }

  network_interface {
    subnet_id = "${yandex_vpc_subnet.vpc0-subnet.id}"
    nat       = true
  }

  metadata = {
    user-data = file("${path.module}/cloud_config-vm2.yaml")
    ssh-keys = "otus:${file("~/.ssh/id_ed25519.pub")}"
  }
}