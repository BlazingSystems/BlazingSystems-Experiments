# Standalone Rental Releases

## Current provisioning/security candidate

### v0.5.3-rental-rc.1

Reconciles the hardened provisioning architecture with BlazePwifi `0.5.3-dev.1`.

Key properties:

- Standard Enrollment and Device Owner Provisioning are independent QR contracts.
- Device Owner APK metadata is isolated in `rental-provisioning.tsv`.
- Provisioning requires HTTPS and a pinned local BlazePwifi certificate.
- Android 12+ provisioning-mode/compliance activities are present.
- In-app scanner rejects Device Provisioning payloads.
- One-time enrollment is retry-safe and response-authenticated.
- R281 BusyBox/OneClick fixes remain included.
- TEST signing only; `production_ready=false`.
- physical Setup Wizard validation remains required.

## Previous provisioning candidates

- `v0.5.2-rental.2-rc.3` — hardened 0.5.2 provisioning/security candidate.
- `v0.5.2-rental.2-rc.2`
- `v0.5.2-rental.2-rc.1`

## Latest stable

- `v0.5.2-rental.1`
