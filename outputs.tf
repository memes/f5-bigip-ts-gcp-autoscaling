output "vip" {
  value = google_compute_address.vip.address
}

output "bastion_commands" {
  value = {
    ssh    = module.bastion.ssh_command
    tunnel = module.bastion.tunnel_command
  }
}
