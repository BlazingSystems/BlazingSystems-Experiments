# Changelog

## 0.5.3-dev.3 — development

- Enabled transactional **live WireGuard activation/disable** for Full BlazePwifi while keeping ZeroTier live activation staged-only.
- Added on-device WireGuard private-key generation/storage with restrictive permissions. The private key is never accepted from or returned to the browser; only the device public key is exposed after explicit admin re-authentication.
- Added Blaze-owned UCI sections for the live tunnel and firewall path so dev.3 does not replace or take ownership of existing LAN/WAN/EasyMode network sections.
- Blocked unsafe WireGuard routing before apply: no default/full-tunnel routes, no overly broad routes, no overlap with directly connected networks, and no route that would capture the current admin source path.
- Added transactional network/firewall/runtime snapshots, a detached rollback watchdog, and boot-time recovery for any apply/disable interrupted by process failure or reboot.
- A candidate WireGuard apply is accepted only after the interface starts, firewall reload succeeds, a real WireGuard handshake is observed, and the default/current management route signatures remain unchanged.
- Failed apply/disable restores the previous network/firewall/runtime state, including a previously active Blaze WireGuard tunnel when updating an existing deployment.
- Added a dedicated WireGuard-only remote-admin HTTPS service with a restricted web root containing only the admin page/assets and admin CGI endpoints. The normal LAN admin uHTTPd and captive-portal/Rental/Vendo CGI surface are not rebound or exposed through this listener.
- Enforced Remote Terminal permission server-side for requests arriving through the WireGuard management listener; local/LAN admin behavior remains unchanged.
- Added explicit Management Console controls for local WireGuard public-key generation, staged profile save, **Test & Apply WireGuard**, live activation/handshake status, and safe disable from a local/non-WireGuard path.
- Added WireGuard runtime dependency to Full BlazePwifi image/install paths.
- Added regression coverage for route helper isolation, IPv4 admin-source recognition, private-key config permissions, exact restricted-admin CGI allowlist, watchdog ownership, transaction-engine EOF integrity, rollback behavior and browser management flow.
- Development identity advanced to `0.5.3-dev.3` / Android versionCode `50292`.
- Exact green branch candidate: `c60645729e6fbd9b9af6db8b11af13c3b58b7ae3`, workflow `37516557416` — PASS.
- Frozen v0.5.2 production/tag/signing/recovery workflows remain untouched.

## 0.5.3-dev.2 — development

- Added a hardened Advanced Terminal to the Full BlazePwifi Management Console. It is disabled by default and requires admin role, fresh password re-authentication, CSRF, current admin-session/IP binding, short TTL/idle expiry, one active session per admin, one command at a time, bounded runtime/output and audit logging.
- Advanced Terminal session tokens remain only in browser memory and are discarded on close/disable/error/reload; they are never written to localStorage/sessionStorage or shown in the DOM.
- Background/detached commands and high-risk appliance lifecycle/storage commands such as reboot, sysupgrade, firstboot/jffs2reset, mtd and fw_setenv are blocked from Advanced Terminal so those operations can remain behind dedicated guarded controls.
- Terminal command audit records executable name plus command SHA-256 instead of full command text to reduce accidental secret persistence in audit logs.
- Expanded Safe Tools with WAN status, NTP/clock status, latency/jitter sampling, TCP port checks, local neighbors, controller status, services and recent system logs while preserving the allowlisted diagnostic model.
- Added a validated Worldwide Remote Access profile for Disabled, WireGuard and ZeroTier modes with separate Monitoring, Management and Remote Terminal permissions, node/site identity, source CIDR allowlist, heartbeat/offline thresholds and transport-specific public configuration.
- Remote profiles never accept or expose a WireGuard private key. Saving a profile requires admin re-authentication and is serialized/crash-safe.
- Live WireGuard/ZeroTier network/firewall activation remains intentionally safety-locked in dev.2. The profile can be validated/staged, but transport apply/rollback must pass a separate network-survival matrix before activation is enabled.
- Browser runtime audit now exercises remote-profile save, password re-authentication, terminal enable/open/execute/close, dual CSRF transport and confirms no console errors.
- Fixed a real Remote Access edit race where an unconditional delayed startup refresh could reset the selected mode while the operator was editing; remote configuration now loads only on page entry/explicit refresh/save, stale responses are suppressed, and the authoritative save response is rendered immediately.
- Added dynamic console-operations security tests for password re-authentication, session binding, close/disable behavior, blocked commands, command concurrency, remote-profile validation and absence of private-key storage.
- Development identity advanced to `0.5.3-dev.2` / Android versionCode `50291`; frozen v0.5.2 production/recovery workflows remain untouched.

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
