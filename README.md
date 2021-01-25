# Raspberry Pi Wifi-AP
Transform your PI into a Wireless Router (DHCP and WPA2 already insisde)

Checkout my `Docker Hub`: [`https://hub.docker.com/r/namths/rpi-wifi-ap`](https://hub.docker.com/r/namths/rpi-wifi-ap)

# Docker container stack: hostap + dhcp server = wifi-ap

Designed to work on **Raspberry Pi** (arm) using as base image alpine Linux (very little size).

# Idea

Since my last change on ISP, they put a cable modem with a horrible Wireless, it drops lots of packets, and I didn't want to put an extra AP or wireless router.

Most of the time use wireless devices on same room so I decided to try to convert my current Pi on a small Access Point using a small USB dongle.


# Requirements

On the host system, the ralink firmware (in my case) should be installed so you can use it on AP mode.

On debian/raspbian 32bit armhf and Ubuntu Core 20.04 arm64:

```
apt-get install firmware-ralink
```

Make sure your USB support AP mode:

```
# iw list
...
        Supported interface modes:
                 * IBSS
                 * managed
                 * AP
                 * AP/VLAN
                 * WDS
                 * monitor
                 * mesh point
...
```

Set country regulations, for example, to Spain set:

```
# iw reg set ES
country ES: DFS-ETSI
        (2400 - 2483 @ 40), (N/A, 20), (N/A)
        (5150 - 5250 @ 80), (N/A, 23), (N/A), NO-OUTDOOR
        (5250 - 5350 @ 80), (N/A, 20), (0 ms), NO-OUTDOOR, DFS
        (5470 - 5725 @ 160), (N/A, 26), (0 ms), DFS
        (57000 - 66000 @ 2160), (N/A, 40), (N/A)
```

# Build / run

I've already uploaded the image to docker hubs, so you can run it from there like this: [`namths/rpi-wifi-ap:latest`](https://hub.docker.com/r/namths/rpi-wifi-ap) 

```
sudo docker run -d -t \
  -e INTERFACE=wlan0 \
  -e CHANNEL=6 \
  -e SSID=PI \
  -e AP_ADDR=192.168.254.1 \
  -e SUBNET=192.168.254.0 \
  -e WPA_PASSPHRASE=12345678 \
  -e OUTGOINGS=eth0 \
  --privileged \
  --net host \
  namths/rpi-wifi-ap:latest
```

Docker-compose file: docker-compose.yml

```
version: '3.0'
services:
  rpi-wifi-ap:
    container_name: wifi-ap
    hostname: wifi-ap
    image: namths/rpi-wifi-ap:latest
    network_mode: host
    privileged: true
    restart: always
    environment:
      INTERFACE: wlan0
      CHANNEL: 6
      SSID: PI
      AP_ADDR: 192.168.254.1
      SUBNET: 192.168.254.0
      WPA_PASSPHRASE: 12345678
      OUTGOINGS: eth0
```

But before this, hostap usually requires that wlan0 interface to be already up, so before `docker run` take the interface up:

```
/sbin/ifconfig wlan0 192.168.254.1/24 up
```

Also you should have a driver to enable hostap on your USB wifi (if you are using Pi 3 integrated WiFI you won't need this).

```
apt-get install firmware-ralink
```


Make sure you are not runing `wpa_supplicant` on your host machine or docker container will tell messages like `wlan0: Could not connect to kernel driver`.

```
# ps uaxf |grep wpa_supplicant
root     22619  0.0  0.4   6616  3700 ?        Ss   22:04   0:00 /sbin/wpa_supplicant -s -B -P /run/wpa_supplicant.wlan0.pid -i wlan0 -D nl80211,wext -C /run/wpa_supplicant
```

## Environment Variables

| Name            | Required | Description                    | Default Value |
|:---------------:|:--------:|:------------------------------:|:-------------:|
| INTERFACE       | true     | The wireless interface         |               |
| CHANNEL         | false    | WiFi Channel to use            | 6             |
| SSID            | false    | WiFi Name                      | PI            |
| AP\_ADDR        | false    | Access Point IP Address        | 192.168.254.1 |
| SUBNET          | false    | WiFi network subnet            | 192.168.254.0 |
| WPA\_PASSPHRASE | false    | WiFi Password                  | 12345678      |
| OUTGOINGS       | false    | Interfaces to external traffic |               |
| HW\_MODE        | false    | Hardware protocol              | g             |
