# Создаем vpc

resource "yandex_vpc_network" "vpc-0" {
  name        = "vpc-0"
  description = "vpc-0 для лабы"
}

# Создаем подсеть для frontend
resource "yandex_vpc_subnet" "vpc0-subnet-frontend" {
  name           = "vpc0-subnet-frontend"
  description    = "frontend"
  v4_cidr_blocks = ["192.168.0.0/24"]
  zone           = var.zone
  network_id     = "${yandex_vpc_network.vpc-0.id}"
}

# Создаем подсеть для backend
resource "yandex_vpc_subnet" "vpc0-subnet-backend" {
  name           = "vpc0-subnet-backend"
  description    = "backend"
  v4_cidr_blocks = ["192.168.1.0/24"]
  zone           = var.zone
  network_id     = "${yandex_vpc_network.vpc-0.id}"
}

# Создаем подсеть для database
resource "yandex_vpc_subnet" "vpc0-subnet-database" {
  name           = "vpc0-subnet-database"
  description    = "database"
  v4_cidr_blocks = ["192.168.2.0/24"]
  zone           = var.zone
  network_id     = "${yandex_vpc_network.vpc-0.id}"
}

# Создаем группу безопасности front
resource "yandex_vpc_security_group" "vpc0-sg-front" {
  name        = "vpc0-sg-front"
  description = "Группа безопасности front"
  network_id  = "${yandex_vpc_network.vpc-0.id}"

  ingress {
    protocol       = "ANY"
    description    = "From front"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 80
  }

  egress {
    protocol       = "ANY"
    description    = "Out"
    v4_cidr_blocks = ["192.168.1.0/24"]
  }
}

# Создаем группу безопасности backend
resource "yandex_vpc_security_group" "vpc0-sg-back" {
  name        = "vpc0-sg-back"
  description = "Группа безопасности back"
  network_id  = "${yandex_vpc_network.vpc-0.id}"

  ingress {
    protocol       = "ANY"
    description    = "From front"
    v4_cidr_blocks = ["192.168.0.0/24"]
    port           = 3000
  }

  egress {
    protocol       = "ANY"
    description    = "Out"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

# Создаем группу безопасности DB
resource "yandex_vpc_security_group" "vpc0-sg-db" {
  name        = "vpc0-sg-db"
  description = "Группа безопасности db"
  network_id  = "${yandex_vpc_network.vpc-0.id}"

  ingress {
    protocol       = "ANY"
    description    = "From front"
    v4_cidr_blocks = ["192.168.1.0/24"]
    port           = 6000
  }
}

# Создание ВМ в front
resource "yandex_compute_disk" "boot-disk-front_vm" {
  name     = "disk-1"
  type     = "network-hdd"
  zone     = var.zone
  size     = 20
  image_id = "fd85u0rct32prepgjlv0"
}

# Создание ВМ в back
resource "yandex_compute_disk" "boot-disk-back_vm" {
  name     = "disk-2"
  type     = "network-hdd"
  zone     = var.zone
  size     = 20
  image_id = "fd85u0rct32prepgjlv0"
}

# Создание ВМ в db
resource "yandex_compute_disk" "boot-disk-db_vm" {
  name     = "disk-3"
  type     = "network-hdd"
  zone     = var.zone
  size     = 20
  image_id = "fd85u0rct32prepgjlv0"
}

resource "yandex_compute_instance" "vm-frontend" {
  name                      = "frontend-vm"
  allow_stopping_for_update = true
  platform_id               = "standard-v3"
  zone                      = var.zone
  hostname                  = "frontend"

  resources {
    cores  = 2
    memory = 4
  }

  boot_disk {
    disk_id = yandex_compute_disk.boot-disk-front_vm.id
  }

  network_interface {
    subnet_id = "${yandex_vpc_subnet.vpc0-subnet-frontend.id}"
    nat       = true
    security_group_ids = ["${yandex_vpc_security_group.vpc0-sg-front.id}"]
  }

  metadata = {
    user-data = file("${path.module}/cloud_config-front_vm.yaml")
    ssh-keys = "otus:${file("~/.ssh/id_ed25519.pub")}"
  }
}

resource "yandex_compute_instance" "vm-backend" {
  name                      = "backend-vm"
  allow_stopping_for_update = true
  platform_id               = "standard-v3"
  zone                      = var.zone
  hostname                  = "backend"

  resources {
    cores  = 2
    memory = 4
  }

  boot_disk {
    disk_id = yandex_compute_disk.boot-disk-back_vm.id
  }

  network_interface {
    subnet_id = "${yandex_vpc_subnet.vpc0-subnet-backend.id}"
    nat       = true
    security_group_ids = ["${yandex_vpc_security_group.vpc0-sg-back.id}"]
  }

  metadata = {
    user-data = file("${path.module}/cloud_config-back_vm.yaml")
    ssh-keys = "otus:${file("~/.ssh/id_ed25519.pub")}"
  }
}

resource "yandex_compute_instance" "vm-db" {
  name                      = "db-vm"
  allow_stopping_for_update = true
  platform_id               = "standard-v3"
  zone                      = var.zone
  hostname                  = "db"

  resources {
    cores  = 2
    memory = 4
  }

  boot_disk {
    disk_id = yandex_compute_disk.boot-disk-db_vm.id
  }

  network_interface {
    subnet_id = "${yandex_vpc_subnet.vpc0-subnet-database.id}"
    nat       = true
    security_group_ids = ["${yandex_vpc_security_group.vpc0-sg-db.id}"]
  }

  metadata = {
    user-data = file("${path.module}/cloud_config-db_vm.yaml")
    ssh-keys = "otus:${file("~/.ssh/id_ed25519.pub")}"
  }
}
