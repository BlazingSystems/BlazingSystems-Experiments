# ESP Standalone Rental Server

The same firmware has two persistent roles:

1. **Standalone Rental Server** — the ESP owns enrollment, leases, v3 policy signing and local coin inputs.
2. **MultiCoin Controller** — the ESP stops owning rental time and exposes each configured GPIO coin input as a separate logical BlazePwifi vendo to a remote full/standalone OpenWrt BlazePwifi server.

Defaults:
- ESP8266: 2 logical coin slots, up to 6 rental devices.
- ESP32: 4 logical coin slots, up to 18 rental devices.

No external Arduino libraries are required beyond the normal ESP8266/ESP32 board core. State is stored in LittleFS.

On first boot the setup AP is open until a 12+ character administrator password is created. After setup, configure an AP password from the configuration file or reflash/reset LittleFS as appropriate.

The firmware expects isolated/dry-contact coin signals. Do not connect a 12 V coin acceptor directly to an ESP GPIO.
