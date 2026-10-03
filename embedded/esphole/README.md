# ESPHole

Experimental ESP8266 DNS sinkhole, captive setup portal, and Wi-Fi NAPT repeater.

> **Release policy:** numbered releases are immutable snapshots. New releases are added as new files such as `ESPHole_v1.1.0.ino`, `ESPHole_v1.2.0.ino`, and so on. Older numbered releases are not deleted or overwritten.

## Current status

**Latest experimental release:** v1.1.0  
**Target:** ESP8266 Arduino Core 3.1.2 / NodeMCU ESP-12E-class boards  
**Promotion rule:** keep releases in BlazingSystems-Experiments until hardware testing is confirmed successful. Only then move/copy a validated release to BlazingSystems-Projects.

## Releases

### v1.1.0 — Experimental

File: `ESPHole_v1.1.0.ino`

Changes from v1.0.0:

- Added nearby Wi-Fi scanning and tap/select setup flow.
- Reduced manual setup fields and moved less-used controls into advanced settings.
- Changed the default ESPHole LAN address to `10.6.20.1/24`.
- Added local hostname `blaze.iot`.
- Default admin credentials changed to:
  - User: `root`
  - Password: `mnbvcxZ123`
- Admin username/password remain configurable in Settings.
- Added live dashboard metrics including:
  - free heap
  - heap fragmentation
  - maximum free heap block
  - uptime
  - STA connectivity
  - upstream SSID
  - STA IP, gateway, DNS
  - channel
  - RSSI and estimated signal quality
  - AP client count
  - NAPT state
  - DNS query / blocked / forwarded / reply / error counters
  - RX/TX packet and byte counters
  - LED and buzzer activity counts
- Added built-in LED activity indication.
- Added RX/TX packet activity tracking using the ESP8266 PHY capture hook.
- Added D5/GPIO14 activity buzzer integration.
- Added first-boot startup chime.
- LED and buzzer activity can be configured independently.
- Improved switching between Wi-Fi networks so a new SSID does not silently reuse an old password when the password field is left blank.

Known limitations / items still requiring hardware validation:

- Still experimental until real ESP8266 compile, flash, boot, repeater, DNS filtering, captive setup, `blaze.iot`, LED, and buzzer behavior are confirmed on hardware.
- DNS-over-HTTPS, Android Private DNS, or applications using hard-coded encrypted DNS can bypass DNS blocking.
- NAPT is IPv4-only.
- ESP8266 can measure upstream STA RSSI, but cannot directly measure the signal strength seen by each AP client.
- The in-memory blocklist is intentionally limited for ESP8266 RAM usage.
- PHY capture is used only for activity counters/indication; packet contents are not stored.

### v1.0.0 — Experimental stabilization baseline

File: `ESPHole_v1.0.0.ino`

Main fixes:

- Fixed Arduino auto-prototype problems around the custom `DnsQuestion` type.
- Fixed duplicate default-argument generation for `activityBeep(bool)`.
- Fixed malformed EasyMode HTML/C++ quoting that caused compile errors around the ONLINE/OFFLINE status pill.
- Standardized the buzzer pin internally to GPIO14 / NodeMCU D5.
- Added ESP8266 target guarding.
- Reconciled the existing DNS, LittleFS, ESP8266WebServer, DHCP DNS, tone, and lwIP NAPT structure against ESP8266 Arduino Core 3.1.2.
- Retained the EasyMode-inspired interface, local DNS filtering, captive portal, AP+STA mode, NAPT, persistent settings, blocklist editor, and status API.

Known limitations:

- This is not a full Linux Pi-hole replacement.
- IPv4 DNS/NAPT only.
- Encrypted/private DNS can bypass filtering.
- Hardware validation was still pending at this release.

## Historical build issue notes

### Arduino prototype generator

Earlier builds failed because Arduino generated function prototypes before it knew about `DnsQuestion`, and because a default argument on `activityBeep(bool force = false)` was repeated in an auto-generated prototype.

Resolution:

- Define/forward-declare custom types before Arduino-generated prototypes can reference them.
- Avoid default arguments on sketch-defined functions that Arduino may auto-prototype.

### Dashboard HTML quoting

An earlier EasyMode status string embedded HTML quotes incorrectly inside an `F("...")` literal, causing errors such as:

- `expected primary-expression before '<' token`
- `'span' was not declared in this scope`
- `'ONLINE' was not declared in this scope`

Resolution:

- Correctly quote the embedded HTML and keep status branches separate.

## File policy

- `ESPHole_vX.Y.Z.ino` = permanent versioned snapshot.
- Never overwrite or delete an older numbered release when publishing a newer one.
- `ESPHole.ino` currently remains as the historical rolling copy, but future releases should be published as new numbered files first.
- README release notes should be updated for every new version with:
  - changes
  - fixes
  - known bugs/limitations
  - test status
  - hardware validation status

## Safety / scope

ESPHole is designed as a small ESP8266 network utility. It does not attempt to inspect or store user payload data. Traffic hooks used for activity indication only count packet direction/size and trigger LED/buzzer activity.
