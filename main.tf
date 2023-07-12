terraform {
  required_providers {
    proxmox = {
      source = "Telmate/proxmox"
      version = "2.9.14"
    }
  }
  required_version = "~> 1.5.0"
}

provider "proxmox" {
  pm_api_url = "https://192.168.5.10:8006/api2/json"
  pm_tls_insecure = true
  pm_user = var.pm_user
  pm_password = var.pm_password
  pm_debug = true
  pm_log_enable = true
}

module "servers" {
  source = "./terraform-modules/servers"
  home_assistant_target_node = "nuc1"
  home_assistant_core_count = 2
  home_assistant_disk_size = "32G"
  public_ssh_key = file(var.public_key_path)
  pm_ssh_user = var.pm_ssh_user
  pm_ssh_private_key_path = var.pm_ssh_private_key_path
}