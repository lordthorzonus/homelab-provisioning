resource "random_password" "k3s_token" {
  length = 48
  special = false
}

resource "null_resource" "cloud_init_k3s_server_user_data_file_nuc1" {
  triggers = {
    user_data_file = filemd5("${path.module}/files/k3s_server_user_data.yml")
    k3s_token : random_password.k3s_token.result,
  }

  connection {
    type = "ssh"
    user = var.pm_ssh_user
    private_key = file(var.pm_ssh_private_key_path)
    host = local.pm_host["nuc1"]
    timeout = "30s"
  }

  provisioner "file" {
    content = templatefile("${path.module}/files/k3s_server_user_data.yml", {
      ssh_key : var.public_ssh_key,
      proxmox_host : "nuc1",
      k3s_token : random_password.k3s_token.result,
      server_number : 1,
      main_vlan_network : var.main_vlan_network,
      remote_vpn_vlan_network : var.remote_vpn_vlan_network,
      k3s_private_ip : ""
    })

    destination = "/var/lib/vz/snippets/k3s_server_user_data.yml"
  }
}

resource "proxmox_vm_qemu" "k3s_server" {
  depends_on = [null_resource.cloud_init_k3s_server_user_data_file_nuc1]

  name = "k3s-server-1"
  desc = "K3S Server"
  tags = "k3s_server"
  target_node = "nuc1"
  os_type = "cloud-init"
  clone = "ubuntu-2204-cloudinit-template"
  onboot = true

  ciuser = "provisioner"
  cloudinit_cdrom_storage = "local-lvm"
  cicustom = "user=local:snippets/k3s_server_user_data.yml"

  cores = 1
  sockets = 1
  memory = 4096
  agent = 1

  ssh_user = "provisioner"
  sshkeys = <<EOF
${var.public_ssh_key}
EOF

  disk {
    type = "scsi"
    storage = "local-lvm"
    size = "32G"
    backup = false
  }

  serial {
    id = 0
    type = "socket"
  }

  network {
    model = "virtio"
    bridge = "vmbr0"
    tag = 10
    firewall = false
    macaddr = "FC:03:F2:22:9E:12"
  }

  ipconfig0 = "ip=192.168.10.40/24,gw=192.168.10.1"
}

locals {
  agent_network_mac_addresses = {
    0 = "E0:B1:D5:8C:79:3E"
    1 = "1E:AA:66:A9:52:9D"
    2 = "8E:FB:06:C5:89:72"
    3 = "52:2E:F5:A0:35:76"
  }
}

resource "null_resource" "cloud_init_k3s_agent_user_data_file_nuc1" {
  count = var.k3s_agent_count["nuc1"]
  triggers = {
    user_data_file = filemd5("${path.module}/files/k3s_agent_user_data.yml")
    k3s_token : random_password.k3s_token.result,
  }

  connection {
    type = "ssh"
    user = var.pm_ssh_user
    private_key = file(var.pm_ssh_private_key_path)
    host = local.pm_host["nuc1"]
    timeout = "30s"
  }

  provisioner "file" {
    content = templatefile("${path.module}/files/k3s_agent_user_data.yml", {
      ssh_key : var.public_ssh_key,
      proxmox_host : "nuc1",
      k3s_private_ip : proxmox_vm_qemu.k3s_server.default_ipv4_address
      k3s_token : random_password.k3s_token.result,
      remote_vpn_vlan_network : var.remote_vpn_vlan_network,
      agent_number : count.index + 1,
      main_vlan_network : var.main_vlan_network
    })

    destination = "/var/lib/vz/snippets/k3s_agent_user_data_${count.index + 1}.yml"
  }
}

resource "proxmox_vm_qemu" "k3s_agent_nuc1" {
  depends_on = [null_resource.cloud_init_k3s_agent_user_data_file_nuc1, proxmox_vm_qemu.k3s_server]
  count = var.k3s_agent_count["nuc1"]

  name = "k3s-agent-${count.index + 1}"
  desc = "K3S Agent"
  tags = "k3s_agent"
  target_node = "nuc1"
  os_type = "cloud-init"
  clone = "ubuntu-2204-cloudinit-template"
  onboot = true

  ciuser = "provisioner"
  cloudinit_cdrom_storage = "local-lvm"
  cicustom = "user=local:snippets/k3s_agent_user_data_${count.index + 1}.yml"

  cores = var.k3s_agent_core_count["nuc1"]
  sockets = 1
  memory = var.k3s_agent_memory_amount["nuc1"]
  agent = 1

  ssh_user = "provisioner"
  sshkeys = <<EOF
${var.public_ssh_key}
EOF

  disk {
    type = "scsi"
    storage = "local-lvm"
    size = var.k3s_agent_disk_size["nuc1"]
    backup = false
  }

  serial {
    id = 0
    type = "socket"
  }

  network {
    model = "virtio"
    bridge = "vmbr0"
    tag = 10
    firewall = false
    macaddr = local.agent_network_mac_addresses[count.index]
  }

  ipconfig0 = "ip=192.168.10.4${count.index +1}/24,gw=192.168.10.1"

}
