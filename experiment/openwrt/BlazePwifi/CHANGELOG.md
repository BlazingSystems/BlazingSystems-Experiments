# Changelog

## 0.5.3-dev.1 — development

- Full BlazePwifi admin mutations now send CSRF through both the custom header and form body, use same-origin/no-store requests, refresh stale sessions and retry a CSRF mismatch once.
- Rental setup is split into two explicit QR modes: low-security binding for an already-installed BlazeRental APK, and Android Device Owner provisioning for factory-reset Setup Wizard.
- Device Owner provisioning binds to the published signed BlazeRental APK checksum and pins the local BlazePwifi self-signed TLS certificate for secure post-provision enrollment.
- Enrollment is retry-safe across dropped responses: the same persisted request nonce returns the same issued identity, a different nonce is rejected, and the response is authenticated before BlazeRental commits the permanent identity.
- BlazeRental and the PisoWiFi captive portal now expose separate server-authoritative purchased-time and insert-coin countdowns.
- Rental coin windows track signed pulse count and centavo value, suppress replayed Vendo events, preserve the active target across repeated open requests, and remove expired/closed progress atomically.
- BlazeRental displays received pulse/value progress and a real Done Inserting action while preventing overlapping coin-window opens.
- Runtime validation now asserts the visible unpaid 00:00:00 / INSERT COIN gate, live portal timer ticks, both QR modes, dual CSRF transport, Device Owner behavior and exact installed development version.
- Current CI artifacts use neutral development channels so post-v0.5.2 builds cannot be mistaken for the frozen v0.5.2 production release.
- Rollback rescue for this development line is built from the exact frozen v0.5.2 production application candidate with a forward-only rescue versionCode.

## 0.3.0 — production

- Production phone-rental enforcement: Device Owner lock-task allowlist, server-authoritative lease, coin targeting, app policy, phone-admin password verifier and PC QR provisioning.
- Managed ESP8266/ESP32 controller policy with verified first-boot Wi-Fi setup and reconnect fallback.
- Permanent production GitHub Release assets for supported router/SBC/x86/Android/controller targets.

- Added capability-tier architecture: Lite for constrained routers, Standard for Orange Pi/SBC deployments and Full for x86 systems.
- Began public-tree cleanup and neutral reference documentation.
- v0.3 implementation plan adds hardened admin sessions/lockouts, configurable portal builder/templates, ESP32, Linux GPIO/Orange Pi support, BlazeRental Android management and GitHub Release asset packaging.
- Successful targets remain publication-gated: no placeholder firmware or installer files are released.

## 0.2.0-rc.2 — 2026-10-04

- Final RC2 hardening: atomic persistent-state replacement, kernel flock serialization, durable coin-target/ESP pending-event recovery, local firewall-zone rules, repeated regression/stress gates and fail-closed clock synchronization checks.
- Reconciled publicly observable prepaid-hotspot behavior and open integration examples without redistributing closed commercial binaries.
- Replaced MAC-only balances with browser device-token accounts that survive private/random MAC rotation.
- Added server-side pause/resume with optional pause lifetime limit.
- Made coin events target-bound, signed and idempotent across lost acknowledgements.
- Separated durable voucher-use markers from bounded coin replay history.
- Kept high-frequency Vendo heartbeat state in RAM while making short active coin-window records durable.
- Added dynamic IPv4/IPv6 walled-garden sets for provider hosts.
- Kept BlazePwifi forwarding subordinate to firewall4 policy.
- Added HTTPS-only local administration with local certificate generation.
- Bound local service listeners to the configured LAN address rather than WAN-facing wildcard addresses.
- Secured ESP8266 setup AP with generated WPA2 credentials and automatic shutdown after provisioning.
- Added automatic single-Vendo selection and explicit multi-Vendo selection.
- Added v0.1 state migration, crash-safe legacy claims, kernel-backed flock serialization, same-filesystem atomic replacement and concurrency/replay stress tests.
- Added ESP8266 LittleFS journaling for unacknowledged coin events.
- Added local firewall-zone service rules and clean uninstall removal.
- Added executable-mode auditing.
- Added verified Ruijie bootstrap/custom sysupgrade packaging and x86 BIOS/UEFI ImageBuilder outputs.

## 0.1.0-alpha.1 — 2026-10-04

- Initial BlazePwifi implementation.
- OpenWrt 25.12.x installer with apk package handling.
- nftables captive portal and paid-MAC authorization set.
- Persistent credit and session accounting.
- Configurable rate table.
- Client portal and token-protected admin status page.
- ESP8266 remote-Vendo firmware and authenticated API.
- Ruijie RG-EW1200G Pro v1.1 and x86_64 deployment profiles.
- GitHub Actions static validation and release-bundle workflow.
