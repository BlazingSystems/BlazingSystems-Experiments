# BlazeRental v0.4 signing lineage

BlazeRental v0.4 keeps the package ID `com.blazesystems.blazerental`. Production APKs therefore **must use the same production certificate lineage as v0.3** so an installed rental phone can upgrade in place.

Expected SHA-256 certificate fingerprint:

`F6:8F:A0:41:A8:15:2C:C6:9C:77:C9:7A:D2:95:45:E8:25:9F:D0:DD:27:41:2C:58:F9:12:21:7D:D1:C0:B2:B9`

The public reference is retained at:

`releases/0.3.0/BlazeRental-signing-fingerprint.txt`

## Required signature schemes

v0.4 has `minSdkVersion 21`. The final production APK must verify with:

- v1/JAR signing — required for Android 5.x/6.x compatibility.
- APK Signature Scheme v2.
- APK Signature Scheme v3.

The CI signing workflow refuses a different certificate fingerprint and refuses an APK missing any of those signature schemes.

## Private key handling

The production private key must not be committed to this repository. The v0.4 signing workflow expects the existing production keystore through GitHub Actions secrets:

- `BLAZERENTAL_KEYSTORE_B64`
- `BLAZERENTAL_KEYSTORE_PASSWORD`
- optionally `BLAZERENTAL_KEY_ALIAS` (defaults to `blazerental`)

If those secrets are not present, production signing intentionally fails instead of silently generating a replacement identity.
