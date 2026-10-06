# BlazeRental Android client — legacy/reference implementation

> **Not the current production APK source.**
>
> The active BlazeRental APK is built from `android/BlazeRentalLauncher/`. This older compact DPC project remains only as a historical/reference implementation and must not be used to generate current Device Owner provisioning metadata or release APKs.

Current supported concepts remain:

1. **Device Provisioning / Device Owner** — generated for the exact current Launcher3-based BlazeRental APK and scanned from Android Setup Wizard on a new/factory-reset, owned or explicitly authorized rental phone.
2. **Standard Enrollment** — scanned inside an already-installed BlazeRental app and used only to bind that app to a BlazePwifi/Rental server. It does not grant Device Owner.

Do not mix the two QR payload formats.

Rental time remains server-authoritative. The project does not claim to defeat bootloader unlock, recovery flashing, OEM service tools, or privileged exploits.
