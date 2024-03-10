# Создаем 3 vpc, для каждой создаем подсеть и таблицу маршрутизации

# Первая VPC
resource "yandex_vpc_network" "vpc-0" {
  name        = "vpc-0"
  description = "vpc-0 для лабы"
}

# Создаем подсеть
resource "yandex_vpc_subnet" "vpc0-subnet-0" {
  name           = "vpc0-subnet-0"
  description    = "Subnet for vpc-0"
  v4_cidr_blocks = ["192.168.0.0/24"]
  zone           = var.zone
  network_id     = "${yandex_vpc_network.vpc-0.id}"
}

# Создаем таблицу маршрутизации
resource "yandex_vpc_route_table" "vpc0-rt-0" {
  name       = "vpc0-rt-0"
  network_id = "${yandex_vpc_network.vpc-0.id}"
}

# Вторая  VPC
resource "yandex_vpc_network" "vpc-1" {
  name        = "vpc-1"
  description = "vpc-1 для лабы"
}

# Создаем подсеть
resource "yandex_vpc_subnet" "vpc1-subnet-0" {
  name           = "vpc1-subnet-0"
  description    = "Subnet for vpc-1"
  v4_cidr_blocks = ["192.168.1.0/24"]
  zone           = var.zone
  network_id     = "${yandex_vpc_network.vpc-1.id}"
}

# Создаем таблицу маршрутизации
resource "yandex_vpc_route_table" "vpc1-rt-0" {
  name       = "vpc1-rt-0"
  network_id = "${yandex_vpc_network.vpc-1.id}"
}

# Третья VPC
resource "yandex_vpc_network" "vpc-2" {
  name        = "vpc-2"
  description = "vpc-2 для лабы"
}

# Создаем подсеть
resource "yandex_vpc_subnet" "vpc2-subnet-0" {
  name           = "vpc2-subnet-0"
  description    = "Subnet for vpc-2"
  v4_cidr_blocks = ["192.168.2.0/24"]
  zone           = var.zone
  network_id     = "${yandex_vpc_network.vpc-2.id}"
}

# Создаем таблицу маршрутизации
resource "yandex_vpc_route_table" "vpc2-rt-0" {
  name       = "vpc2-rt-0"
  network_id = "${yandex_vpc_network.vpc-2.id}"
}