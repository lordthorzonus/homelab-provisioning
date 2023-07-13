locals {
  pm_host = {
    "nuc1" = "192.168.5.10"
    "pve2" = "192.168.5.11"
  }
}
variable "home_assistant_target_node" {
  type = string
  description = "The proxmox node where the home assistant vm should be provisioned"

  validation {
    condition = contains(["nuc1"], var.home_assistant_target_node)
    error_message = "Not a valid target, should be a existing proxmox node like nuc1"
  }
}

variable "home_assistant_disk_size" {
  type = string
  default = "32G"
  description = "The disk size for home assistant vm eq 32G"
}

variable "home_assistant_core_count" {
  type = number
  default = 2
  description = "The core count for home assistant vm"
}

variable "main_vlan_network" {
  type = string
  default = "192.168.10.1/24"
}

variable "remote_vpn_vlan_network" {
  type = string
  default = "10.0.10.1/24"
}

variable "k3s_agent_count" {
  type = map(number)
  description = "The count of k3s agents inside a proxmox host"
  default = {
    "nuc1" = 2
    "pve2" = 1
  }
}

variable "k3s_agent_core_count" {
  type = map(number)
  description = "The core count for k3s agent vm"
  default = {
    "nuc1" = 2
    "pve2" = 4
  }
}

variable "k3s_agent_memory_amount" {
  type = map(number)
  description = "The memory amount for k3s agent vm"
  default = {
    "nuc1" = 4096
    "pve2" = 4096
  }
}

variable "k3s_agent_disk_size" {
  type = map(string)
  description = "The core count for k3s agent vm"
  default = {
    "nuc1" = "64G"
    "pve2" = "64G"
  }
}

variable "public_ssh_key" {
  type = string
  description = "The public key that can be used for ansible provisioning later on"
}

variable "pm_ssh_user" {
  type = string
  description = "The username used for provisioning files to proxmox nodes with ssh"
}

variable "pm_ssh_private_key_path" {
  type = string
  description = "The path to ssh key used for provisioning files to proxmox nodes with ssh"
}
