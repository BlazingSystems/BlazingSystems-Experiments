# BlazePwifi Standalone Rental Server v0.5.2-rental.2-rc.6

RC6 is an immutable prerelease candidate. It supersedes RC5 for physical provisioning tests without changing older tags or assets.

## What RC6 adds

- Android provisioning callbacks are idempotent when Setup Wizard redelivers the same provisioning extras.
- A working Standard Enrollment identity can no longer be destroyed by scanning a second Standard QR.
- Rebinding now requires the explicit on-device **Transfer** action first.
- The Standard Enrollment scanner distinguishes Device Provisioning QR, already-bound state, and local storage/configuration failure.
- Android package identity is `0.5.2-rental.2-rc.6`, versionCode `50207`.

## Onboarding modes remain separate

### Standard Enrollment QR

For BlazeRental already installed. It is scanned inside BlazeRental and performs server binding only. It does not request Device Owner.

Schema: `blazerental.enrollment.v2`.

### Device Provisioning QR

For Android Setup Wizard on a new/factory-reset phone. It carries the exact DPC component, exact TEST APK URL/checksum/version, server certificate pin, and one-time server enrollment extras.

Admin-extras schema: `blazerental.provisioning.v2`.

This RC remains TEST-signed and is not production-ready. Google-certified devices may block a custom DPC that is not Android Enterprise approved; the UI/API require explicit acknowledgement and label that limitation.

## Security retained from RC5

- protocol-2 enrollment derives the permanent device secret independently on phone and server;
- no long-lived device secret is transported in the enrollment response;
- enrollment response is authenticated before identity is committed;
- retry with the same enrollment nonce reuses the same device identity;
- a different nonce after token claim is rejected;
- Device Provisioning requires HTTPS plus the pinned Rental Server certificate;
- exact APK SHA-256, Android provisioning checksum, signer evidence and version are release-bound;
- R281/BusyBox compatibility fixes remain included;
- Standalone installation does not take ownership of OpenWrt network/wireless/firewall configuration.

## Validation status

This release remains a prerelease until factory-reset physical Android Setup Wizard testing is completed on representative supported devices. CI passing is necessary but does not substitute for physical Device Owner provisioning validation.
