# BlazePwifi

BlazePwifi is a clean-room prepaid Wi-Fi/captive-portal platform for OpenWrt-family systems, designed around a small router or x86 gateway plus one or more ESP8266 coin/vendo controllers.

**Production base:** ImmortalWrt 25.12.2 (current stable, chosen after reconciliation with the WiFi5 reference firmware).

**Portable install target:** OpenWrt or ImmortalWrt 25.12.x with `apk`, `uhttpd`, and nftables.

**Hardware targets**
- Ruijie RG-EW1200G Pro v1.1 — ramips/mt7621, 128 MB RAM, 16 MB flash
- x86_64 gateway — UEFI/BIOS PC or thin client
- ESP8266 / NodeMCU — external coin-slot controller

## Release status

`1.0.0-rc1` is the first release candidate after a full code audit and reconciliation against the supplied WiFi5 Ruijie/x86 firmware plus its public file endpoints. It is CI-buildable into flashable Ruijie and x86 images. Physical flash/recovery and real coin-acceptor electrical validation remain mandatory before unattended commercial deployment.

## What it implements

- nftables paid/unpaid MAC authorization and HTTP captive redirect
- persistent credit, rates, vouchers, timed sessions, connect/extend/disconnect
- IPv4-only hotspot by default on custom images to prevent IPv6 bypass
- 10.0.0.1/19, 8,190-address DHCP pool, 72-hour leases on custom images
- isolated client APs on router-class custom images
- isolated public portal, HTTPS-only admin UI, and Vendo API listeners bound to the LAN address
- ESP8266 setup fallback AP, interrupt-driven coin GPIO, LED and relay controls
- server-bound coin-window nonce plus monotonic sequence anti-replay
- no heartbeat/session polling writes to flash
- installer/uninstaller for existing 25.12.x systems
- verified ImageBuilder pipeline for Ruijie and x86_64

## Install on an existing system

```sh
cd BlazePwifi
sh installer/install.sh
```

The installer preserves your existing LAN addressing and wireless configuration. Custom images use the WiFi5-compatible hotspot defaults described above.

Portal: `http://<LAN-IP>:8080/`

Admin: `https://<LAN-IP>:8443/admin.html` (self-signed certificate by default)

Vendo API: `http://<LAN-IP>:4455/cgi-bin/vendo`

## Build flashable images

```sh
./build/build-openwrt-image.sh ruijie
./build/build-openwrt-image.sh x86_64
```

Outputs are placed under `dist/<target>/` with `SHA256SUMS` and `BUILDINFO.txt`.

## Clean-room policy

No WiFi5 commercial application binary, private key, certificate, database, artwork, or proprietary source code is redistributed. BlazePwifi reimplements observed behavior using public ImmortalWrt/OpenWrt interfaces and original source.
