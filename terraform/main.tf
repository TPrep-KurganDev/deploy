terraform {
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = "~> 0.135"
    }
    github = {
      source  = "integrations/github"
      version = "~> 6.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
  }
  required_version = ">= 1.0"
}

provider "yandex" {
  token     = var.yc_token
  cloud_id  = var.cloud_id
  folder_id = var.folder_id
  zone      = var.zone
}

provider "github" {
  owner = var.github_owner
  token = var.github_token
}

resource "yandex_vpc_network" "tprep" {
  name = "tprep-network"
}

resource "yandex_vpc_subnet" "tprep" {
  name           = "tprep-subnet"
  zone           = var.zone
  network_id     = yandex_vpc_network.tprep.id
  v4_cidr_blocks = ["10.0.1.0/24"]
}

resource "yandex_vpc_security_group" "tprep" {
  name       = "tprep-sg"
  network_id = yandex_vpc_network.tprep.id

  ingress {
    protocol       = "TCP"
    port           = 22
    v4_cidr_blocks = ["0.0.0.0/0"]
    description    = "SSH"
  }

  ingress {
    protocol       = "TCP"
    port           = 80
    v4_cidr_blocks = ["0.0.0.0/0"]
    description    = "HTTP"
  }

  ingress {
    protocol       = "TCP"
    port           = 443
    v4_cidr_blocks = ["0.0.0.0/0"]
    description    = "HTTPS"
  }

  egress {
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
    description    = "Allow all outbound"
  }
}

resource "tls_private_key" "deploy" {
  algorithm = "ED25519"
}

resource "yandex_compute_instance" "tprep" {
  name        = "tprep-server"
  platform_id = "standard-v3"
  zone        = var.zone

  resources {
    cores  = var.cores
    memory = var.memory
  }

  boot_disk {
    initialize_params {
      image_id = var.image_id
      size     = var.disk_size
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.tprep.id
    nat                = true
    security_group_ids = [yandex_vpc_security_group.tprep.id]
  }

  metadata = {
    user-data = file("${path.module}/cloud-init.yml")
    ssh-keys  = "ubuntu:${tls_private_key.deploy.public_key_openssh}"
  }
}

resource "github_actions_organization_secret" "ssh_host" {
  secret_name     = "SSH_HOST"
  visibility      = "all"
  plaintext_value = yandex_compute_instance.tprep.network_interface[0].nat_ip_address
}

resource "github_actions_organization_secret" "ssh_user" {
  secret_name     = "SSH_USER"
  visibility      = "all"
  plaintext_value = "ubuntu"
}

resource "github_actions_organization_secret" "ssh_private_key" {
  secret_name     = "SSH_PRIVATE_KEY"
  visibility      = "all"
  plaintext_value = tls_private_key.deploy.private_key_openssh
}