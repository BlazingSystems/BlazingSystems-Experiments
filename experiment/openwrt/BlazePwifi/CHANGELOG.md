# Changelog

## 1.0.0-rc1 — 2026-10-04

- Reconciled supplied WiFi5 Ruijie/x86 firmware and public resource references.
- Confirmed WiFi5 uses ImmortalWrt; production ImageBuilder moved to current stable ImmortalWrt 25.12.2.
- Added mandatory Ruijie sysupgrade validation, optional initramfs capture when ImageBuilder provides it, and x86 1 GiB writable root image build.
- Added per-build SHA256SUMS and BUILDINFO metadata.
- Removed five-second persistent session rewrites that would cause unnecessary flash wear.
- Moved Vendo heartbeat/poll state to tmpfs.
- Bound coin messages to server target nonce + monotonic sequence and made credit commit atomic.
- Prevented active coin-window takeover by another client.
- Removed client-supplied MAC fallback; MAC derives from source-IP neighbor/DHCP state.
- Admin secrets no longer accepted from query parameters.
- Split public portal, HTTPS admin, and Vendo API into separate `/srv` uhttpd document roots, bound them to the LAN address only, and removed BlazePwifi pages from the router default `/www` root.
- Added HTTPS-only admin access with a device-local certificate.\n- Added secure setup-AP fallback behavior for ESP8266.
- Changed ESP8266 coin capture to interrupt-driven counting so HTTP/Wi-Fi polling cannot miss short coin pulses.
- Added ESP GPIO validation to reject flash-reserved pins and GPIO16 for coin interrupts.
- Added IPv4-only hotspot default and reference-aligned 10.0.0.1/19 DHCP configuration for custom images.
- Added security regression tests.

## 0.1.0-alpha.1 — 2026-10-04

- Initial clean-room BlazePwifi implementation.
