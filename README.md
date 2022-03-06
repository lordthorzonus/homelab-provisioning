# Homelab Provisioning
This repository contains the playbooks to provision my home network environment. Ansible vault files that contain secrets haven't been committed to the public repo. Currently, only contains the playbooks for setup of Home Assitant. 

## Home Assistant
The Home Assistant instance currently runs on an old Raspberry PI 3B+.

### Other related software running besides Home Assistant

* Traefik as a reverse proxy
* Mosquitto as a MQTT broker
* Zigbee2MQTT with a Conbee II stick for various zigbee device communications

### Devices/Integrations in use

* Sensors
  * Xiaomi Aqara water and door/window sensors
  * Xiaomi Miio illuminance sensor
  * Netatmo weather station
  * Aeotec motion sensors
* Energy
  * Shelly plug S for monitoring energy usage and remote control of some devices
* Lights
  * Philips hue lamps for everything inside
  * Ledvance smart+ outdoor plug for Balcony lights
* Google
  * Nest hub as a command center, tts target and voice assistant
* Media
  * Samsung Q8 Smart TV
  * Denon X3400H AVR network receiver





