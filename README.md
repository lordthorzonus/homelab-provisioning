# Homelab Provisioning
[Available ansible playbooks](#available-playbooks) • [Terraform](#terraform) • [Home Assistant](#home-assistant)

This repository contains the ansible playbooks and terraform files to provision my home network environment. Ansible vault files that contain secrets haven't been committed to the public repo.

## Quickstart

```bash
ansible-galaxy install -r requirements.yml
terraform init
terraform apply -var-file="prod.tfvars"
ansible-playbook -i inventory.ini provision-homelab.yml
```

## Overview

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

## Home Assistant
The Home Assistant instance currently runs on a VM inside a proxmox in a intel nuc, with a friend mqtt gateway running on a old Raspberry PI 3b+.

The configurations can be found [roles/home_assistant](./roles/home_assistant/files/home_assistant_config). Most of the integrations are through MQTT whenever it's available. 

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

#### Available playbooks
- provision-home-assistant-server.yml
  - Used for Provisioning/updating everything
- update-home-assistant.yml
  - Only update home assistant and it's configs

```bash
ansible-playbook playbooks/your-playbook.yml -i inventory.ini
```
