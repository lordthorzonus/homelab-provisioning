terraform {
  required_providers {
    proxmox = {
      source = "Telmate/proxmox"
      version = "2.9.13"
    }
  }
}

resource "null_resource" "cloud_init_user_data_file" {
  triggers = {
    user_data_file = filemd5("${path.module}/files/home_assistant_user_data.yml.tftpl")
  }

  connection {
    type = "ssh"
    user = var.pm_ssh_user
    private_key = file(var.pm_ssh_private_key_path)
    host = "192.168.10.10"
    timeout = "30s"
  }

  provisioner "file" {
    content = templatefile("${path.module}/files/home_assistant_user_data.yml.tftpl", {
      ssh_key: var.public_ssh_key
    })

    destination = "/var/lib/vz/snippets/home_assistant_user_data.yml"
  }
}

resource "proxmox_vm_qemu" "home-assistant-server" {
  depends_on = [null_resource.cloud_init_user_data_file]

  name = "home-assistant01"
  desc = "Main server for home-automation"
  tags = "docker_host"
  target_node = var.home_assistant_target_node
  os_type = "cloud-init"
  clone = "ubuntu-2204-cloudinit-template"

  ciuser = "provisioner"
  cloudinit_cdrom_storage = "local-lvm"
  cicustom = "user=local:snippets/home_assistant_user_data.yml"

  cores = var.home_assistant_core_count
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
    size = var.home_assistant_disk_size
    backup = 1
  }

  serial {
    id = 0
    type = "socket"
  }

  network {
    model = "virtio"
    bridge = "vmbr0"
    tag = 30
    firewall = false
    macaddr = "72:4E:FA:9A:D6:B9"
  }

  ipconfig0 = "ip=dhcp"
}