# BlazePwifi Standalone Rental Server v0.5.2-rental.2-rc.3

RC3 is the hardened provisioning/security candidate. RC1 and RC2 remain immutable historical releases.

## QR architecture

Two QR systems are intentionally separate:

- **Standard Enrollment / binding QR** — scanned inside an already-installed BlazeRental app. It binds the app to the Rental Server only and never claims Device Owner.
- **Device Owner Provisioning QR** — scanned from Android Setup Wizard on a new/factory-reset owned or authorized phone. It carries the exact DPC APK URL/checksum, minimum version code, pinned BlazePwifi certificate metadata, and a separate one-time Rental enrollment token.

The in-app scanner rejects Device Owner provisioning payloads.

## RC3 hardening

- HTTPS-only Device Owner provisioning with pinned local BlazePwifi TLS certificate fingerprint.
- Exact Device Owner APK metadata isolated in `rental-provisioning.tsv`; ordinary app-update metadata cannot silently become provisioning metadata.
- Retry-safe, crash-recoverable enrollment redemption bound to a persistent request nonce.
- Enrollment response is authenticated before BlazeRental commits permanent device identity.
- Rental `auth_v=2` signs mutation-specific canonical payloads and rejects replayed nonces.
- Rental state writes and policy revision compare-and-swap operations are serialized.
- Device IDs are collision-checked.
- Status synchronization is read-only apart from an atomic last-seen touch.
- Coin windows are server-authoritative, signed, idempotent, replay-safe, and expose signed live coin progress.
- Existing R281 BusyBox compatibility, CSRF transport, Windows OneClick, password reset, network-neutral Standalone install, ESP modes, EW1200G and x86 outputs remain included.

## Provisioning APK status

RC3 builds and verifies an exact **TEST-signed** Launcher3 BlazeRental APK with:

- package: `com.blazesystems.blazerental`
- versionName: `0.5.2-rental.2-rc.3`
- versionCode: `50204`

The release manifest records the exact APK SHA-256, Android Base64URL provisioning checksum, TEST signer certificate SHA-256, and the locked production signer fingerprint expected for eventual promotion.

`production_ready` remains **false**.

## Promotion gate

Do not promote Device Owner provisioning to stable until the exact hardened APK is signed by the locked production identity and a factory-reset physical Android device completes Setup Wizard provisioning, Device Owner confirmation, server enrollment, and policy sync. Representative older and Android 12+ provisioning paths must also be exercised.
