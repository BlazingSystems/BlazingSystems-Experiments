# BlazePwifi Standalone Rental Server

Latest stable server line: **v0.5.2-rental.1**  
Provisioning/security candidate: **v0.5.2-rental.2-rc.3** (RC1/RC2 remain immutable history)

The provisioning candidate separates the two Android onboarding modes:

- **Standard Enrollment QR** — BlazeRental already installed; in-app scan; server binding only.
- **Device Provisioning QR** — Android Setup Wizard on a factory-reset phone; exact DPC APK/checksum; Device Owner where supported; then server binding.

See [PROVISIONING-AUDIT.md](./PROVISIONING-AUDIT.md) for the audit findings and promotion gate.

Fresh Standalone Rental console credentials remain `admin / admin`. The Windows package also includes the one-click administrator reset tool.

Standalone OpenWrt installation remains network-neutral: it does not take ownership of `network`, `wireless`, or `firewall` UCI configuration.


## RC3 security reconciliation

RC3 carries the split-QR architecture forward with the post-v0.5.2 hardening line:

- retry-safe and crash-recoverable one-time enrollment redemption;
- authenticated enrollment-response handoff before device identity commit;
- Rental `auth_v=2` HMAC canonicalization with replay rejection;
- serialized Rental state and policy revision compare-and-swap;
- signed/idempotent coin-window state and live coin progress;
- HTTPS-only provisioning with pinned BlazePwifi certificate metadata;
- isolated `rental-provisioning.tsv` metadata for the exact Device Owner APK;
- Device Provisioning remains TEST-channel / prerelease until physical Setup Wizard validation and production signing of the exact hardened APK.
