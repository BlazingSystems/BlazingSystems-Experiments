# BlazePwifi Standalone Rental Server

Current release: **v0.5.0-rental-rc.2**

This edition keeps the **complete BlazePwifi v0.5 software payload** on OpenWrt but activates and exposes only rental-related management. The dormant full-server code remains installed so a supported OpenWrt device can later be converted to full BlazePwifi without replacing it with a stripped product.

## Releases (2)

### [BlazePwifi Standalone Rental Server v0.5.0-rental-rc.2 — Latest Rental Release](https://github.com/BlazingSystems/BlazingSystems-Experiments/releases/tag/v0.5.0-rental-rc.2)

**Release candidate · published October 6, 2026**

Primary download for an existing OpenWrt router:

- **[Windows OneClick Installer](https://github.com/BlazingSystems/BlazingSystems-Experiments/releases/download/v0.5.0-rental-rc.2/BlazePwifi-Rental-Standalone-Windows-OneClick-v0.5.0-rental-rc.2.zip)** — recommended for R281, EW1200G Pro, and compatible OpenWrt installations.

Other release assets:

- [ESP8266 BIN](https://github.com/BlazingSystems/BlazingSystems-Experiments/releases/download/v0.5.0-rental-rc.2/BlazePwifi-Rental-Standalone-ESP8266.bin) · [ESP8266 INO](https://github.com/BlazingSystems/BlazingSystems-Experiments/releases/download/v0.5.0-rental-rc.2/BlazePwifi-Rental-Standalone-ESP8266.ino)
- [ESP32 BIN](https://github.com/BlazingSystems/BlazingSystems-Experiments/releases/download/v0.5.0-rental-rc.2/BlazePwifi-Rental-Standalone-ESP32.bin) · [ESP32 INO](https://github.com/BlazingSystems/BlazingSystems-Experiments/releases/download/v0.5.0-rental-rc.2/BlazePwifi-Rental-Standalone-ESP32.ino)
- [EW1200G Pro v1.1 sysupgrade BIN](https://github.com/BlazingSystems/BlazingSystems-Experiments/releases/download/v0.5.0-rental-rc.2/BlazePwifi-Rental-Standalone-EW1200G-Pro-v1.1-sysupgrade.bin)
- [EW1200G Pro recovery initramfs](https://github.com/BlazingSystems/BlazingSystems-Experiments/releases/download/v0.5.0-rental-rc.2/OpenWrt-EW1200G-Pro-v1.1-recovery-initramfs.bin)
- [x86_64 BIOS IMG.GZ](https://github.com/BlazingSystems/BlazingSystems-Experiments/releases/download/v0.5.0-rental-rc.2/BlazePwifi-Rental-Standalone-x86_64-BIOS.img.gz) · [x86_64 UEFI IMG.GZ](https://github.com/BlazingSystems/BlazingSystems-Experiments/releases/download/v0.5.0-rental-rc.2/BlazePwifi-Rental-Standalone-x86_64-UEFI.img.gz)
- [OpenWrt manual bundle](https://github.com/BlazingSystems/BlazingSystems-Experiments/releases/download/v0.5.0-rental-rc.2/BlazePwifi-Rental-Standalone-OpenWrt-v0.5.0-rental-rc.2.tar.gz)
- [BlazeRental v0.5.0 TEST APK](https://github.com/BlazingSystems/BlazingSystems-Experiments/releases/download/v0.5.0-rental-rc.2/BlazeRental-v0.5.0-TEST.apk)
- [SHA256SUMS](https://github.com/BlazingSystems/BlazingSystems-Experiments/releases/download/v0.5.0-rental-rc.2/SHA256SUMS) · [Release manifest](https://github.com/BlazingSystems/BlazingSystems-Experiments/releases/download/v0.5.0-rental-rc.2/RELEASE-MANIFEST.json)

[Open the Rental release archive](./releases/) for notes and older Rental releases.

### [v0.5.0-rental-rc.1](https://github.com/BlazingSystems/BlazingSystems-Experiments/releases/tag/v0.5.0-rental-rc.1)

Superseded by rc.2. This older build used the earlier ESP multi-slot direction and is kept only for release history.

> GitHub's native **Releases** page belongs to the whole repository, not to an individual subfolder. This Rental folder therefore keeps its own release index here while the downloadable binaries remain normal GitHub Release assets.

## OpenWrt URL model

The existing router UI keeps its own routes. BlazePwifi adds only:

- `https://LocalIP/rental/` — rental management console
- `http://LocalIP/cgi-bin/rental` — BlazeRental application API
- `http://LocalIP:4455/cgi-bin/vendo` — authenticated remote ESP coinslot API

Examples such as `/` for EasyMode/basic administration and `/admin` or `/cgi-bin/luci` for advanced administration remain whatever the router already provides.

Rental Standalone does **not** modify WAN, LAN, wireless, cellular, repeater, DNS, or firewall UCI packages. Internet-interface ownership begins only after an explicit conversion to full BlazePwifi:

```sh
/usr/sbin/blazepwifi-rental-upgrade --full
```

That conversion backs up the existing router and rental state before activating the dormant full-server defaults and BlazePwifi hotspot/firewall ownership.

## Credit model

There is no customer captive portal. Rental phones remain on the same reachable IP/Wi-Fi network as the server and the BlazeRental launcher acts as the customer rental interface.

Credit can be added by the rental administrator, a supported local coinslot interface, or authenticated remote ESP8266/ESP32 coinslot interfaces. A remote coinslot is dynamically reserved for the phone that starts an insert-coin window; it is not permanently tied to one phone.

## ESP editions

ESP8266 and ESP32 use one lightweight root console at `http://assigned-ip/`.

They support three modes:

1. **Rental Server**
2. **Rental Server + one Local Coin Slot**
3. **Remote Coin Slot Interface**

Modes 1 and 2 can bind additional remote ESP coin interfaces. Mode 3 makes the ESP a single remote coinslot for an ESP/OpenWrt Standalone server or a full BlazePwifi server.

The ESP firmware itself cannot become full Linux/OpenWrt BlazePwifi.

## Installation priority

The primary OpenWrt release experience is the Windows OneClick installer bundle. It prompts for target IP, SSH user/password, verifies the SSH host key, uploads the release bundle, runs target detection and installation, then reports the final `/rental/` URL.

Manual tarball installation and real target-specific firmware images remain available as additional assets when a trustworthy hardware-specific OpenWrt image can be built.
