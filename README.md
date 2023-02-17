# Homelab Provisioning
[Available ansible playbooks](#available-playbooks) • [Terraform](#terraform) • [Home Assistant](#home-assistant) • [Network](./docs/network.md) • [Kubernetes Manifests](./kubernetes) 

This repository contains the ansible playbooks, terraform modules and kubernetes manifests to provision my home network environment. Ansible vault files that contain secrets haven't been committed to the public repo.

## Quickstart

First install the tools needed

```bash
brew install --cask 1password/tap/1password-cli
brew install ansible
brew install terraform
brew install kubectl
```

```bash
terraform init
terraform apply -var-file="prod.tfvars"
ansible-galaxy install -r requirements.yml
ansible-playbook -i inventory.ini provision-homelab.yml
```

## Overview

- PFsense is managed by hand
- Unifi equipment is managed by hand
- Terraform spins up all VMs
- Ansible is used for provisioning those + other computers and bootstrapping the k3s cluster
- ArgoCD deploys everything under [./kubernetes](./kubernetes)

### Network

See the documentation [here](./docs/network.md)

### Hardware
- Intel NUC i3-8109U/16Gb RAM/480Gb running Proxmox
- Raspberry PI 3b+ running Raspberry Pi OS
- Netgate SG-3100 with Pfsense as router/firewall/dns/vpn
- Unifi access points and switches

### Software
- [Home Assistant](./roles/home_assistant)
- [Mosquitto](./roles/mosquitto)
- [Zigbee2MQTT](./roles/zigbee2mqtt)
- [Ble2MQTT](./roles/ble2mqtt)
- [Traefik](./roles/traefik)

#### Currently waiting to be moved to k3s
- [Grafana](./roles/grafana)
- [InfluxDB](./roles/influxdb)

## Home Assistant
The Home Assistant instance currently runs on a VM inside a proxmox in a intel nuc, with a friend mqtt gateway running on a old Raspberry PI 3b+.

The configurations can be found [roles/home_assistant](./roles/home_assistant/files/home_assistant_config). Most of the integrations are through MQTT whenever it's available. [Overview of connections](./docs/network.md#home-assistant) 

### Home Assistant VM

* Traefik as a reverse proxy
* Mosquitto as a MQTT broker
* Home Asssistant

### Gateway computer
* Zigbee2MQTT with a Conbee II stick for various zigbee device communications
* BLE2MQTT Gateway (https://github.com/lordthorzonus/ble2mqtt-gateway) for BLE sensors

### Devices/Integrations in use

* Sensors
  * Xiaomi Aqara water and door/window sensors
  * Xiaomi Miio illuminance sensor
  * Netatmo weather station
  * Aeotec motion sensors
  * RuuviTags
  * MiFlora Flower Care sensors
* Energy
  * Shelly plug S for monitoring energy usage and remote control of some devices
  * [Home Assistant Glow](https://github.com/klaasnicolaas/home-assistant-glow) for energy monitoring
* Lights
  * Philips hue lamps for everything inside
  * Ledvance smart+ outdoor plug for Balcony lights
* Google
  * Nest hub as a command center, tts target and voice assistant
* Media
  * Samsung Q8 Smart TV
  * Denon X3400H AVR network receiver
* Vacuum
  * Roborock S7


## Terraform

### Running

Set the proxmox variables
```bash
cp example.tfvars prod.tfvars
terraform init
terraform plan -var-file="prod.tfvars"
terraform apply -var-file="prod.tfvars"
```

## Ansible

The inventory.ini is updated manually for now. So run first the terraform if you are provisioning new servers and modify inventory.ini after that. 

### Running

First remember to 

```bash
ansible-galaxy install -r requirements.yml
```

```bash
ansible-playbook playbooks/your-playbook.yml -i inventory.ini
```

Available playbooks are in [./playbooks](./playbooks)