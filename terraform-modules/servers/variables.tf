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