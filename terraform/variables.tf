variable "cloud_id" {
  description = "Yandex Cloud ID"
  type        = string
}

variable "folder_id" {
  description = "Yandex Cloud Folder ID"
  type        = string
}

variable "zone" {
  description = "Availability zone"
  type        = string
  default     = "ru-central1-a"
}

variable "image_id" {
  description = "Ubuntu 22.04 LTS image ID (yc compute image list --folder-id standard-images)"
  type        = string
  default     = "fd8autg36kchufhej85b"
}


variable "cores" {
  description = "Number of CPU cores"
  type        = number
  default     = 2
}

variable "memory" {
  description = "RAM in GB"
  type        = number
  default     = 2
}

variable "disk_size" {
  description = "Boot disk size in GB"
  type        = number
  default     = 20
}

variable "ssh_user" {
  description = "Username for SSH access to the VM"
  type        = string
  default     = "dabbler"
}

# GitHub

variable "github_owner" {
  description = "GitHub organization or user (e.g. TPrep-KurganDev)"
  type        = string
}

variable "github_token" {
  description = "GitHub personal access token with repo and admin:org scopes"
  type        = string
  sensitive   = true
}

variable "domain" {
  description = "Domain name for the application (e.g. tprep.duckdns.org)"
  type        = string
  default     = "tprep.duckdns.org"
}


variable "yc_token" {
  description = "Yandex Cloud OAuth token (yc iam create-token)"
  type        = string
  sensitive   = true
}