BlazeRental R281 Test Hub v0.1.0 - Test Report
================================================

Static checks
- POSIX shell syntax: PASS for installer, app CGI, admin CGI.
- Installer does not issue uci set/commit, firewall reload, network reload, wifi reload, modem commands, or reboot.
- Installer verifies existing uHTTPd home=/www and cgi_prefix=/cgi-bin and aborts rather than modifying them.
- Existing /www/index.html and /www/admin are not written.
- Existing non-Blaze /www/rental or /www/cgi-bin/rental endpoints cause a safe abort unless --force is explicitly used.

Protocol integration check (host-side)
- Admin health authentication: PASS.
- One-time enrollment token generation: PASS.
- BlazeRental-compatible HMAC-SHA256 enrollment: PASS.
- Device ID + device secret creation: PASS.
- Signed status response: PASS.
- Expired/zero-time compatibility clamp to server-now: PASS.
- Manual +3600 second lease grant: PASS.
- Signed status reflected >= 3599 seconds remaining: PASS.
- coin_start in manual-only mode returns a clear operator message: PASS.

Target evidence used
- R281 backup: uHTTPd main serves /www on ports 80/443 with cgi_prefix=/cgi-bin.
- R281 backup: LAN IP is 192.168.1.1.
- Existing OpenWrt/EasyMode network, firewall, relay, modem and Wi-Fi configuration remain outside installer write paths.
- Repository R281 baseline: board notion,r281, OpenWrt 24.10.8, EasyMode 4.2.3 experiment.
- Current BlazeRental client API path: BASE_URL/cgi-bin/rental.

Remaining physical validation
- Run installer on the actual R281.
- Open /rental from a LAN client.
- Enroll the actual BlazeRental APK.
- Verify Device Owner/manual APK behavior and lease refresh on the physical Android phone.

This is a rental test hub, not a full hotspot/coinslot BlazePwifi deployment.
