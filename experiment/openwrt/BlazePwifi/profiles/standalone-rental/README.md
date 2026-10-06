# BlazePwifi Standalone Rental Server

**Core baseline:** BlazePwifi `0.5.3-dev.1`  
**Latest stable Rental line:** `v0.5.2-rental.1`  
**Current provisioning/security candidate:** `v0.5.3-rental-rc.1`

This candidate reconciles the hardened Device Owner provisioning work from the 0.5.2 RC3 line with the newer 0.5.3 runtime.

## Two separate Android onboarding modes

### Standard Enrollment QR

For phones where BlazeRental is already installed.

- scanned inside BlazeRental;
- schema `blazerental.enrollment.v1`;
- binds the app to the Rental Server;
- does **not** provision Android;
- does **not** grant Device Owner.

### Device Owner Provisioning QR

For a new or factory-reset, owned/authorized Android phone.

- scanned by Android Setup Wizard;
- schema `blazerental.provisioning.v1`;
- exact DPC APK URL and Android provisioning checksum;
- minimum APK version code;
- pinned local BlazePwifi TLS certificate fingerprint;
- one-time server enrollment data;
- optional Wi-Fi configuration;
- modern Android provisioning mode/compliance activities;
- BlazeRental must finish server binding before provisioning is considered complete.

The in-app scanner explicitly rejects Device Provisioning payloads.

## Release candidate status

The RC builds an exact **TEST-signed** BlazeRental APK with release package ID `com.blazesystems.blazerental`.

`production_ready=false` remains mandatory. Do not promote Device Owner provisioning to stable until:

1. the exact hardened APK is signed by the locked production identity;
2. a physical factory-reset Android device completes Setup Wizard provisioning;
3. Device Owner is confirmed;
4. BlazeRental binds to the server and completes policy sync;
5. representative older Android and Android 12+ provisioning paths are tested.

## R281/OpenWrt safety

The current Windows OneClick installer:

- detects `notion,r281` and uses the dedicated R281/EasyMode path;
- uses BusyBox-compatible archive extraction;
- never uses GNU `tar --strip-components`;
- retains BusyBox-safe locking;
- keeps Standalone installation network-neutral.

Standalone installation does not intentionally modify OpenWrt `network`, `wireless`, or `firewall` UCI packages.

Fresh Rental console credentials remain `admin / admin`. The Windows package also includes the one-click admin reset BAT.
