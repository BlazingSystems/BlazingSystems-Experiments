# Standalone Rental Releases

## Latest prerelease

### v0.5.2-rental.2-rc.2

Provisioning architecture release candidate.

- **Standard Enrollment QR** and **Android Device Provisioning QR** are separate flows.
- Standard Enrollment is scanned inside an already-installed BlazeRental app.
- Device Provisioning is scanned from Android Setup Wizard on a new/factory-reset device.
- Device Provisioning is bound to the exact TEST APK asset and checksum from the same immutable RC.
- Android 12+ provisioning-mode and policy-compliance activities are implemented.
- One-time enrollment claims are concurrency-safe.
- R281 BusyBox, CSRF, Windows OneClick, admin reset, network-preservation, ESP, and full-conversion safeguards remain included.
- RC2 passed the dedicated Rental release pipeline and the repository-wide BlazePwifi validation/simulation pipeline.
- **Physical Setup Wizard provisioning remains pending.**
- **TEST signing only; not production-ready.**

## Latest stable

### v0.5.2-rental.1

Stable CSRF / Standard Enrollment hotfix.

This remains the stable release while Device Owner provisioning is physically validated and rebuilt with the locked production BlazeRental signing identity.

## Previous

- v0.5.2-rental — initial stable release.
- v0.5.2-rental-rc.2 — R281 auth/login/BusyBox fixes.
- v0.5.2-rental-rc.1 — R281 BusyBox installer fix.
