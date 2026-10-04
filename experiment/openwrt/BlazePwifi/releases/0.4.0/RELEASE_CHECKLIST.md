# BlazePwifi v0.4.0 production checklist

The release workflow must not publish until all of these refer to the **same candidate commit**.

- [ ] Main `BlazePwifi build` run concluded successfully.
- [ ] `BlazePwifi-v0.4-candidate-gate` exists in that build run.
- [ ] Launcher3 Android emulator Device Owner audit passed.
- [ ] Browser admin simulation passed without console/page errors.
- [ ] ESP8266/ESP32 compiled-binary parsing and protocol compatibility passed.
- [ ] Ruijie RG-EW1200G Pro v1.1 sysupgrade structure/rootfs audit passed.
- [ ] x86 BIOS and UEFI QEMU boot audit passed.
- [ ] Orange Pi Zero 3, One and PC rootfs + qemu-user audit passed.
- [ ] Production BlazeRental APK is signed with the v0.3 certificate lineage.
- [ ] v1, v2 and v3 APK signature schemes verify.
- [ ] Release SHA256SUMS generated after final staging.
- [ ] No physical-board boot claim is made where only structural/QEMU validation was possible.
