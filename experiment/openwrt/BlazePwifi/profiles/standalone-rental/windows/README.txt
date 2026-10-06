BlazePwifi Standalone Rental Server - Windows OneClick
Version: v0.5.3-rental-rc.1
Core baseline: BlazePwifi 0.5.3-dev.1

INSTALL
1. Extract the ZIP completely.
2. Double-click Install-BlazePwifi-Rental.bat.
3. Enter router IP/hostname, SSH username and password.
4. Confirm the SSH host-key fingerprint on first connection.
5. The installer detects the board.
6. notion,r281 automatically uses the R281/EasyMode compatibility path.
7. Other supported OpenWrt targets use generic target detection.

The R281 path is BusyBox-compatible and never uses GNU tar-only extraction options.

Normal Standalone installation does not intentionally modify network, wireless, or firewall UCI packages.

After installation:
  Rental console: https://ROUTER-IP/rental/
  Android server: https://ROUTER-IP
  Rental API: https://ROUTER-IP/cgi-bin/rental

Fresh-install Rental console credentials:
  Username: admin
  Password: admin

Existing administrator records are preserved on upgrade.

PASSWORD RESET
Double-click Reset-BlazePwifi-Admin-Password.bat.
It works with Standalone Rental and full BlazePwifi and always restores:
  Username: admin
  Password: admin

PROVISIONING
Standard Enrollment QR and Device Owner Provisioning QR are separate.
Device Owner provisioning is HTTPS-only and uses exact APK/checksum metadata injected by release CI.
This RC uses a TEST-signed provisioning APK and is not production-ready until physical Setup Wizard validation and production signing succeed.

The package includes pinned PuTTY command-line deployment tools and the bundled PuTTY licence text.
