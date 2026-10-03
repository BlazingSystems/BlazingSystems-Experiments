# ESPHole

Experimental ESP8266 DNS sinkhole, captive setup portal, and Wi-Fi NAPT repeater.

> **Release policy:** every release is kept as its own numbered source file. A new release must be added as a new file such as `ESPHole_v1.2.0.ino`; older numbered releases must never be deleted, renamed, or overwritten.

## Current status

**Latest experimental release:** v1.1.0  
**Target board:** NodeMCU 1.0 / ESP-12E-class ESP8266  
**Reference build environment:** ESP8266 Arduino Core 3.1.2, GCC 10.3, 160 MHz CPU build  
**Promotion rule:** ESPHole stays in `BlazingSystems-Experiments` until the user confirms successful real-board testing. A validated version may then be copied to `BlazingSystems-Projects`.

## Release files

| Version | File | Status |
| --- | --- | --- |
| v1.1.0 | `ESPHole_v1.1.0.ino` | Experimental / hardware validation pending |
| v1.0.0 | `ESPHole_v1.0.0.ino` | Experimental stabilization baseline |
| Rolling copy | `ESPHole.ino` | Legacy convenience copy; not the permanent release record |

### Versioning rules

- Never overwrite a numbered release.
- Never delete an older numbered release just because a newer one exists.
- Every future version gets a new file: `ESPHole_vX.Y.Z.ino`.
- The README must be updated for each release.
- Each release note must state:
  - features added
  - bugs fixed
  - known bugs / limitations
  - dependency or library changes
  - compile/test status
  - real-hardware validation status
- If a future release adds a third-party library, its exact library name, source, version if pinned, and installation steps must be documented under **Libraries and installation** before that release is considered complete.
- `ESPHole.ino` must not replace the historical numbered files. Numbered files are the authoritative snapshots.

## Libraries and installation

### External libraries

**ESPHole v1.1.0 requires no third-party/external Arduino libraries.**

Everything currently included by the sketch comes with the ESP8266 Arduino core:

| Include | Source | Separate install? | Purpose |
| --- | --- | --- | --- |
| `Arduino.h` | ESP8266 Arduino core | No | Arduino runtime |
| `ESP8266WiFi.h` | ESP8266 Arduino core | No | STA/AP Wi-Fi, scanning, RSSI and connection state |
| `ESP8266WebServer.h` | ESP8266 Arduino core | No | Local EasyMode-style web interface |
| `WiFiUdp.h` | ESP8266 Arduino core | No | DNS UDP listener and upstream forwarding |
| `LittleFS.h` | ESP8266 Arduino core | No | Persistent settings and blocklist |
| `NetDump.h` | ESP8266 Arduino core | No | Lightweight PHY/network activity observation |
| `lwip/napt.h` | ESP8266 Arduino core / lwIP2 | No separate library | IPv4 NAPT repeater support |

Do **not** install random Library Manager packages with similar names. ESPHole is written against the versions bundled with the selected ESP8266 core.

### Install the ESP8266 Arduino platform

In Arduino IDE:

1. Open **File > Preferences**.
2. Add this URL under **Additional Boards Manager URLs**:

   `https://arduino.esp8266.com/stable/package_esp8266com_index.json`

3. Open **Tools > Board > Boards Manager**.
4. Search for **esp8266** and install the ESP8266 platform.
5. ESPHole development currently targets **ESP8266 Arduino Core 3.1.2**.
6. Select **NodeMCU 1.0 (ESP-12E Module)** or the matching ESP8266 board.
7. Use a 4 MB flash configuration where available.
8. Use an IPv4 lwIP2 configuration with features/NAPT enabled.

If a later release requires an external library, installation instructions will be added here, including the exact version if compatibility requires pinning.

## v1.1.0 — Experimental

File: `ESPHole_v1.1.0.ino`

### Added

- Nearby Wi-Fi scanning.
- First-boot Wi-Fi setup with selectable scan results rather than requiring every field to be typed manually.
- Strongest-first Wi-Fi results with:
  - SSID
  - RSSI
  - estimated signal quality
  - channel
  - security status
- Default ESPHole LAN changed to `10.6.20.1/24`.
- Friendly local hostname: `blaze.iot`.
- Default web credentials:
  - Username: `root`
  - Password: `mnbvcxZ123`
- Configurable admin username and password.
- EasyMode-style at-a-glance dashboard.
- Live metrics for:
  - free heap
  - heap fragmentation
  - maximum free heap block
  - uptime
  - STA connection state
  - upstream SSID
  - STA IP
  - gateway
  - upstream DNS
  - Wi-Fi channel
  - RSSI
  - estimated Wi-Fi signal quality
  - AP client count
  - AP address / SSID
  - NAPT state
  - RX packets and bytes
  - TX packets and bytes
  - DNS queries
  - blocked queries
  - forwarded queries
  - DNS replies
  - errors / timeouts
  - last blocked domain
  - LED activity count
  - buzzer activity count
- Built-in ESP8266 LED activity blinking.
- D5 / GPIO14 activity buzzer.
- Short first-boot/startup chime.
- Independent LED and buzzer activity settings.
- PHY-level RX/TX activity counters for more realistic network-activity indication.

### Fixed / improved

- Reduced the number of fields presented during normal first-time setup.
- Moved less frequently used settings into an advanced section.
- Wi-Fi switching logic no longer silently carries the old Wi-Fi password into a newly selected SSID when the password field is intentionally blank.
- Activity indicators use non-blocking state/timing instead of long delays in normal packet handling.
- Packet activity monitoring records counters/direction only; packet payload contents are not stored.

### Known bugs / limitations

- **Hardware validation still pending.** Compile, flash, boot, NAPT throughput, captive setup, DNS blocking, `blaze.iot`, LED behavior and buzzer behavior must still be confirmed on the physical board.
- DNS-over-HTTPS, Android Private DNS, and applications with built-in encrypted DNS can bypass a DNS sinkhole.
- NAPT is IPv4-only.
- ESP8266 can measure the upstream STA RSSI, but cannot directly know the signal level experienced by each client connected to ESPHole's AP.
- The in-memory blocklist is deliberately limited to conserve ESP8266 RAM.
- `blaze.iot` is a local DNS alias provided by ESPHole, not a public Internet domain.
- Real packet counters depend on the ESP8266 core's PHY capture support.
- A very busy network can generate more traffic events than it is practical to represent as individual buzzer chirps; activity indication is rate-limited deliberately.

### Validation performed before upload

- Feature regression/static checks.
- Embedded dashboard/setup JavaScript syntax check.
- Host GCC C++17 syntax pass with ESP8266/Arduino compatibility stubs.
- Host Clang C++17 syntax pass with ESP8266/Arduino compatibility stubs.
- The user's exact ESP8266 `xtensa-lx106-elf-g++` environment remains the authoritative compile test.

## v1.0.0 — Experimental stabilization baseline

File: `ESPHole_v1.0.0.ino`

### Fixed

- Fixed Arduino auto-prototype problems around the custom `DnsQuestion` type.
- Fixed duplicate default-argument generation for `activityBeep(bool)`.
- Fixed malformed EasyMode HTML/C++ quoting that caused compile failures around the ONLINE/OFFLINE status pill.
- Standardized the buzzer pin internally to GPIO14 / NodeMCU D5.
- Added an ESP8266 target guard.
- Reconciled DNS, LittleFS, ESP8266WebServer, DHCP DNS, `tone()`, and lwIP NAPT structure against ESP8266 Arduino Core 3.1.2.

### Retained

- EasyMode-inspired interface.
- Local DNS filtering.
- Captive setup portal.
- AP+STA operation.
- IPv4 NAPT.
- Persistent configuration.
- Blocklist editor.
- Status API.

### Known bugs / limitations

- Not a full Linux Pi-hole replacement.
- IPv4 DNS/NAPT only.
- Encrypted/private DNS can bypass filtering.
- Real-board validation was still pending.

## Historical compiler bug notes

### Arduino prototype generator

Earlier builds failed because Arduino generated prototypes before it knew about `DnsQuestion`, and because a default argument on `activityBeep(bool force = false)` was repeated in an auto-generated prototype.

Errors included:

- `'DnsQuestion' has not been declared`
- `default argument given for parameter 1 of 'void activityBeep(bool)'`

Resolution:

- Forward-declare / define custom types before generated prototypes can reference them.
- Avoid default arguments on sketch-defined functions that Arduino preprocessing may auto-prototype.

### Dashboard HTML quoting

An early EasyMode status string embedded HTML quotes incorrectly inside an `F("...")` literal.

Errors included:

- `expected primary-expression before '<' token`
- `'span' was not declared in this scope`
- `'ONLINE' was not declared in this scope`

Resolution:

- Correct the embedded HTML quoting.
- Keep ONLINE/OFFLINE output branches separate instead of building the broken ternary flash-string expression.

## Hardware defaults — v1.1.0

- ESPHole AP IP: `10.6.20.1`
- Local hostname: `blaze.iot`
- Admin user: `root`
- Admin password: `mnbvcxZ123`
- Activity buzzer: NodeMCU **D5 / GPIO14**
- Built-in activity LED: `LED_BUILTIN`

Change the default admin password after initial setup on any installation that other people can reach.

## Project scope

ESPHole is intentionally a small ESP8266 network utility. It does not attempt to reproduce Linux Pi-hole feature-for-feature and does not store captured user payloads. Network hooks used for the dashboard and activity indications are intended for counters and activity signaling only.
