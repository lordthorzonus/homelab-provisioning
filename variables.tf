variable "public_key_path" {
  type = string
  description = "The path to your public ssh key to be used for provisioning"
  default = "~/.ssh/id_rsa.pub"
}

variable "pm_user" {
  type = string
  description = "The user for communicating with proxmox API"
}

variable "pm_password" {
  type = string
  description = "The password for the user used with proxmox API"
}

variable "pm_ssh_user" {
  type = string
  description = "The username used for provisioning files to proxmox nodes with ssh"
}
variable "pm_ssh_private_key_path" {
  type = string
  description = "The path to ssh key used for provisioning files to proxmox nodes with ssh"
}