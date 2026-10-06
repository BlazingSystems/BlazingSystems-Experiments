# BlazePwifi Standalone Rental Server

Latest stable server line: **v0.5.2-rental.1**  
Provisioning architecture candidate: **v0.5.2-rental.2-rc.5**

The provisioning candidate keeps two independent Android onboarding modes:

- **Standard Enrollment QR** — BlazeRental already installed; scanned inside BlazeRental; server binding only; no Device Owner claim.
- **Device Provisioning QR** — Android Setup Wizard on a factory-reset phone; exact APK/checksum; Device Owner only where the platform permits that DPC; then server binding.

RC5 adds:

- canonical padded Base64URL SHA-256 provisioning checksum;
- exact signer-certificate and APK digests in release evidence;
- one metadata builder shared by OpenWrt tar/OneClick and prebuilt firmware images;
- explicit custom-DPC/GMS compatibility gating;
- GMS approval state in provisioning metadata and API responses;
- AOSP/non-GMS / explicit-test warning when the custom DPC is not approved.

Google-certified Android devices can block non-approved DPCs during enterprise Setup Wizard provisioning. The project does not describe this custom-DPC path as universally production-compatible. See [PROVISIONING-AUDIT.md](./PROVISIONING-AUDIT.md).

Fresh Standalone Rental console credentials remain `admin / admin`. The Windows package includes the one-click administrator reset tool.

Standalone OpenWrt installation remains network-neutral: it does not take ownership of `network`, `wireless`, or `firewall`.


## RC5 target scope

Android Device Provisioning QR is implemented on the **OpenWrt Rental Server** path in RC5.

ESP8266/ESP32 Rental Server mode continues to support manual one-time server/token enrollment, but does not yet render Standard Enrollment QR or Android Device Provisioning QR. The release manifest declares this explicitly rather than implying OpenWrt/ESP feature parity.


## RC5 security hardening

RC5 ports the validated post-v0.5.2 enrollment hardening into the separated provisioning architecture:

- pinned HTTPS for OpenWrt-generated Standard Enrollment and Device Provisioning;
- retry-safe one-time enrollment with a stable request nonce;
- authenticated enrollment response before permanent identity storage;
- serialized Android sync and durable identity persistence;
- one global lock domain for enrollment TSV creation/redemption.

RC5 remains TEST-signed and a prerelease. Production signing continuity and physical factory-reset Setup Wizard validation remain mandatory before stable promotion.
