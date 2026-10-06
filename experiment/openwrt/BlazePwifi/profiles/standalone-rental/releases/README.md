# Standalone Rental Releases

## Provisioning candidate

### v0.5.2-rental.2-rc.3

RC3 supersedes RC2 without modifying older tags/assets.

Key hardening:
- canonical padded Base64URL APK checksum for Android Setup Wizard;
- exact APK SHA-256 + signer-certificate SHA-256 published in release evidence;
- OpenWrt tar/OneClick and EW1200G/x86 firmware share the same exact provisioning metadata generator;
- explicit `GMS_DPC_APPROVED` state and API/UI acknowledgement gate;
- non-approved custom DPC QR is labeled for AOSP/non-GMS or explicitly supported test targets only;
- Standard Enrollment and Device Provisioning remain separate contracts.

### v0.5.2-rental.2-rc.2

Atomic one-time enrollment claims, release-package TEST APK identity, and executable provisioning/race CI.

### v0.5.2-rental.2-rc.1

First published provisioning split candidate; preserved unchanged.

## Latest stable

### v0.5.2-rental.1

CSRF/QR mutation hotfix for the previous single-enrollment-QR flow.

## Older

- v0.5.2-rental
- v0.5.2-rental-rc.2
- v0.5.2-rental-rc.1
