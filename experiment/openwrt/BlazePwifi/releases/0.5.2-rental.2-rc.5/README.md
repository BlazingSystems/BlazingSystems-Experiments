# BlazePwifi Standalone Rental Server v0.5.2-rental.2-rc.5

RC5 is the next audited Device Provisioning candidate. RC4 remains immutable.

## Security changes

- Standard Enrollment and Android Device Provisioning remain separate, non-interchangeable QR contracts.
- OpenWrt-generated QR payloads use the Rental Server HTTPS origin and include the SHA-256 fingerprint of the local uHTTPd certificate.
- Device Provisioning rejects HTTP and rejects missing/invalid server certificate pins.
- BlazeRental uses pinned HTTPS for the local self-signed Rental Server certificate.
- One-time server enrollment is retry-safe: the same persisted request nonce recovers the same device identity after a lost response.
- The server authenticates the enrollment identity response before BlazeRental stores the permanent device secret.
- Android sync is serialized and identity/enrollment state uses durable SharedPreferences commits.
- Enrollment-file creation and redemption use a single lock domain, avoiding append-vs-rewrite races.

## Android artifact identity

- versionName: `0.5.2-rental.2-rc.5`
- versionCode: `50206`
- package: `com.blazesystems.blazerental`
- candidate APK remains TEST-signed.
- release metadata remains `production_ready:false`.
- `GMS_DPC_APPROVED=0` remains explicit.

## Promotion boundary

Do **not** call Device Owner provisioning stable/production-ready yet.

Stable promotion still requires:

1. restoration of the locked production signing identity/lineage for the exact APK;
2. physical factory-reset Setup Wizard validation on intended hardware;
3. separate validation/positioning for Google-certified devices because non-approved custom DPCs may be rejected.

The existing stable Standalone Rental server line remains `v0.5.2-rental.1`.
