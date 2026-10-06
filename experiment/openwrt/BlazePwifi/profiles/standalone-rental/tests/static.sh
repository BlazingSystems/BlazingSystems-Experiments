#!/bin/sh
set -eu
ROOT="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"

for f in "$ROOT/openwrt/install.sh" "$ROOT/openwrt/upgrade-to-full.sh" "$ROOT/openwrt/uninstall.sh" "$ROOT/openwrt/install-r281.sh" "$ROOT/openwrt/install-ew1200g-pro.sh" "$ROOT/openwrt/install-generic-openwrt.sh" "$ROOT/openwrt/rental-profile"; do
  sh -n "$f"
done

! grep -Eq 'uci (set|add_list|delete) (network|wireless|firewall)\.' "$ROOT/openwrt/install.sh"
! grep -Eq 'uci commit (network|wireless|firewall)' "$ROOT/openwrt/install.sh"

grep -q "PROFILE_VERSION=\"0.5.2-rental\"" "$ROOT/openwrt/install.sh"
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

COMMON="experiment/openwrt/BlazePwifi/openwrt/rootfs/usr/lib/blazepwifi/common.sh"
AUTH="experiment/openwrt/BlazePwifi/openwrt/rootfs/usr/lib/blazepwifi/auth.sh"
grep -q 'CONTENT_LENGTH' "$COMMON"
grep -q 'dd bs=1 count=' "$COMMON"

BODY='username=admin&password=admin'
LEN="${#BODY}"
PARSED="$(printf '%s' "$BODY" | REQUEST_METHOD=POST CONTENT_LENGTH="$LEN" sh -c '. "$1"; printf "%s|%s" "$(bp_param username)" "$(bp_param password)"' sh "$COMMON")"
[ "$PARSED" = 'admin|admin' ]
grep -q 'BP_AUTH_ALLOW_WEAK_BOOTSTRAP' "$AUTH"
grep -q 'bp_flock_wait' "$COMMON"
! grep -q -- 'flock -w' "$COMMON"
! grep -q -- 'flock -w' "$AUTH"
! grep -q -- 'flock -w' "experiment/openwrt/BlazePwifi/openwrt/rootfs/usr/lib/blazepwifi/update.sh"
grep -q 'BOOT="admin"' "$ROOT/openwrt/install.sh"
grep -q 'sha256i' "$ROOT/openwrt/install.sh"
grep -q 'bp_auth_verify_password admin admin' "$ROOT/openwrt/install.sh"

RESET_BAT="$ROOT/windows/Reset-BlazePwifi-Admin-Password.bat"
RESET_PS="$ROOT/windows/Reset-BlazePwifi-Admin-Password.ps1"
test -f "$RESET_BAT"
test -f "$RESET_PS"
grep -q 'Password: admin' "$RESET_BAT"
grep -q 'PASS=admin' "$RESET_PS"
grep -q 'BLAZE_RESET_OK' "$RESET_PS"
grep -q 'admin-users.tsv' "$RESET_PS"

HTML="$ROOT/openwrt/rental-standalone.html"
grep -q "data.csrf=csrf" "$HTML"
grep -q "refreshCsrf" "$HTML"
grep -q "credentials:'same-origin'" "$HTML"
grep -q "cache:'no-store'" "$HTML"
grep -q "csrf validation failed" "$HTML"
grep -q "QR renderer error" "$HTML"

echo "Standalone Rental v0.5.2-rental.1 static checks passed"
