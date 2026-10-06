# BlazePwifi Standalone Rental Server

Current release: **v0.5.0-rental-rc.3**

This edition keeps the **complete BlazePwifi v0.5 software payload** on OpenWrt but activates and exposes only rental-related management. The dormant full-server code remains installed so a supported OpenWrt device can later be converted to full BlazePwifi.

## Releases (3)

### [BlazePwifi Standalone Rental Server v0.5.0-rental-rc.3 — Latest Rental Release](https://github.com/BlazingSystems/BlazingSystems-Experiments/releases/tag/v0.5.0-rental-rc.3)

**Windows OneClick first-SSH hotfix.**

Primary download:

- **[Windows OneClick Installer rc.3](https://github.com/BlazingSystems/BlazingSystems-Experiments/releases/download/v0.5.0-rental-rc.3/BlazePwifi-Rental-Standalone-Windows-OneClick-v0.5.0-rental-rc.3.zip)**

Also available in the same release: ESP8266/ESP32 BIN+INO, EW1200G Pro firmware, x86 BIOS/UEFI images, OpenWrt manual bundle, BlazeRental APK, manifest and SHA256 checksums.

### [v0.5.0-rental-rc.2](https://github.com/BlazingSystems/BlazingSystems-Experiments/releases/tag/v0.5.0-rental-rc.2)

Superseded by rc.3 because the Windows installer could terminate on PuTTY's first-connection host-key stderr before showing the host-key confirmation dialog. The server/ESP architecture from rc.2 remains the basis of rc.3.

### [v0.5.0-rental-rc.1](https://github.com/BlazingSystems/BlazingSystems-Experiments/releases/tag/v0.5.0-rental-rc.1)

Superseded. Kept for release history.

[Open the Rental release archive](./releases/).

> GitHub's native Releases page is repository-wide. This folder keeps the Rental project's own release index while binaries remain normal GitHub Release assets.

## OpenWrt URL model

The existing router UI keeps its own routes. BlazePwifi adds:

- `https://LocalIP/rental/` — rental management console
- `http://LocalIP/cgi-bin/rental` — BlazeRental application API
- `http://LocalIP:4455/cgi-bin/vendo` — authenticated remote ESP coinslot API

Rental Standalone does **not** modify WAN, LAN, wireless, cellular, repeater, DNS, or firewall UCI packages. Internet-interface ownership begins only after explicit conversion to full BlazePwifi:

```sh
/usr/sbin/blazepwifi-rental-upgrade --full
```

## Credit model

There is no customer captive portal. Rental phones stay on the same reachable IP/Wi-Fi network as the server. Credit can be added manually, through a supported local coinslot, or through authenticated remote ESP8266/ESP32 coin interfaces.

## ESP editions

ESP8266 and ESP32 use one lightweight root console at `http://assigned-ip/` and support:

1. **Rental Server**
2. **Rental Server + one Local Coin Slot**
3. **Remote Coin Slot Interface**

Modes 1 and 2 can bind additional remote ESP coin interfaces. Mode 3 turns the ESP into a single remote coinslot for a Standalone or full BlazePwifi server.

## Installation priority

For an existing OpenWrt router, use the Windows OneClick installer first. It prompts for target IP, SSH user/password, handles first-connection host-key verification in a GUI dialog, uploads the package, runs target detection and installation, and opens `/rental/`.
