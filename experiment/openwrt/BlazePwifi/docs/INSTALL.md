# Installation

## Production image base

ImmortalWrt 25.12.2. The installer also accepts OpenWrt/ImmortalWrt 25.12.x systems using the `apk` package manager.

## Existing 25.12.x system

1. Back up the router configuration.
2. Copy the project to `/tmp` or `/root`.
3. Run `sh installer/install.sh` as root.
4. Save the generated admin and Vendo keys.
5. Provision the ESP8266 with the LAN IP, Vendo key and GPIO mapping.
6. Edit rates in `/etc/config/blazepwifi`, then `uci commit blazepwifi && /etc/init.d/blazepwifi restart`.

The installer does **not** replace your LAN IP, DHCP or SSID settings.

## Build custom images

Linux host requirements: `curl`, `zstd`, `tar`, `make`, `sha256sum`.

```sh
./build/build-openwrt-image.sh ruijie
./build/build-openwrt-image.sh x86_64
```

The build downloads the official ImmortalWrt 25.12.2 ImageBuilder, verifies its checksum against the official target `sha256sums`, builds the requested profile and writes flashable outputs plus checksums to `dist/`.

Ruijie output must contain both an initramfs recovery/install image and a sysupgrade image. x86 output must contain a combined EFI disk image. The build fails rather than reusing stale output when any required image is missing.

## Ruijie recovery rule

Before flashing, verify that U-Boot TFTP recovery works for the exact **RG-EW1200G Pro v1.1**. Keep an original recovery image and Ethernet/TFTP host available. Do not flash v1.1 images onto another hardware revision.

## First boot of a custom image

Custom images configure:
- gateway `10.0.0.1/19`
- IPv4-only hotspot DHCP, 8190 leases, 72-hour lease time
- open client-isolated SSIDs named `BlazePwifi`, `BlazePwifi-2`, etc.
- portal/admin listener :8080
- isolated ESP/Vendo listener :4455

Retrieve generated keys over SSH:

```sh
uci -q get blazepwifi.main.admin_key
uci -q get blazepwifi.main.vendo_key
```
