# Network

## Overview of network

### Current VLANs
- LAN 192.168.5.1/24
  - All the network equipment are here
- VLAN 10 Main 192.168.10.1/24
  - Trusted VLAN with access to everything
- VLAN 30 IoT 192.168.30.1/24
  - Cannot access anything but Internet and devices in same VLAN
- VLAN 50 Media 192.168.50.1/24
  - Cannot access anything but Internet and UPNP is allowed for certain devices
- VPN 10.10.0.1/24

### Overview of Firewall rules
- DNS everything else but 192.168.5.1 is blocked
  - All DNS calls are redirected here with NAT for VLAN 10, 30 and 50 + VPN
  - Some servers need to do DNS1 acme challenges -> they are allowed to access other DNS servers
  - PfBlocker blocks a lot of dns requests and Ips
- Traffic between VLANS is denied
  - Main VLAN can access everything
  - Also remote VP
  - Home assistant can access DENON 3400 in Media VLAN


### Network Diagram
```mermaid
flowchart TD
    wan(WAN 1000/100) --> router(fa:fa-router Netgate SG-3100 <br> 192.168.5.1 <br> router, dns, firewall)
    wireguard(WireGuard VPN <br> 10.10.0.1/24) --> router
    
    subgraph "Network closet"
        router-->switch1(fa:fa-ethernet Main Switch <br> 192.168.5.2)
    end
   
    subgraph "Office"
        switch1-->switch2(Office Switch <br> 192.168.5.5)
        switch2-- PoE -->ap1(fa:fa-wifi Unifi AP FlexHD <br> 192.168.5.6)
        switch2-- vlan 10 -->comp1(fa:fa-computer Main gaming computer <br> 192.168.10.2)
        switch2--> server1(fa:fa-server Intel NUC <br> 192.168.10.10 <br> Proxmox host)
    end
    
    subgraph nuc [Intel NUC]
        vm1(fa:fa-server Home Assistant VM <br> 192.168.30.11 <br> Ubuntu 22.04 LTS)
        vm2(fa:fa-server K3S Server <br> 192.168.10.40 <br> Ubuntu 22.04 LTS)
        vm3(fa:fa-server K3S Agent 1 <br> 192.168.10.41 <br> Ubuntu 22.04 LTS)
        vm4(fa:fa-server K3S Agent 2 <br> 192.168.10.42 <br> Ubuntu 22.04 LTS)
    end
    
    server1-.->nuc
    
    subgraph home_assistant [Home Assistant VM]
        container1(fa:fa-docker Home Assistant <br> home-assistant.lan)
        container2(fa:fa-docker Mosquitto <br> mqtt.lan)
        container3(fa:fa-docker Traefik <br> traefik-home-assistant.lan)
    end

    vm1-. vlan 30 .->home_assistant

    subgraph "Living Room"
        switch1-->switch3("Living Room Switch <br> 192.168.5.4")
        switch3-- vlan 30 -->server2(fa:fa-server Rasperry PI <br> 192.168.30.10 <br> BLE/Zigbee Gateway)
        switch3-- vlan 30 -->hue1(fa:fa-lightbulb Philips HUE <br> 192.168.30.2 <br> BLE/Zigbee Gateway)
        switch3-- vlan 50 -->playstation(fa:fa-gamepad Playstation 5 <br> 192.168.50.3)
        switch3-- vlan 50 -->comp2(fa:fa-computer Media PC <br> 192.168.50.2 <br> Windows 11)
        switch3-- vlan 50 -->av1(fa:fa-radio Denon 3400 <br> 192.168.50.4 <br> AV Receiver)
        switch3-- vlan 50 -->tv1(fa:fa-tv Samsung Q8D <br> 192.168.50.5 <br> AV Receiver)
        switch3-- PoE -->ap2(fa:fa-wifi Unifi AP FlexHD <br> 192.168.5.5)
    end

    subgraph pi [Rasperry PI]
        container4(fa:fa-docker zigbee2MQTT <br> zigbee2mqtt.lan)
        container5(fa:fa-docker BLE2MQTT)
        container6(fa:fa-docker Traefik <br> traefik-gateway.lan)
    end

    server2-.->pi

```

### Wifi networks
```mermaid
flowchart TD
    subgraph wifi1 [Main WiFi vlan10]
        laptop1(Work Laptop 1 <br> DHCP)
        laptop2(Work Laptop 2 <br> DHCP)
        laptop3(Work Laptop 3 <br> DHCP)
        laptop4(Personal Laptop 1 <br> DHCP)
        laptop5(Personal Laptop 2 <br> DHCP)
    end


    subgraph wifi2 [IoT WiFi vlan30]
        iot1(Chromecast Ultra <br> 192.168.30.5)
        iot2(Withings Body+ <br> DHCP)
        iot3(Dyson PureCool HP04 <br> DHCP)
        iot4(Kindle <br> DHCP)
        iot5(Nintendo Switch <br> DHCP)
        iot6(Roborock S7 <br> 192.168.30.4)
        iot7(Home assistant glow <br> DHCP)
        iot8(Shelly Plug Office <br> 192.168.30.40)
        iot9(Shelly Plug Fridge <br> 192.168.30.41)
        iot10(Google Nest <br>)
    end

```

### Home assistant
```mermaid
flowchart TD

    subgraph Local
    ha1(Home Assistant) -- MQTT --> cont2(Mosquitto <br> MQTT Broker)  
    cont2 -- MQTT --> cont1(Zigbee2MQTT)
    
    cont1-- Zigbee -->device1(Xiaomi Agara door sensor)
    cont1-- Zigbee -->device2(Xiaomi Agara water sensor)
    cont1-- Zigbee -->device3(Aeotec Motion Sensor)
    cont1-- Zigbee -->device4(Xiaomi Light sensor)
    
    cont2 -- MQTT -->cont3(BLE2MQTT)
    
    cont3-- BLE -->ruuvi1(Office RuuviTag)
    cont3-- BLE -->ruuvi2(Fridge RuuviTag)
    cont3-- BLE -->ruuvi3(Freezer RuuviTag)
    cont3-- BLE -->ruuvi4(Bathroom RuuviTag)
    cont3-- BLE -->ruuvi5(Storage RuuviTag)
    
    
    cont3-- BLE -->miflora1(MiFLora 1)
    cont3-- BLE -->miflora2(MiFLora 2)
    
    ha1 -- https --> hue(Philips Hue)
    ha1 -- https --> Denon3400
    end
    
    subgraph Cloud
        Netatmo
        Withings
        Roborock
        Google
    end
    
    ha1 -- https --> Cloud
    
```