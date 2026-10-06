# BlazePwifi Standalone Rental Server v0.5.2-rental.2-rc.5

RC5 is an immutable provisioning/security release candidate that supersedes RC4 for new testing.

## Critical enrollment transport correction

RC4's first enrollment request was HMAC-authenticated, but its response still contained the newly issued long-lived `device_secret` while the default Rental API is reachable over local HTTP. RC5 removes that credential from the wire for all newly generated onboarding flows.

RC5 uses secure enrollment protocol 2:

- Standard Enrollment schema `blazerental.enrollment.v2`;
- Device Provisioning schema `blazerental.provisioning.v2`;
- request authentication canonical form `enroll_v2|nonce|one-time-token`;
- server and APK independently derive the long-lived device secret with HMAC-SHA256 over `device-secret-v2|nonce|device-id`;
- the server returns `enrollment_protocol=2`, the device ID, KDF identifier, timestamps, and an HMAC response signature—never the derived long-lived secret;
- the APK verifies the enrollment response before accepting the identity;
- the consumed bootstrap token is removed from device storage after successful enrollment.

The server retains protocol 1 only as a compatibility path for older clients. RC5-generated QR payloads do not advertise that legacy path.

## Provisioning architecture retained

Standard Enrollment and Android Device Provisioning remain separate contracts. Device Provisioning remains administrator-only, release-bound to the exact TEST APK/checksum, and explicitly gated when the custom DPC is not declared Android Enterprise approved.

## RC5 identity

- Android versionName: `0.5.2-rental.2-rc.5`
- Android versionCode: `50206`
- Device Provisioning scope: OpenWrt Rental Server only in this candidate
- APK signing channel: TEST
- production_ready: false
- physical Setup Wizard validation: still required

## Promotion boundary

Do not promote Device Owner provisioning to stable production until the production signing identity is used and a factory-reset physical target completes Setup Wizard provisioning, Device Owner verification, server binding, second policy sync, and post-provisioning enforcement validation.
