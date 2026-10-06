# BlazePwifi Standalone Rental Server — v0.5.0-rental-rc.2

This edition keeps the **complete BlazePwifi v0.5 software payload** on OpenWrt but activates/exposes only rental-related management. The dormant full-server code remains installed so the OpenWrt device can later be converted to full BlazePwifi without replacing it with a stripped product.

## OpenWrt URL model

The existing router UI keeps its own routes. BlazePwifi adds only:

- `https://LocalIP/rental/` — rental management console
- `http://LocalIP/cgi-bin/rental` — BlazeRental application API
- `http://LocalIP:4455/cgi-bin/vendo` — authenticated remote ESP coinslot API

Examples such as `/` for EasyMode/basic admin and `/admin` or `/cgi-bin/luci` for advanced admin remain whatever the router already provides.

Rental Standalone does **not** modify WAN, LAN, wireless, cellular, repeater, DNS or firewall UCI packages. Internet-interface ownership begins only after an explicit conversion to full BlazePwifi:

```sh
/usr/sbin/blazepwifi-rental-upgrade --full
```

That conversion backs up the existing router and rental state, then activates the dormant full-server defaults and BlazePwifi hotspot/firewall ownership.

## Credit model

There is no customer captive portal. Rental phones remain on the same reachable IP/Wi-Fi network as the server and the BlazeRental launcher acts as the customer rental interface.

Credit can be added by:
- rental administrator/manual time;
- a supported local hardware interface when a platform provides one;
- authenticated remote ESP8266/ESP32 coin interfaces.

A remote coinslot is dynamically reserved for the phone that starts an insert-coin window; it is not permanently tied to one phone.

## ESP editions

ESP8266 and ESP32 use one lightweight root console at `http://assigned-ip/`. They support:
1. Rental Server;
2. Rental Server + **one** local physical coinslot;
3. Remote Coin Slot Interface.

Modes 1 and 2 can bind additional remote ESP coin interfaces. Mode 3 makes the ESP a single remote coinslot for an ESP/OpenWrt Standalone server or a full BlazePwifi server.

The ESP firmware itself cannot become full Linux/OpenWrt BlazePwifi.

## Installation priority

The primary OpenWrt release experience is the Windows one-click installer bundle. It prompts for target IP, SSH user/password, verifies the SSH host key, uploads the immutable release bundle, runs target detection and installation, then reports the final `/rental/` URL.

Manual tarball installation and real target-specific firmware images remain available as additional assets when a trustworthy hardware-specific OpenWrt image can be built.
