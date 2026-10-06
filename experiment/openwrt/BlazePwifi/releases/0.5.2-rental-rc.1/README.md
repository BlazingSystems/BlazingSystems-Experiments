# BlazePwifi Standalone Rental Server v0.5.2-rental-rc.1

This release follows the BlazePwifi **0.5.2 implementation** line and fixes the R281 physical-install regression found in the Windows OneClick package.

## R281 fix

The previous OneClick package reached the R281 over SSH but used GNU tar's strip-components option. The R281 uses BusyBox tar, so extraction stopped before the router-side installer could start.

v0.5.2-rental-rc.1 now detects the board before deployment. `notion,r281` automatically selects the dedicated R281/EasyMode installer and uses BusyBox-compatible extraction only.

The R281 entry preserves the deployment assumptions proven by the earlier successful R281 rental profile: OpenWrt 24.10.x, `/www`, `/cgi-bin`, HTTPS :443, and no ownership of network/wireless/firewall configuration.

## Windows OneClick

First-time PuTTY host-key GUI verification from the previous hotfix remains included. A normal first install should now proceed from credential prompts → host-key trust → board detection → upload → BusyBox extraction → R281-specific install → `/rental/`.

## Other targets

EW1200G Pro, generic supported OpenWrt, x86, ESP8266 and ESP32 remain part of the Standalone Rental release line.

This remains a release candidate pending additional physical hardware testing.
