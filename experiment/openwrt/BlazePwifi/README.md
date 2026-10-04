# BlazePwifi

BlazePwifi is a clean-room, open-source PisoWiFi/captive-portal platform for OpenWrt. It uses an OpenWrt router or x86 controller plus one or more ESP8266 coin/vendo controllers.

Target base: OpenWrt 25.12.x
Release candidate: 0.2.0-rc.1
Primary build target: OpenWrt 25.12.5

## Hardware targets

- Ruijie RG-EW1200G Pro v1.1 — ramips/mt7621, 128 MB RAM, 16 MB flash
- x86_64 OpenWrt — generic PC/thin-client deployment
- ESP8266 / NodeMCU — external coin-slot controller

## What v0.2 adds

- Browser-backed device identity that survives Android/iOS private-MAC changes.
- Persistent credit and timed sessions.
- Pause/resume.
- One-time vouchers.
- Multiple Vendos with online discovery.
- Target-bound signed coin events with idempotent retry protection and ESP8266 LittleFS brownout journal.
- WPA2-protected ESP setup AP.
- Dynamic walled garden for e-payment/login providers.
- nftables enforcement that remains subordinate to normal firewall4 policy.
- HTTPS-only local admin interface.
- v0.1 state migration.
- Repeated CI validation, ESP8266 compilation, and Ruijie/x86 firmware ImageBuilder jobs.

## Quick install

Copy the project to an OpenWrt 25.12.x system and run installer/install.sh as root.

The installer prints the generated admin and Vendo keys once.

Typical local endpoints:

- Portal: http://10.0.0.1:8080/
- Admin: https://10.0.0.1:8443/admin.html
- ESP API: http://10.0.0.1:4455/cgi-bin/vendo

The exact address follows the OpenWrt LAN configuration. The admin certificate is locally generated, so the browser may show a self-signed certificate warning.

## Build flashable images

Run build/build-openwrt-image.sh ruijie or build/build-openwrt-image.sh x86_64.

Outputs and SHA-256 files are written below dist/<target>/. The Ruijie target emits the upstream-style `initramfs-kernel.bin` install image plus `squashfs-sysupgrade.bin`; x86_64 emits BIOS and EFI `.img.gz` disk images.

## Validation status

The project has automated checks for:

- shell syntax and hardening invariants;
- coin → credit → session accounting;
- lost-ACK duplicate coin retry;
- wrong-target coin rejection;
- voucher one-time use;
- pause/resume;
- private-MAC rotation;
- router tmpfs loss, persistent coin-window recovery, and accounting reboot behavior;
- v0.1 state migration;
- ESP8266 firmware compilation;
- Ruijie and x86_64 OpenWrt ImageBuilder output.

Automated builds are not a substitute for physical flash/recovery testing, real coin-acceptor electrical validation, brownout testing, or long-duration load testing.

## Repository map

- openwrt/rootfs/ — runtime overlay
- installer/ — install/uninstall
- esp8266/ — Vendo firmware
- build/ — OpenWrt ImageBuilder automation
- tests/ — regression and persistence tests
- docs/ARCHITECTURE.md — system design
- docs/PROTOCOL.md — Vendo protocol
- docs/SECURITY.md — deployment/security model
- docs/RECONCILIATION.md — WiFi5/public-source reconciliation
- AUDIT.md — production-readiness audit

## Clean-room notice

BlazePwifi does not contain the analyzed commercial PisoWiFi application binaries, license mechanisms, private keys, databases, branding, or proprietary portal assets. Publicly documented behavior and MIT-licensed integration material were used only as interoperability/design references.
