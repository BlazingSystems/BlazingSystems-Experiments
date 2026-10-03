# EasyMode for OpenWrt

EasyMode is a simplified management interface and toolkit for OpenWrt intended to make common networking tasks easier while adapting to different categories of OpenWrt hardware.

> Current development: **5.0.0-alpha.1**  
> Preserved known-good R281 baseline: **4.1.4**

## Editions

| Edition | Intended hardware |
|---|---|
| Cellular | OpenWrt devices with cellular modem |
| AP | Access points / 1–2 port devices |
| Router | Normal Wi-Fi routers |
| Switch | Wi-Fi-less OpenWrt switches |
| PC | Expandable x86/PC OpenWrt systems |
| Generic | Minimal universal EasyMode |

All editions share EasyMode Core. Hardware and capability detection control which modules are visible; unsupported controls should not be shown.

## Installer families

1. **Offline HTML** — browser-compatible `/ubus` JSON-RPC connection test and guided bootstrap/fallback. It does not pretend a `file://` page can open raw SSH/Telnet sockets.
2. **Windows PowerShell** — uses Windows built-in OpenSSH/SCP when available; checks prerequisites before upload/install.
3. **OpenWrt bundle/package** — architecture-independent payload distributed as a `.tar.gz` bundle in this alpha. OpenWrt 24.10 and older use `opkg`; OpenWrt 25.12+ uses `apk`.

## Safety

EasyMode is an application/management layer. Normal installation does **not** modify U-Boot, factory/calibration partitions, raw MTD layout, kernel, or boot arguments.

## Status

`5.0.0-alpha.1` is **Static Tested / Hardware Verification Required**. It is not yet a hardware-certified replacement for 4.1.4.
