#!/bin/sh
set -eu
ROOT="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"

for f in "$ROOT/openwrt/install.sh" "$ROOT/openwrt/upgrade-to-full.sh" "$ROOT/openwrt/uninstall.sh" "$ROOT/openwrt/install-r281.sh" "$ROOT/openwrt/install-ew1200g-pro.sh" "$ROOT/openwrt/install-generic-openwrt.sh" "$ROOT/openwrt/rental-profile"; do
  sh -n "$f"
done

! grep -Eq 'uci (set|add_list|delete) (network|wireless|firewall)\.' "$ROOT/openwrt/install.sh"
! grep -Eq 'uci commit (network|wireless|firewall)' "$ROOT/openwrt/install.sh"

grep -q "PROFILE_VERSION=\"0.5.2-rental-rc.1\"" "$ROOT/openwrt/install.sh"
grep -q "edition='rental-standalone'" "$ROOT/openwrt/install.sh"
grep -q "enabled='0'" "$ROOT/openwrt/install.sh"
grep -q "admin_port='443'" "$ROOT/openwrt/install.sh"
grep -q 'Rental console:.*rental/' "$ROOT/openwrt/install.sh"
! grep -q ':8090' "$ROOT/openwrt/install.sh"
! grep -q ':8444' "$ROOT/openwrt/install.sh"

grep -q 'notion,r281' "$ROOT/openwrt/install-r281.sh"
grep -q 'OpenWrt 24.10' "$ROOT/openwrt/install-r281.sh"
grep -q 'expected /www' "$ROOT/openwrt/install-r281.sh"
grep -q 'expected /cgi-bin' "$ROOT/openwrt/install-r281.sh"
grep -q 'HTTPS :443' "$ROOT/openwrt/install-r281.sh"

P="$ROOT/windows/Install-BlazePwifi-Rental.ps1"
test -f "$ROOT/windows/Install-BlazePwifi-Rental.bat"
test -f "$P"
grep -q 'pwfile' "$P"
grep -q 'hostkey' "$P"
grep -q 'UseR281Installer' "$P"
grep -q 'notion,r281' "$P"
grep -q 'install-r281.sh' "$P"
grep -q 'blazepwifi-rental-unpack' "$P"
! grep -q -- '--strip-components' "$P"

grep -q 'policy_sig_v3' "$ROOT/esp8266/BlazeRentalStandalone8266/BlazeRentalStandaloneCore.h"
grep -q 'mode=="rental_coin"' "$ROOT/esp8266/BlazeRentalStandalone8266/BlazeRentalStandaloneCore.h"
grep -q 'mode=="coin_interface"' "$ROOT/esp8266/BlazeRentalStandalone8266/BlazeRentalStandaloneCore.h"
grep -q 'remoteCoins' "$ROOT/esp8266/BlazeRentalStandalone8266/BlazeRentalStandaloneCore.h"

echo "Standalone Rental v0.5.2-rental-rc.1 static checks passed"
