# BlazePwifi Standalone Rental Server

Current release line: **v0.5.2-rental-rc.1**

This edition follows the BlazePwifi **0.5.2 implementation** branch. OpenWrt installs the complete BlazePwifi software payload but activates/exposes only rental-related management until the operator explicitly converts the device to full BlazePwifi.

## Releases

### [BlazePwifi Standalone Rental Server v0.5.2-rental-rc.1 — Latest](https://github.com/BlazingSystems/BlazingSystems-Experiments/releases/tag/v0.5.2-rental-rc.1)

Primary existing-router deployment:

- **[Windows OneClick Installer](https://github.com/BlazingSystems/BlazingSystems-Experiments/releases/download/v0.5.2-rental-rc.1/BlazePwifi-Rental-Standalone-Windows-OneClick-v0.5.2-rental-rc.1.zip)**

This release fixes the R281 deployment path found during physical testing:

- detects `notion,r281` immediately after SSH;
- automatically runs the dedicated R281/EasyMode installer;
- uses only BusyBox-compatible archive extraction;
- does not use GNU `tar` strip-components;
- preserves the successful R281 assumptions: OpenWrt 24.10.x, `/www`, `/cgi-bin`, HTTPS :443, EasyMode-owned networking.

Older 0.5.0 Rental RCs remain in [the release archive](./releases/) for history only.

## OpenWrt URL model

Existing router/basic/advanced administration remains where the router already provides it. Rental Standalone adds:

- `https://LocalIP/rental/` — rental administration
- `http://LocalIP/cgi-bin/rental` — BlazeRental application API
- `http://LocalIP:4455/cgi-bin/vendo` — authenticated remote ESP coinslot API

Normal Rental Standalone installation does **not** modify OpenWrt `network`, `wireless`, or `firewall` UCI packages.

## Credit model

There is no customer network captive portal. Rental phones remain on the same reachable network as the server. Credit can be added manually, by a supported local coinslot, or by authenticated remote ESP8266/ESP32 coin interfaces.

## ESP modes

ESP8266 and ESP32 use one admin console at `http://assigned-ip/` and support:

1. Rental Server
2. Rental Server + one Local Coin Slot
3. Remote Coin Slot Interface

Rental-server modes can bind additional remote ESP coin interfaces.
