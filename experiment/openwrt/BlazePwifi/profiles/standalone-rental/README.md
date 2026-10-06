# BlazePwifi Standalone Rental Server

Release line: **v0.5.0-rental-rc.1**

This edition installs the **full BlazePwifi v0.5 software payload** on OpenWrt, but activates and exposes only the parts required for managed Android rentals. Hotspot/captive-portal features are not deleted; they remain dormant so the device can later be converted to the full BlazePwifi server by software upgrade.

## Targets

- Notion R281 running OpenWrt/EasyMode (24.10.x baseline)
- Ruijie RG-EW1200G Pro v1.1 running OpenWrt 25.12.x
- other OpenWrt 24.10/25.12 devices with usable LAN/Wi-Fi and sufficient writable storage
- ESP8266 and ESP32 as true standalone rental servers, with a convertible multi-coinslot-controller role

## OpenWrt standalone edition

The OpenWrt edition keeps the full v0.5 runtime, libraries, admin APIs and web assets installed. Only these listeners are activated initially:

- Rental/Android API: `http://LAN_IP:8090/cgi-bin/rental`
- Rental management: `https://LAN_IP:8444/`
- Controller API: `http://LAN_IP:4455/cgi-bin/vendo`

The hotspot nftables gate, captive portal, voucher sales and full general-purpose admin navigation are **not activated** in Rental Standalone mode.

The rental management console exposes only rental-related pages: dashboard, enrollment, rental devices, lease controls, launcher policy, installed-app inventory, allowed/hidden apps, device admin settings, timer/quick-control policy, coinslot controllers, rental events, security audit, server diagnostics and the full-upgrade status.

## Upgrade to full BlazePwifi

The complete full-server files are already installed. Running:

```sh
/usr/sbin/blazepwifi-rental-upgrade --full
```

backs up configuration, enables the normal BlazePwifi portal/admin/controller listeners, enables the BlazePwifi core and activates the hotspot gate. This is an explicit conversion because it changes network/firewall behavior.

## ESP standalone edition

ESP8266/ESP32 do not pretend to run OpenWrt. Their firmware implements a protocol-compatible standalone rental server directly on the MCU:

- AP + optional STA
- local rental management page
- one-time device enrollment
- HMAC-authenticated BlazeRental status
- v3 signed rental policy
- manual lease add/set/expire/revoke
- app allow/hide policy and preferred controller
- persistent LittleFS state
- local coin inputs
- role switch to **MultiCoin Controller**, where one board exposes multiple logical coin controllers to a larger BlazePwifi server

ESP firmware is **not upgradable to full BlazePwifi**. It is convertible only between Standalone Rental Server and MultiCoin Controller roles.

## Safety

OpenWrt standalone installation does not modify `network`, `wireless` or `firewall` UCI packages. It only creates BlazePwifi's own configuration and additive uHTTPd listeners. Full conversion is the point where firewall/hotspot behavior is deliberately activated.

This RC is CI/build validated. Physical boot, flash-space, Wi-Fi, GPIO, coinslot voltage isolation and sustained-load testing are still required on the exact hardware revision.
