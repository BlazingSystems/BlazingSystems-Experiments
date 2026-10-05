# v0.4.0 asset contract

| Target | Production output |
|---|---|
| Android | BlazeRental.apk, QR setup/provisioning sample, signer certificate/fingerprint, signing manifest |
| ESP8266 | BlazePwifi-Vendo-ESP8266.bin + INO |
| ESP32 | BlazePwifi-Vendo-ESP32.bin + INO |
| Ruijie RG-EW1200G Pro v1.1 | sysupgrade, recovery initramfs when available, default-config backup |
| x86_64 | BIOS/UEFI-capable OpenWrt disk images |
| Orange Pi Zero 3 | disk images |
| Orange Pi One | disk images |
| Orange Pi PC | disk images |
| Orange Pi Zero | disk images |
| Orange Pi Zero 2 | disk images |
| Orange Pi Zero 2W | disk images |
| Orange Pi PC2 | disk images |
| Orange Pi PC Plus | disk images |
| Orange Pi One Plus | disk images |

The final release also contains `SHA256SUMS`, `RELEASE-MANIFEST.json`, `CANDIDATE-GATE.json`, compressed validation evidence, and the encrypted BlazeRental signing-key recovery payload.

Simulation evidence includes machine-readable audit output plus screenshots/logs where the environment supports them. Structural or QEMU validation is not described as physical-board boot testing.
