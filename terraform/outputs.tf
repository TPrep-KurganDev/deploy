output "external_ip" {
  description = "Public IP of the server"
  value       = yandex_compute_instance.tprep.network_interface[0].nat_ip_address
}

output "instance_id" {
  description = "Instance ID"
  value       = yandex_compute_instance.tprep.id
}

output "ssh_private_key" {
  description = "SSH private key for connecting to the server"
  value       = tls_private_key.deploy.private_key_openssh
  sensitive   = true
}