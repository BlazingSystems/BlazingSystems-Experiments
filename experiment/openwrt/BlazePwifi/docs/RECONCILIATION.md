# WiFi5 reference reconciliation

This document records architecture-level findings used for BlazePwifi's clean-room implementation.

## Base firmware

- Ruijie reference: WiFi5-Soft 25.12.0, revision `r37854-4b24da3b4c5c`, ramips/mt7621.
- That revision maps to ImmortalWrt 25.12.0.
- x86 reference contains build paths under `immortalwrt-24` and identifies WiFi5-Soft 24.10.4.
- BlazePwifi therefore moved from upstream OpenWrt to current stable ImmortalWrt 25.12.2 for production images.

## Public resource endpoint

The reference x86 scripts point at `files.wifi5-soft.com` for Orange Pi 5 / 5 Plus SPI loader and firmware resources:
- `files/others/rkspi_loader-opi-5.img`
- `files/others/firmware-opi-5.bin`
- `files/others/rkspi_loader-opi-5-plus.img`
- `files/others/firmware-opi-5-plus.bin`

Those files are board-boot resources and are not copied into BlazePwifi. They establish that the WiFi5 project supports dedicated SBC installation paths beyond the Ruijie and x86 targets.

## Server architecture observed

- x86 app under `/soft`, router app under `/lib/lite`
- dedicated persistent x86 storage under `/mnt/wifi5`
- DHCP client event reporting to a local backend
- nftables-based hotspot authorization
- x86 Nginx listener on 4455 proxying to a local sub-vendo service
- remote Vendo/sub-vendo registration and configurable coin/LED/relay GPIO metadata

## Network defaults observed

- gateway 10.0.0.1
- netmask 255.255.224.0 (/19)
- DHCP start 2, limit 8190, lease 72h
- DHCPv6 disabled on hotspot interfaces

BlazePwifi custom images reproduce these useful network-level behaviors with original code while avoiding proprietary binaries and protocol copying.
