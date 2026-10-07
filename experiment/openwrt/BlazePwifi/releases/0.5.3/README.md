# BlazePwifi v0.5.3 — Remote Management, Rental Hardening & Pisonet Authority

BlazePwifi v0.5.3 is the production consolidation of the post-v0.5.2 development line.

## Release identity

- BlazePwifi: **0.5.3**
- BlazeRental versionName: **0.5.3**
- BlazeRental versionCode: **50300**
- Android package: `com.blazesystems.blazerental`
- Production certificate lineage: **BlazeRental-production-lineage2**
- Required production certificate SHA-256:
  `1A:18:D5:8E:1F:95:55:96:89:10:20:71:F5:6C:93:E9:B9:D2:EA:6B:E4:0E:6F:20:70:06:C9:89:62:A1:6A:25`

The frozen v0.5.2 production release remains the rollback baseline.

## BlazeRental and provisioning

- Separate **Binding QR** for already-installed/manual BlazeRental deployments.
- Separate Android **Device Owner Provisioning QR** for factory-reset Setup Wizard.
- Provisioning downloads and verifies the exact signed production APK and passes short-lived enrollment extras to BlazeRental.
- Self-signed BlazePwifi HTTPS enrollment supports certificate pinning.
- Enrollment is retry-safe across lost responses and authenticates the enrollment response before committing the permanent device identity.
- Rental gate visibly shows `00:00:00`, `TIME FINISHED` and `INSERT COIN` when unpaid.
- Purchased-time and Insert Coin reservation countdowns are separate and server-authoritative.
- Accepted Vendo pulse count/value is signed and displayed; replayed events cannot add time twice.
- `DONE INSERTING` closes the authoritative coin reservation.
- Existing v0.5.2 LCM branding and rental alarm behavior remain intact.

## Management Console hardening

- CSRF is carried in both form body and header for mutation compatibility.
- Same-origin/no-store requests and one stale-session refresh/retry are used.
- Advanced Terminal is disabled by default and requires:
  - Admin role;
  - current-password re-authentication;
  - CSRF;
  - admin-session/IP binding;
  - short TTL/idle expiry;
  - one active session per admin;
  - one command at a time;
  - bounded runtime/output;
  - audit logging.
- Terminal tokens remain only in browser memory.
- High-risk lifecycle/storage operations are blocked from the raw terminal path.
- Safe diagnostics include WAN/NTP, ping/jitter, traceroute, DNS, TCP port checks, routes/interfaces/neighbors, Wi-Fi, controller state, storage, services, logs, uptime and optional speed test.

## Worldwide Remote Access

### WireGuard

WireGuard live activation is transactional:

- private key is generated and retained on-device;
- only the public key is exposed;
- only Blaze-owned UCI sections are managed;
- unsafe/default/overlapping routes are rejected;
- network/firewall/runtime state is snapshotted;
- detached watchdog and boot recovery are armed before activation;
- success requires a real WireGuard handshake;
- default/current management paths must survive unchanged;
- failure restores the previous configuration, including a previously active Blaze tunnel;
- remote admin uses a restricted WireGuard-only HTTPS document root;
- captive portal, Rental and Vendo CGI surfaces are not exposed through that listener.

### ZeroTier

ZeroTier live activation is also transactional:

- stable ZeroTier identity remains on-device;
- only public node ID is exposed;
- only Blaze-owned modern UCI network section is managed;
- legacy/foreign layouts fail closed;
- `allow_managed=1`, `allow_global=0`, `allow_default=0`, `allow_dns=0`;
- success requires ONLINE/TUNNELED state, network OK, interface, IPv4 address and safe mesh routes;
- WireGuard and ZeroTier cannot be active simultaneously;
- failed/interrupted changes restore previous network/firewall/runtime/identity state.

## Pisonet member authority and migration

When BlazePwifi integration is enabled, BlazePwifi is the central authority for BlazePisonet SoftTimer members.

- Member passwords are never returned to the browser, SoftTimer, exports or logs.
- Online member balance mutations are idempotent and centrally authoritative.
- Authentication/balance mutation fails closed when central authority is unavailable.
- Metadata migration uses verifier-free `BLAZE_MEMBER_METADATA_V1`.
- Import is preview-first and requires fresh Admin re-authentication to apply.
- Collision handling is explicit: abort, skip, or metadata-only update.
- New imported members are disabled/reset-required until a normal password reset.
- Import is transactional and rolls back member/event/revision state on failure.

## No-reflash update

The transactional overlay updater remains the ordinary upgrade path for compatible installations.

Release assets include:

- `BlazePwifi-v0.5.3-update.tar.gz`
- `BlazePwifi-v0.5.3-update.tar.gz.sha256`
- `BlazePwifi-v0.5.3-update-bootstrap.sh`
- `BlazePwifi-v0.5.3-update-bootstrap.sh.sha256`

Base-system/kernel/bootloader/partition changes still require the appropriate full firmware image.

## Android rollback rescue

The production rollback APK uses the exact frozen **v0.5.2 application candidate** with only Android recovery metadata raised:

- rescue versionName: `0.5.2-rescue-for-0.5.3`
- rescue versionCode: **50301**

This makes the rescue installable over production v0.5.3 while restoring known-good v0.5.2 application behavior.

The rescue must be signed by the same permanent Lineage-2 certificate as production v0.5.3.

## Production signing

v0.5.3 must **not** generate a new signing key.

The signing workflow must recover the exact v0.5.2 Lineage-2 PKCS12 from the encrypted v0.5.2 release backup using an owner recovery private key supplied outside Git, verify the permanent certificate fingerprint, then sign both current and rescue APKs.

Production Device Owner QR/provisioning assets must be generated **after signing** from the exact retained `BlazeRental.apk`; the provisioning checksum must therefore match the signed APK bytes.

## Release validation

The exact production candidate must pass:

- static/security/config/integration/accounting/replay validation;
- CSRF/QR/enrollment/rental timer regressions;
- Advanced Terminal security;
- WireGuard network-survival;
- ZeroTier network-survival;
- centralized SoftTimer member regression;
- member metadata migration regression;
- Android current/rescue build;
- Android Device Owner emulator;
- browser runtime audit;
- ESP8266/ESP32;
- Ruijie;
- required Orange Pi targets;
- x86_64 QEMU;
- transactional update bundle;
- final candidate gate.

No production release may be published from a different SHA than the exact green candidate.
