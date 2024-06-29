##---IAM
resource "yandex_iam_service_account" "todo_cloud_sa" {
  name        = "${var.user}-todo-cloud-sa"
  description = "service account to manage cloud"
}

resource "yandex_resourcemanager_cloud_iam_binding" "cloud_admin" {
  cloud_id   = "${var.cloud_id}"
  role = "admin"
  members = [
    "serviceAccount:${yandex_iam_service_account.todo_cloud_sa.id}",
  ]
  sleep_after = 10
}

resource "yandex_iam_service_account" "todo_folder_sa" {
  name        = "${var.user}-todo-folder-sa"
  description = "service account to manage folder"
}

resource "yandex_resourcemanager_folder_iam_binding" "folder_admin" {
  folder_id   = "${var.folder_id}"
  role = "admin"
  members = [
    "serviceAccount:${yandex_iam_service_account.todo_folder_sa.id}",
  ]
  sleep_after = 10
}

resource "yandex_iam_service_account" "todo_vpc_sa" {
  name        = "${var.user}-todo-vpc-sa"
  description = "service account for vpc admins"
}

resource "yandex_resourcemanager_folder_iam_binding" "vpc_admin" {
  folder_id   = "${var.folder_id}"
  role = "admin"
  members = [
    "serviceAccount:${yandex_iam_service_account.todo_vpc_sa.id}",
  ]
  sleep_after = 10
}

resource "yandex_iam_service_account" "todo_ig_sa" {
  name        = "${var.user}-todo-ig-sa"
  description = "service account to manage IG"
}

resource "yandex_resourcemanager_folder_iam_binding" "folder_editor" {
  folder_id   = "${var.folder_id}"
  role = "editor"
  members = [
    "serviceAccount:${yandex_iam_service_account.todo_ig_sa.id}",
  ]
  sleep_after = 10
}

resource "yandex_iam_service_account" "todo_node_sa" {
  name        = "${var.user}-todo-node-sa"
  description = "service account to manage docker images on nodes"
}

resource "yandex_resourcemanager_folder_iam_binding" "folder_puller" {
  folder_id   = "${var.folder_id}"
  role = "container-registry.images.puller"
  members = [
    "serviceAccount:${yandex_iam_service_account.todo_node_sa.id}",
  ]
}

#---Network

resource "yandex_vpc_network" "todo-network" {
  name = "todo-network"
}

resource "yandex_vpc_subnet" "todo-subnet-b" {
  name = "todo-subnet-b"
  v4_cidr_blocks = ["10.3.0.0/16"]
  zone           = "ru-central1-b"
  network_id     = "${yandex_vpc_network.todo-network.id}"
}

resource "yandex_vpc_subnet" "todo-subnet-d" {
  name = "todo-subnet-d"
  v4_cidr_blocks = ["10.4.0.0/16"]
  zone           = "ru-central1-d"
  network_id     = "${yandex_vpc_network.todo-network.id}"
}

#---Database

locals {
  dbuser     = tolist(yandex_mdb_postgresql_cluster.todo_postgresql.user.*.name)[0]
  dbpassword = tolist(yandex_mdb_postgresql_cluster.todo_postgresql.user.*.password)[0]
  dbhosts    = yandex_mdb_postgresql_cluster.todo_postgresql.host.*.fqdn
  dbname     = tolist(yandex_mdb_postgresql_cluster.todo_postgresql.database.*.name)[0]
}

resource "yandex_mdb_postgresql_cluster" "todo_postgresql" {
  name        = "todo-postgresql"
  folder_id   = var.folder_id
  environment = "PRODUCTION"
  network_id  = yandex_vpc_network.todo-network.id

  config {
    version = 12
    resources {
      resource_preset_id = "s2.small"
      disk_type_id       = "network-ssd"
      disk_size          = 10
    }
  }

  database {
    name  = var.postgre_dbname
    owner = var.postgre_owner
  }

  user {
    name     = var.postgre_user
    password = var.postgre_password
    permission {
      database_name = var.postgre_dbname
    }
  }

  host {
    zone             = "ru-central1-b"
    subnet_id        = yandex_vpc_subnet.todo-subnet-b.id
    assign_public_ip = true
  }
  host {
    zone             = "ru-central1-d"
    subnet_id        = yandex_vpc_subnet.todo-subnet-d.id
    assign_public_ip = true
  }
}

#---Container Registry

resource "yandex_container_registry" "todo_registry" {
  name = "todo-registry"
  folder_id = var.folder_id
}

#---Instance Group

data "yandex_compute_image" "coi" {
  family = "container-optimized-image"
}

resource "yandex_compute_instance_group" "todo_instances" {
  name               = "todo-ig"
  folder_id          = var.folder_id
  service_account_id = yandex_iam_service_account.todo_ig_sa.id
  instance_template {
    platform_id = "standard-v2"
    resources {
      memory = 2
      cores  = 2
    }
    boot_disk {
      mode = "READ_WRITE"
      initialize_params {
        image_id = data.yandex_compute_image.coi.id
        size     = 30
      }
    }
    network_interface {
      network_id = yandex_vpc_network.todo-network.id
      nat        = "true"
    }
    service_account_id = yandex_iam_service_account.todo_node_sa.id
    metadata = {
      ssh-keys                     = "otus:${file("~/.ssh/id_ed25519.pub")}"
      docker-container-declaration = templatefile("${path.module}/files/spec.yaml", {
        docker_image   = "cr.yandex/${yandex_container_registry.todo_registry.id}/todo-project:v1"
        database_uri   = "postgresql://${local.dbuser}:${local.dbpassword}@:1/${local.dbname}"
        database_hosts = "${join(",", local.dbhosts)}"
      })
    }
  }

  scale_policy {
    auto_scale {
      initial_size = 4
      max_size = 10
      min_zone_size = 2
      cpu_utilization_target = 30
      measurement_duration = 60
      custom_rule {
        metric_name = "network_received_packets"
        metric_type = "GAUGE"
        rule_type   = "WORKLOAD"
        target      = 100
      }
    }
  }

  allocation_policy {
    zones = [
      "ru-central1-b",
      "ru-central1-d"
    ]
  }

  deploy_policy {
    max_unavailable = 2
    max_expansion   = 2
  }

  load_balancer {
    target_group_name = "tg-ig"
  }

  health_check {
    healthy_threshold   = 2
    interval            = 2
    timeout             = 1
    unhealthy_threshold = 2

    http_options {
      path = "/healthy"
      port = "80"
    }
  }

  depends_on = [
    yandex_resourcemanager_folder_iam_binding.folder_editor
  ]
}

##---Load balancer

resource "yandex_lb_network_load_balancer" "todo_lb" {
  name = "todo-lb"

  listener {
    name = "todo-listener"
    port = 80
    external_address_spec {
      ip_version = "ipv4"
    }
  }

  attached_target_group {
    target_group_id = "${yandex_compute_instance_group.todo_instances.load_balancer.0.target_group_id}"

    healthcheck {
      name = "todo-http-hc"
      http_options {
        port = 80
        path = "/alive"
      }
    }
  }
}