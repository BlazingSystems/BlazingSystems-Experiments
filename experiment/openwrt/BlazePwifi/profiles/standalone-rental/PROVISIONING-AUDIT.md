# Provisioning audit — 0.5.3 reconciliation

This document is carried forward from the hardened 0.5.2 RC3 audit and updated for the `0.5.3-dev.1` reconciliation candidate.

# BlazeRental Provisioning / Enrollment Audit

Audit target: BlazePwifi 0.5.2 Standalone Rental and the active Launcher3-based BlazeRental DPC.

## Security boundary

Two QR formats are intentionally separate and must never be treated as interchangeable.

### Standard Enrollment QR

- Scanner: BlazeRental in-app scanner.
- Prerequisite: BlazeRental is already installed.
- Purpose: one-time server binding only.
- Schema: `blazerental.enrollment.v1`.
- Payload: Rental Server URL, one-time enrollment token, device label.
- Does not request or claim Device Owner.

### Android Device Provisioning QR

- Scanner: Android Setup Wizard enterprise QR provisioning.
- Prerequisite: new/factory-reset, unprovisioned, owned or explicitly authorized phone.
- Purpose: install and verify the DPC, provision Device Owner where Android/OEM supports it, then bind BlazeRental to the Rental Server.
- Admin-extras schema: `blazerental.provisioning.v1`.
- Includes exact DPC component, exact APK HTTPS download URL, URL-safe Base64 SHA-256 APK checksum, minimum version code, one-time Rental Server enrollment material, and optional Wi-Fi.

## Audit findings corrected

1. The server previously used one `rental_device_qr` concept for both discussions. It is now explicitly the compatibility alias for Standard Enrollment only; new actions are `rental_standard_qr`, `rental_provisioning_status`, and `rental_provisioning_qr`.
2. The current APK source is `android/BlazeRentalLauncher/`. The older `android/BlazeRental/` project is legacy/reference and is not the provisioning release source.
3. Android 12+ admin-integrated provisioning activities were missing. The Launcher3 APK now implements GET_PROVISIONING_MODE and ADMIN_POLICY_COMPLIANCE, while preserving legacy provisioning completion support.
4. Managed provisioning no longer opens the normal/manual initial administrator wizard. A Device Owner-provisioned phone waits for server enrollment/operator admin policy instead of allowing a local user to claim setup.
5. The in-app Standard Enrollment scanner explicitly rejects Android Device Provisioning payloads.
6. Device Provisioning tokens use a longer one-hour one-time window; Standard Enrollment remains ten minutes.
7. Provisioning metadata fails closed unless an exact APK URL/checksum/version/channel is installed on the server.
8. The previous Rental release workflow reused a v0.5.1 TEST APK. The provisioning RC builds, test-signs, verifies, and publishes its exact Launcher3 APK in the same pipeline and injects the exact checksum metadata into OpenWrt bundles/images.
9. The generic 0.5.2 compatibility test had a stale version whitelist; this was corrected so CI failures are meaningful.

## Release gate

The provisioning implementation is intentionally released first as a release candidate.

The current CI provisioning APK uses a test signing identity. It is valid for exact-byte provisioning validation because the QR carries that exact APK checksum, but it is not a substitute for production signing continuity.

Do not promote Device Owner provisioning to stable production status until:

- the APK is signed by the locked production BlazeRental identity;
- a factory-reset physical Android device successfully completes Setup Wizard QR provisioning;
- Device Owner is confirmed on-device;
- the one-time token is consumed and the phone appears on the intended Rental Server;
- a second sync obtains and verifies server policy;
- the manual in-app scanner rejects the provisioning QR;
- the same release is exercised on representative older and Android 12+ provisioning paths.

## Non-goals

The product does not claim resistance to bootloader unlock, recovery flashing, OEM service tooling, or privileged platform exploits.


## RC3 security findings

RC3 extends the provisioning audit beyond QR shape:

- enrollment redemption is retry-bound and crash-recoverable;
- the server signs the enrollment identity response before BlazeRental commits device credentials;
- the client persists and reuses the enrollment request nonce until identity commit;
- Rental auth v2 binds mutations to action-specific canonical payloads and rejects replayed nonces;
- legacy signatures remain compatibility-only and parameters they did not cover are ignored rather than trusted;
- Rental TSV state writes and policy revision compare-and-swap are serialized;
- Device Owner provisioning requires HTTPS plus the local BlazePwifi certificate SHA-256 pin;
- exact Device Owner APK metadata is isolated in `/etc/blazepwifi/state/rental-provisioning.tsv`;
- the checked-in source tree contains no ready-to-use provisioning APK metadata, so source installs fail closed until a release bundle injects an exact APK URL/hash/signer tuple.

RC3 remains a prerelease until the exact hardened APK is production-signed and a factory-reset physical Android device completes Setup Wizard provisioning end-to-end.
