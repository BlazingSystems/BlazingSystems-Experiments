# OpenWrt Rental Standalone

Use `install.sh --target=auto` after extracting the release bundle.

Recognized target hints: `r281`, `ew1200g-pro`, `generic`, and `auto` (default).

The installer supports OpenWrt 24.10.x and 25.12.x and detects `opkg` vs `apk`.

It copies the complete BlazePwifi rootfs payload but does **not** run the full BlazePwifi uci-defaults script and does **not** start the hotspot core. A separate rental-only document root is created so normal browsing does not expose hotspot/media/general management consoles.

To convert the installed software to full BlazePwifi later:

```sh
/usr/sbin/blazepwifi-rental-upgrade --full
```

Backups are written under `/root/blazepwifi-rental-standalone-backups/`.
