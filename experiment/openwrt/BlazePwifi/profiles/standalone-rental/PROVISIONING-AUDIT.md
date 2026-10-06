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

## Google-certified Android / custom DPC compatibility

Current Android Enterprise policy can block custom DPC installation during enterprise enrollment when the DPC is not verified/approved by Android Enterprise. BlazeRental must therefore not advertise custom Device Owner QR provisioning as universally production-compatible on GMS/Play-Protect devices.

The server metadata carries `GMS_DPC_APPROVED`. When it is `0`, both the API and UI require an explicit custom-DPC acknowledgement and label the QR for AOSP/non-GMS or explicitly supported test targets only.

Android Enterprise also states that device-financing / hardware-lease control solutions are not permitted scenarios for DPC approval. Production planning must account for that policy constraint rather than assuming an approval path exists.

Official reference: https://support.google.com/work/android/answer/16694822

## Checksum canonicalization

Android documents `PROVISIONING_DEVICE_ADMIN_PACKAGE_CHECKSUM` as URL-safe Base64 SHA-256. RC3 emits canonical padded Base64URL for the 32-byte SHA-256 digest (44 characters ending in `=`) and publishes the exact raw APK SHA-256 separately.

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
