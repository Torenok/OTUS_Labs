# Создаем vpc

resource "yandex_vpc_network" "vpc-0" {
  name        = "vpc-0"
  description = "vpc-0 для лабы"
}

# Создаем подсеть
resource "yandex_vpc_subnet" "vpc0-subnet" {
  name           = "vpc0-subnet"
  description    = "subnet"
  v4_cidr_blocks = ["192.168.0.0/24"]
  zone           = var.zone
  network_id     = yandex_vpc_network.vpc-0.id
}

# Создание загрузочный диск для jump host
resource "yandex_compute_disk" "boot-disk-vm1" {
  name     = "disk-1"
  type     = "network-hdd"
  zone     = var.zone
  size     = 20
  image_id = "fd85u0rct32prepgjlv0"
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

  network_interface {
    subnet_id = yandex_vpc_subnet.vpc0-subnet.id
    nat       = true
  }

  metadata = {
    user-data = file("${path.module}/cloud_config-vm1.yaml")
    ssh-keys = "otus:${file("~/.ssh/id_ed25519.pub")}"
  }
}