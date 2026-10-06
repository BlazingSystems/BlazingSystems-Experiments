# BlazePwifi Standalone Rental Server

## Release status

**Latest stable:** `v0.5.2-rental.1`

**Latest provisioning candidate:** `v0.5.2-rental.2-rc.2`

The provisioning candidate intentionally remains a prerelease because its Device Owner APK is TEST-signed and real factory-reset Android Setup Wizard validation is still required.

## Two different QR systems

### Standard Enrollment QR

For phones where BlazeRental is already installed.

- scanned inside BlazeRental;
- schema `blazerental.enrollment.v1`;
- binds the app to the Rental Server;
- does **not** provision Android or grant Device Owner.

### Device Provisioning QR

For a new or factory-reset, owned/authorized Android phone.

- scanned by Android Setup Wizard;
- schema `blazerental.provisioning.v1`;
- contains the exact DPC component, HTTPS APK URL, APK checksum, minimum version code, one-time server enrollment data, and optional Wi-Fi configuration;
- Android installs/verifies BlazeRental and provisions Device Owner where supported;
- BlazeRental must then successfully bind to the Rental Server before managed provisioning is considered complete.

These QR formats are deliberately incompatible. BlazeRental's in-app scanner rejects Device Provisioning payloads.

## RC2 audit status

`v0.5.2-rental.2-rc.2` passed:

- Standalone Rental validation and release pipeline;
- exact TEST APK build/signature/package/version verification;
- OpenWrt bundle and Windows OneClick packaging;
- R281/BusyBox compatibility gates;
- ESP8266 and ESP32 builds;
- EW1200G Pro and x86 images;
- repository-wide BlazePwifi validation;
- persistence/replay stress tests;
- browser, x86, Ruijie, Orange Pi, ESP, and Android emulator simulations.

The Android emulator audit is useful compatibility coverage, but it is **not** represented as proof of factory-reset Setup Wizard QR provisioning.

## Credentials

Fresh Standalone Rental installation:

```text
Username: admin
Password: admin
```

The Windows package also includes the one-click administrator reset tool for Standalone Rental and full BlazePwifi.

## Standalone boundary

Standalone installation preserves the router's existing network, wireless, and firewall configuration. Full-network behavior remains gated behind explicit conversion to full BlazePwifi.
