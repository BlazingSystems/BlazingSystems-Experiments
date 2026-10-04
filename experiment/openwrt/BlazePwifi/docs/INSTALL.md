# Installation

## Supported base

BlazePwifi v0.2 targets OpenWrt 25.12.x and is built in CI against OpenWrt 25.12.5.

## Existing OpenWrt

1. Back up the router configuration and confirm a recovery path.
2. Upload the BlazePwifi project directory.
3. Run installer/install.sh as root.
4. Save the printed admin and Vendo secrets.
5. Open the local HTTPS admin page. A self-signed certificate warning is expected.
6. Flash/provision the ESP8266 with the Vendo key, server LAN address and GPIO mapping.
7. Configure rates and any optional walled-garden domains in /etc/config/blazepwifi.

The installer preserves an existing BlazePwifi UCI configuration during upgrades and only adds missing v0.2 options. v0.1 MAC-keyed credit/session data is claimed into a browser device-token account on first use.

## Local endpoints

Defaults:

- Portal: http://LAN_IP:8080/
- Admin: https://LAN_IP:8443/admin.html
- Vendo API: http://LAN_IP:4455/cgi-bin/vendo

All three listeners are bound to the configured LAN address by the installer.

## Walled garden

Example:

    uci add_list blazepwifi.main.walled_domain='payment.example.com'
    uci add_list blazepwifi.main.walled_ip='203.0.113.10'
    uci commit blazepwifi
    /etc/init.d/blazepwifi restart

Use the payment/login provider's current documentation and keep the list minimal.

## Custom images

Run on Linux with curl, zstd, tar and make:

    ./build/build-openwrt-image.sh ruijie
    ./build/build-openwrt-image.sh x86_64

The build script verifies the official OpenWrt ImageBuilder checksum, injects the BlazePwifi overlay, and creates per-target SHA256SUMS.

## First-boot secrets

For custom images:

    uci -q get blazepwifi.main.admin_key
    uci -q get blazepwifi.main.vendo_key

Store them securely.

## Recovery

For the Ruijie RG-EW1200G Pro v1.1, verify U-Boot/TFTP recovery before field deployment. Never flash the v1.1 image onto a different hardware revision without matching upstream OpenWrt support.

## Before taking money

Bench-test the actual acceptor's voltage interface, pulse polarity, pulse width, debounce, ESP GPIO levels, relay/LED wiring, reboot/brownout behavior and repeated insertions.
