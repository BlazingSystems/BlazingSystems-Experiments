# Changelog

## 0.2.0-rc.2 — 2026-10-04

- Final RC2 hardening: atomic persistent-state replacement, kernel flock serialization, durable coin-target/ESP pending-event recovery, local firewall-zone rules, repeated x3 regression/stress gates, and fail-closed clock synchronization checks.

- Reconciled public WiFi5 behavior and public KLCiS/WiFi5 integration material without redistributing closed WiFi5 binaries.
- Replaced MAC-only balances with browser device-token accounts that survive private/random MAC rotation.
- Added server-side pause/resume with optional pause lifetime limit.
- Made coin events target-bound, signed, and idempotent across lost acknowledgements.
- Separated durable voucher-use markers from bounded coin replay history.
- Kept high-frequency Vendo heartbeat state in RAM while making the short active coin-window record durable so a router brownout does not orphan an accepted coin.
- Added dynamic IPv4/IPv6 walled-garden sets for payment or login domains.
- Moved the BlazePwifi forward gate after firewall4 so OpenWrt zone policy remains authoritative.
- Added HTTPS-only admin listener on port 8443 with local self-signed certificate generation.
- Bound service listeners to the LAN address rather than WAN-facing wildcard addresses.
- Secured ESP8266 setup AP with a generated WPA2 password and automatic AP shutdown after provisioning.
- Added automatic single-Vendo selection and explicit multi-Vendo selection.
- Added v0.1 MAC-account migration, crash-safe legacy claims, kernel-backed flock serialization, same-filesystem atomic state replacement, persistence/replay/concurrency stress tests, and firmware SHA256SUMS.
- Added ESP8266 LittleFS journaling for unacknowledged coin events across ESP brownouts.
- Added LAN-zone service firewall rules and clean uninstall removal.
- Added executable-mode auditing for direct-flash runtime scripts.
- Ruijie CI now requires both the upstream-style initramfs install image and squashfs sysupgrade image; x86 requires BIOS and EFI images.
- Continued support for OpenWrt 25.12.5 Ruijie RG-EW1200G Pro v1.1 and x86_64 ImageBuilder outputs.

## 0.1.0-alpha.1 — 2026-10-04

- Initial BlazePwifi clean-room implementation.
- OpenWrt 25.12.x installer with apk package handling.
- nftables captive portal and paid-MAC authorization set.
- Persistent credit and session accounting.
- Configurable rate table.
- Client portal and token-protected admin status page.
- ESP8266 remote-vendo firmware and authenticated API.
- Ruijie RG-EW1200G Pro v1.1 and x86_64 deployment profiles documented.
- GitHub Actions static validation and release-bundle workflow.
