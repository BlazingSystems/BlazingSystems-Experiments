# BlazePwifi

BlazePwifi is a clean-room, open-source PisoWiFi/captive-portal platform for OpenWrt. It is designed around a small OpenWrt router or x86 OpenWrt server plus one or more ESP8266 coin/vendo controllers.

**Target base:** OpenWrt 25.12.x (primary validated design target: 25.12.5)

**Initial hardware targets**
- Ruijie RG-EW1200G Pro v1.1 — ramips/mt7621, mipsel_24kc, 128 MB RAM, 16 MB flash
- x86_64 OpenWrt — generic PC/thin-client deployment
- ESP8266 — external coin-slot / vendo controller

## Status

`0.1.0-alpha.1` is a production-oriented reconstruction milestone, not a claim of field validation. The repository contains the complete installable OpenWrt overlay, installer/uninstaller, captive portal, nftables enforcement, accounting/session engine, ESP8266 firmware, protocol documentation, and GitHub Actions packaging checks. Real coin acceptor pulse timing, device-specific network naming, and recovery behavior must be hardware-tested before commercial deployment.

## Design goals

- No copied commercial PisoWiFi server binaries, pages, certificates, or proprietary assets.
- Lightweight enough for 16 MB flash targets.
- MAC/IP session tracking with nftables authorization.
- Captive HTTP redirection while unpaid.
- Configurable time/credit rates.
- ESP8266 remote vendo over a small authenticated HTTP API.
- Persistent credit/session state with bounded flash writes.
- Same protocol on router-class and x86 OpenWrt systems.
- Recovery-safe install/uninstall paths.

## Quick install on OpenWrt 25.12.x

Copy this project to the router, then:

```sh
cd BlazePwifi
sh installer/install.sh
```

The installer creates random admin and vendo keys and prints them once. Save them securely.

Portal: `http://10.0.0.1:8080/`

Admin: `http://10.0.0.1:8080/admin.html`

ESP API: `http://10.0.0.1:4455/cgi-bin/vendo`

The actual gateway address follows your OpenWrt LAN configuration.

## Repository map

- `openwrt/rootfs/` — files installed onto OpenWrt
- `installer/` — installer and uninstaller
- `esp8266/` — external coin/vendo firmware
- `docs/ARCHITECTURE.md` — server design and traffic flow
- `docs/PROTOCOL.md` — ESP/server protocol
- `docs/SECURITY.md` — threat model and deployment guidance
- `tests/` — static tests

## Clean-room notice

BlazePwifi was designed from observed behavior and public OpenWrt interfaces. It intentionally does not include or redistribute the analyzed commercial firmware's application binaries, private keys, artwork, databases, or source code.
