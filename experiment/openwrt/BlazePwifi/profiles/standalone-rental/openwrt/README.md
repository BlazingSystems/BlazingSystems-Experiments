# OpenWrt Standalone Rental — v0.5.3-rental-rc.1

Core baseline: BlazePwifi `0.5.3-dev.1`.

The installer is intentionally network-neutral. Normal Standalone installation does not take ownership of WAN, LAN, Wi-Fi, cellular, repeater, DNS, or firewall UCI configuration.

After installation:

- Rental console: `https://LocalIP/rental/`
- BlazeRental server: `https://LocalIP`
- Rental API: `https://LocalIP/cgi-bin/rental`
- remote ESP coin API: `http://LocalIP:4455/cgi-bin/vendo`

## R281 / EasyMode

The Windows installer detects `notion,r281` and invokes `install-r281.sh`.

The R281 adapter validates:

- OpenWrt 24.10.x;
- uHTTPd root `/www`;
- CGI prefix `/cgi-bin`;
- HTTPS :443.

Archive extraction uses BusyBox-supported options only.

## Device Owner provisioning

The source tree fails closed without exact release metadata. Release CI injects `rental-provisioning.tsv` into the generated OpenWrt bundle only after building, signing, verifying, and hashing the exact TEST APK.

That metadata is separate from the normal BlazeRental update channel.
