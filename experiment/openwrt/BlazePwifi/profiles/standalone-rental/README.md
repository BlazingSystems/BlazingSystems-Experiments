# BlazePwifi Standalone Rental Server

Latest stable server line: **v0.5.2-rental.1**  
Provisioning architecture candidate: **v0.5.2-rental.2-rc.1**

The provisioning candidate separates the two Android onboarding modes:

- **Standard Enrollment QR** — BlazeRental already installed; in-app scan; server binding only.
- **Device Provisioning QR** — Android Setup Wizard on a factory-reset phone; exact DPC APK/checksum; Device Owner where supported; then server binding.

See [PROVISIONING-AUDIT.md](./PROVISIONING-AUDIT.md) for the audit findings and promotion gate.

Fresh Standalone Rental console credentials remain `admin / admin`. The Windows package also includes the one-click administrator reset tool.

Standalone OpenWrt installation remains network-neutral: it does not take ownership of `network`, `wireless`, or `firewall` UCI configuration.
