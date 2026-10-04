# BlazePwifi v0.4.0 — Launcher Edition

BlazePwifi v0.4.0 is the major Launcher Edition update. The Android rental client is rebuilt as a Launcher3 derivative rather than a dedicated intent-launcher activity.

## Required production outputs

- `BlazeRental.apk` — signed Android Launcher Edition package.
- ESP8266 and ESP32 controller firmware (`.bin` plus source `.ino`).
- Ruijie RG-EW1200G Pro v1.1 OpenWrt firmware/sysupgrade artifact.
- x86_64 OpenWrt disk images suitable for BIOS and UEFI deployment.
- Orange Pi Zero 3 image.
- Orange Pi One image.
- Orange Pi PC image.
- SHA256 manifests and simulation/audit evidence.

Optional Orange Pi family targets are published only after their own build/validation succeeds.

## Android behavior

Rental Mode provides three fixed Launcher3 workspace pages: rental/timer, safe quick controls, and mirrored notifications. The app drawer is lease-gated and package-policy filtered. Device Owner provisioning is the strongest deployment mode; manual APK installation remains supported with lower security and optional legacy Device Admin defence.

Launcher3 upstream provenance is pinned in `android/BlazeRentalLauncher/BLAZE_UPSTREAM.md` and an unmodified preservation copy is retained in `BlazingSystems/Forked-Projects`.

## Release rule

A build is not production-ready merely because it compiles. Required v0.4 validation, board identity checks, Android signing checks, and environment simulation must pass before final publication.
