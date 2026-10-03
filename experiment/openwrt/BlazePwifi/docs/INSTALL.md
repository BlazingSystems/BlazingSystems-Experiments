# Installation

## Supported base

OpenWrt 25.12.x. The initial release is developed against 25.12.5.

On a custom firmware image, retrieve the generated first-boot secrets with `uci -q get blazepwifi.main.admin_key` and `uci -q get blazepwifi.main.vendo_key`.

## Existing OpenWrt

1. Upload the BlazePwifi project directory to `/tmp` or `/root`.
2. Run `sh installer/install.sh` as root.
3. Save the generated admin and Vendo keys.
4. Connect the ESP8266 to the BlazePwifi LAN and provision it with the Vendo key.
5. Configure rates in `/etc/config/blazepwifi`, then run `uci commit blazepwifi && /etc/init.d/blazepwifi restart`.

## Custom images

On Linux with `curl`, `zstd`, `tar` and `make`:

```sh
./build/build-openwrt-image.sh ruijie
./build/build-openwrt-image.sh x86_64
```

The script downloads the official OpenWrt 25.12.5 ImageBuilder, verifies it against the official `sha256sums`, injects the BlazePwifi root filesystem and copies resulting installable images to `dist/`.

## Recovery

For Ruijie RG-EW1200G Pro v1.1, preserve access to the documented U-Boot/TFTP recovery path before flashing custom images. Never test an image intended for v1.1 on another hardware revision unless that revision has its own verified OpenWrt support.
