# BlazePwifi v0.3.0 verified backup images

This folder is populated from the GitHub environment-simulation lab only after the corresponding execution gate passes.

Backup classes:
- x86_64 BIOS/UEFI: full configured disk images created after real QEMU boot and runtime checks.
- Orange Pi: configured production SD-card images after partition mount plus ARM/AArch64 userspace execution checks. Exact Xunlong board peripherals/U-Boot are not claimed as emulated.
- Android: emulator userdata image after installing the signed production APK as Device Owner and reboot validation.
- ESP8266/ESP32: firmware backup binaries plus protocol/state audit; hardware-specific Wi-Fi/GPIO electrical behavior still requires a real board.
- Ruijie MT7621: production sysupgrade image plus standard OpenWrt configuration backup bundle; mutable site configuration is not injected into the sysupgrade binary.

Large files that exceed practical Git limits are kept as permanent v0.3.0 GitHub Release assets and referenced by manifest/checksum from this folder.
