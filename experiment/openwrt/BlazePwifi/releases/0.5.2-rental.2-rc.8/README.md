# BlazePwifi Standalone Rental Server v0.5.2-rental.2-rc.8

RC8 is an immutable prerelease candidate. It supersedes RC7 for further Device Provisioning validation without altering RC7 assets.

## RC8 security hardening

- Stable-promotion checks verify the **actual APK signer certificate** using `apksigner verify --print-certs`.
- The actual signer must match the locked BlazeRental Lineage-2 production identity.
- Release metadata signer claims must match the signer extracted from the APK.
- Provisioning metadata now carries explicit `TARGET_SCOPE`.
- `GMS_DPC_APPROVED=0` is restricted to `aosp_non_gms_or_explicit_oem_only`.
- `GMS_DPC_APPROVED=1` requires `gms_and_supported_aosp`.
- Physical Setup Wizard validation evidence must match the APK bytes, signer, GMS approval state and exact target scope.
- Non-approved custom DPC evidence must explicitly state that no universal GMS compatibility claim is being made.
- Runtime provisioning status/QR responses expose the same target scope so the UI cannot hide the release boundary.

## Retained safeguards

RC8 retains Standard Enrollment vs Device Provisioning separation, protocol-v2 secret derivation, response-loss retry safety, HTTPS certificate pinning, strict server-origin validation, idempotent provisioning callbacks, bounded enrollment state, explicit Transfer for rebinding, R281 BusyBox compatibility, and network-neutral Standalone installation.

## Release status

This remains a prerelease. Stable promotion is still blocked until the exact production-signed APK and required physical factory-reset Setup Wizard evidence satisfy the executable promotion gate.
