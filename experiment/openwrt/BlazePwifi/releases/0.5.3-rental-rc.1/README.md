# BlazePwifi Standalone Rental Server v0.5.3-rental-rc.1

This prerelease reconciles the hardened Rental provisioning work with the current BlazePwifi `0.5.3-dev.1` runtime.

## QR architecture

Two QR systems are intentionally separate.

**Standard Enrollment / binding QR**

- scanned inside an already-installed BlazeRental app;
- schema `blazerental.enrollment.v1`;
- server binding only;
- never claims Device Owner.

**Device Owner Provisioning QR**

- scanned from Android Setup Wizard on a new/factory-reset owned or authorized phone;
- schema `blazerental.provisioning.v1`;
- exact DPC APK URL/checksum and minimum version code;
- pinned BlazePwifi TLS certificate metadata;
- independent one-time Rental enrollment token;
- optional Wi-Fi parameters;
- managed provisioning does not complete until BlazeRental verifies Device Owner and successfully binds to the Rental Server.

BlazeRental's in-app scanner rejects Device Owner provisioning payloads.

## Reconciled security

This RC carries forward the 0.5.2 RC3 protections while retaining newer 0.5.3 runtime work:

- isolated `rental-provisioning.tsv` metadata for the exact Device Owner APK;
- HTTPS-only Device Owner provisioning with pinned local TLS certificate fingerprint;
- retry-safe/crash-recoverable enrollment redemption;
- authenticated enrollment response before device identity commit;
- replay-safe Rental authentication;
- serialized Rental state/policy writes;
- signed/idempotent coin-window state;
- R281 BusyBox-safe extraction and locking;
- CSRF body/header transport with token refresh;
- Windows OneClick and admin reset BAT;
- network-neutral Standalone install.

## Provisioning APK

The release pipeline stamps and verifies a dedicated TEST provisioning APK:

- package: `com.blazesystems.blazerental`
- versionName: `0.5.3-rental-rc.1`
- versionCode: `50301`
- channel: `test`
- `production_ready=false`

The source tree itself remains on authoritative `0.5.3-dev.1`; only the isolated Android release workspace is stamped to the RC identity before build/sign/verification.

## Promotion gate

Do **not** promote Device Owner provisioning to stable until the exact hardened APK is signed by the locked production identity and physical factory-reset Android validation succeeds on representative older and Android 12+ devices.

This tag must remain immutable once published.
