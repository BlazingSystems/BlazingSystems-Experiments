BlazePwifi Standalone Rental Server - Windows One-Click Installer
Version: v0.5.2-rental-rc.1

1. Extract the ZIP completely.
2. Double-click Install-BlazePwifi-Rental.bat.
3. Enter the OpenWrt router IP/hostname, SSH username and password.
4. Confirm the router SSH host-key fingerprint on first connection.
5. The installer probes the board before deployment.
6. If it detects notion,r281 it automatically uses the R281/EasyMode-specific installation path.
7. Other supported OpenWrt devices use the generic target-detection path.

The R281 path is BusyBox-compatible and does not use GNU tar-only extraction options.

Normal Rental Standalone installation does not intentionally modify network, wireless or firewall UCI packages.

After installation:
  Rental console: https://ROUTER-IP/rental/
  Android server: http://ROUTER-IP

The SSH password is written only to a temporary local file for plink/pscp and is overwritten/deleted at the end of the run.

The package includes PuTTY command-line SSH tools (plink/pscp) solely for deployment. See the included PuTTY licence file.
