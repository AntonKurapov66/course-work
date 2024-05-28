terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.13"
}

variable "token" {
  description = "The token Yandex.Cloud"
  type        = string
}
variable "cloud_id" {
  description = "The cloud ID of the Yandex.Cloud"
  type        = string
}
variable "folder_id" {
  description = "The folder ID of the Yandex.Cloud"
  type        = string
}
provider "yandex" {
  token     = var.token  #var.yandex_cloud_token
  cloud_id  = var.cloud_id 
  folder_id = var.folder_id 
}

# Виртуальные машины #

#Создаем 1-ый вебсервер
resource "yandex_compute_instance" "webserver-1" {
  name = "webserver-1"
  platform_id = "standard-v3"
  zone = "ru-central1-b"
  resources {
    core_fraction = 50 
    cores  = 2
    memory = 2
  }
  boot_disk {
    initialize_params {
      image_id = "fd8idq8k33m9hlj0huli"
      size     = 30
      type     = "network-hdd"
    }
  }
  network_interface {
    subnet_id = yandex_vpc_subnet.private-subnet-b.id
    nat       = true
    security_group_ids = ["${yandex_vpc_security_group.internal.id}"]
  }
  metadata = {
    user-data = "${file("./meta.yml")}"
  }
}
#Создаем 2-ой вебсервер
resource "yandex_compute_instance" "webserver-2" {
  name = "webserver-2"
  platform_id = "standard-v3"
  zone = "ru-central1-a"
  resources {
    core_fraction = 50
    cores  = 2
    memory = 2
  }
  boot_disk {
    initialize_params {
      image_id = "fd8idq8k33m9hlj0huli"
      size     = 30
      type     = "network-hdd"
    }
  }
  network_interface {
    subnet_id = yandex_vpc_subnet.private-subnet-a.id
    nat       = true
    security_group_ids = ["${yandex_vpc_security_group.internal.id}"]
  }
  metadata = {
    user-data = "${file("./meta.yml")}"
  }
}
#Создаем ВМ Prometheus
resource "yandex_compute_instance" "prometheus-server" {
  name = "prometheus-server"
  platform_id = "standard-v3"
  zone = "ru-central1-a"
  resources {
    core_fraction = 50 
    cores  = 2
    memory = 4
  }
  boot_disk {
    initialize_params {
      image_id = "fd8idq8k33m9hlj0huli"
      size     = 30
      type     = "network-hdd"
    }
  }
  network_interface {
    subnet_id = yandex_vpc_subnet.private-subnet-a.id
    #nat       = true
    security_group_ids = ["${yandex_vpc_security_group.internal.id}"]
  }
  metadata = {
    user-data = "${file("./meta.yml")}"
  }
}
#Создаем ВМ Elasticsearch
resource "yandex_compute_instance" "elasticsearch-server" {
  name = "elasticsearch-server"
  platform_id = "standard-v3"
  zone = "ru-central1-a"
  resources {
    core_fraction = 100 
    cores  = 4
    memory = 8
  }
  boot_disk {
    initialize_params {
      image_id = "fd8idq8k33m9hlj0huli"
      size     = 50
      type     = "network-hdd"
    }
  }
  network_interface {
    subnet_id = yandex_vpc_subnet.private-subnet-a.id
    #nat       = true
    security_group_ids = ["${yandex_vpc_security_group.internal.id}"]
  }
  metadata = {
    user-data = "${file("./meta.yml")}"
  }
}
#Создаем ВМ Kibana
resource "yandex_compute_instance" "kibana-server" {
  name = "kibana-server"
  platform_id = "standard-v3"
  zone = "ru-central1-a"
  resources {
    core_fraction = 50 
    cores  = 2
    memory = 4
  }
  boot_disk {
    initialize_params {
      image_id = "fd8idq8k33m9hlj0huli"
      size     = 30
      type     = "network-hdd"
    }
  }
  network_interface {
    subnet_id = yandex_vpc_subnet.public-subnet.id
    nat       = true
    security_group_ids = ["${yandex_vpc_security_group.internal.id}","${yandex_vpc_security_group.public-kibana.id}"]
  }
  metadata = {
    user-data = "${file("./meta.yml")}"
  }
}
#Создаем ВМ Grafana
resource "yandex_compute_instance" "grafana-server" {
  name = "grafana-server"
  platform_id = "standard-v3"
  zone = "ru-central1-a"
  resources {
    core_fraction = 50 
    cores  = 2
    memory = 2
  }
  boot_disk {
    initialize_params {
      image_id = "fd8idq8k33m9hlj0huli"
      size     = 30
      type     = "network-hdd"
    }
  }
  network_interface {
    subnet_id = yandex_vpc_subnet.public-subnet.id
    nat       = true
    security_group_ids = ["${yandex_vpc_security_group.internal.id}","${yandex_vpc_security_group.public-grafana.id}"]
  }
  metadata = {
    user-data = "${file("./meta.yml")}"
  }
}
#Создаем bastion-host
resource "yandex_compute_instance" "bastion" {
  name = "bastion"
  platform_id = "standard-v3"
  zone = "ru-central1-a"
  resources {
    core_fraction = 50 
    cores  = 2
    memory = 2
  }
  boot_disk {
    initialize_params {
      image_id = "fd8idq8k33m9hlj0huli"
      size     = 20
      type     = "network-hdd"
    }
  }
  network_interface {
    subnet_id = yandex_vpc_subnet.public-subnet.id
    nat       = true
    security_group_ids = ["${yandex_vpc_security_group.internal.id}","${yandex_vpc_security_group.public-bastion.id}"]
  }
  metadata = {
    user-data = "${file("./meta.yml")}"
  }
}

# Сетевые ресурсы #

# Создание VPC
resource "yandex_vpc_network" "vpc" {
  name = "vpc-network"
}
resource "yandex_vpc_route_table" "nat-bastion" {
  network_id = "${yandex_vpc_network.vpc.id}"

  static_route {
    destination_prefix = "0.0.0.0/0"
    next_hop_address   = "${yandex_compute_instance.bastion.network_interface.0.ip_address}"
  }
}
# Создание публичной подсети
resource "yandex_vpc_subnet" "public-subnet" {
  name           = "public-subnet"
  zone           = "ru-central1-a"
  network_id     = "${yandex_vpc_network.vpc.id}"
  v4_cidr_blocks = ["192.168.10.0/24"]
}
# Создание приватной подсети для Web, Prometheus, Elasticsearch серверов
resource "yandex_vpc_subnet" "private-subnet-a" {
  name           = "private-subnet-a"
  zone           = "ru-central1-a"
  network_id     = "${yandex_vpc_network.vpc.id}"
  v4_cidr_blocks = ["192.168.20.0/24"]
  route_table_id = "${yandex_vpc_route_table.nat-bastion.id}"
}
resource "yandex_vpc_subnet" "private-subnet-b" {
  name           = "private-subnet-b"
  zone           = "ru-central1-b"
  network_id     = "${yandex_vpc_network.vpc.id}"
  v4_cidr_blocks = ["192.168.30.0/24"]
  route_table_id = "${yandex_vpc_route_table.nat-bastion.id}"
}
# Создаем Target Group
resource "yandex_alb_target_group" "web-target-group" {
  name = "web-target-group"

  target {
    subnet_id = "${yandex_compute_instance.webserver-1.network_interface.0.subnet_id}"
    ip_address   = "${yandex_compute_instance.webserver-1.network_interface.0.ip_address}"
  }

  target {
    subnet_id = "${yandex_compute_instance.webserver-2.network_interface.0.subnet_id}"
    ip_address   = "${yandex_compute_instance.webserver-2.network_interface.0.ip_address}"
  }
}
# Создаем Backend Group и настраиваем health checks
resource "yandex_alb_backend_group" "web-backend-group" {
  name = "web-backend-group"
  http_backend {
    name        = "backend1"
    weight = 1
    port = 80
    target_group_ids = ["${yandex_alb_target_group.web-target-group.id}"]
    load_balancing_config {
      panic_threshold = 90
    }
    healthcheck {
      timeout = "10s"
      interval = "5s"
      http_healthcheck {
        path = "/"
      }
    }
  }
}
# Создаем HTTP router  
resource "yandex_alb_http_router" "web-http-router" {
  name = "web-http-router"
}
resource "yandex_alb_virtual_host" "my-virtual-host" {
  name           = "my-virtual-host"
  http_router_id = "${yandex_alb_http_router.web-http-router.id}"
  route {
    name = "core"
    http_route {
      http_match {
        path {
          prefix = "/"
        }
      }
      http_route_action {
        backend_group_id = "${yandex_alb_backend_group.web-backend-group.id}"
        timeout          = "3s"
      }
    }
  }
}
# Создаем Application Load Balancer (ALB)
resource "yandex_alb_load_balancer" "web-alb" {
  name = "web-alb"
  network_id  = yandex_vpc_network.vpc.id 
  security_group_ids = ["${yandex_vpc_security_group.internal.id}","${yandex_vpc_security_group.public-load-balancer.id}"] 

  allocation_policy {
    location {
      zone_id   = "ru-central1-a"
      subnet_id = "${yandex_vpc_subnet.public-subnet.id}" 
    }
  }
  listener {
    name = "my-listener"
    endpoint {
      address {
        external_ipv4_address {
        }
      }
      ports = [ 80 ]
    }    
    http {
      handler {
        http_router_id = "${yandex_alb_http_router.web-http-router.id}"
      }
    }
  }
}

# Security Groups #

resource "yandex_vpc_security_group" "internal" {
  name       = "internal-sg"
  network_id = yandex_vpc_network.vpc.id

  ingress {
    protocol       = "ANY"
    description    = "allow any connection from internal subnets"
	  predefined_target = "self_security_group"
  }

  egress {
    protocol       = "ANY"
    description    = "allow any outgoing connections"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "yandex_vpc_security_group" "public-bastion" {
  name       = "public-bastion-sg"
  network_id = yandex_vpc_network.vpc.id

  ingress {
    protocol       = "TCP"
    description    = "ssh_bastion"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 22
  }

  ingress {
    protocol       = "ICMP"
    description    = "allow ping"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol       = "ANY"
    description    = "allow any outgoing connection"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "yandex_vpc_security_group" "public-grafana" {
  name       = "public-grafana-sg"
  network_id = yandex_vpc_network.vpc.id

  ingress {
    protocol       = "TCP"
    description    = "allow grafana connections from internet"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 3000
  }
  
  ingress {
    protocol       = "TCP"
    description    = "allow grafana connections from internet"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 80
  } 

  ingress {
    protocol       = "ICMP"
    description    = "allow ping"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol       = "ANY"
    description    = "allow any outgoing connection"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "yandex_vpc_security_group" "public-kibana" {
  name       = "public-kibana-sg"
  network_id = yandex_vpc_network.vpc.id

  ingress {
    protocol       = "TCP"
    description    = "allow kibana connections from internet"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 5601
  }

  ingress {
    protocol       = "ICMP"
    description    = "allow ping"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol       = "ANY"
    description    = "allow any outgoing connection"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "yandex_vpc_security_group" "public-load-balancer" {
  name       = "public-load-balancer-sg"
  network_id = yandex_vpc_network.vpc.id

  ingress {
    protocol          = "ANY"
    description       = "Health checks"
    v4_cidr_blocks    = ["0.0.0.0/0"]
    predefined_target = "loadbalancer_healthchecks"
  }

  ingress {
    protocol       = "TCP"
    description    = "allow HTTP connections from internet"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 80
  }

  ingress {
    protocol       = "ICMP"
    description    = "allow ping"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol       = "ANY"
    description    = "allow any outgoing connection"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

#Снепшот дисков 

resource "yandex_compute_snapshot_schedule" "my-snapshot-disk" {
  name           = "my-snapshot-disk"
  schedule_policy {
	expression = "10 15 * * *"
  }
  snapshot_count = 7
  labels = {
    my-label = "my-label-value"
  }

  disk_ids = ["${yandex_compute_instance.webserver-1.boot_disk.0.disk_id}","${yandex_compute_instance.webserver-2.boot_disk.0.disk_id}","${yandex_compute_instance.bastion.boot_disk.0.disk_id}","${yandex_compute_instance.prometheus-server.boot_disk.0.disk_id}","${yandex_compute_instance.elasticsearch-server.boot_disk.0.disk_id}","${yandex_compute_instance.kibana-server.boot_disk.0.disk_id}","${yandex_compute_instance.grafana-server.boot_disk.0.disk_id}"]
  depends_on = [yandex_alb_load_balancer.web-alb]
} 
