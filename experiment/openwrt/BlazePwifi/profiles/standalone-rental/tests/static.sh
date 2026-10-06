#!/bin/sh
set -eu
ROOT="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
for f in "$ROOT/openwrt/install.sh" "$ROOT/openwrt/upgrade-to-full.sh" "$ROOT/openwrt/uninstall.sh" "$ROOT/openwrt/install-r281.sh" "$ROOT/openwrt/install-ew1200g-pro.sh" "$ROOT/openwrt/install-generic-openwrt.sh" "$ROOT/openwrt/rental-profile"; do
  sh -n "$f"
done

# Rental Standalone installation must not take ownership of the current
# networking stack. Full conversion is the only script allowed to write firewall.
! grep -Eq 'uci (set|add_list|delete|commit) (network|wireless)\.' "$ROOT/openwrt/install.sh"
! grep -Eq 'uci commit (network|wireless)' "$ROOT/openwrt/install.sh"
! grep -Eq 'uci (set|add_list|delete) firewall\.' "$ROOT/openwrt/install.sh"
! grep -Eq 'uci commit firewall' "$ROOT/openwrt/install.sh"

grep -q "edition='rental-standalone'" "$ROOT/openwrt/install.sh"
grep -q "enabled='0'" "$ROOT/openwrt/install.sh"
grep -q 'blazepwifi-rental-upgrade --full' "$ROOT/README.md"
grep -q 'policy_sig_v3' "$ROOT/esp8266/BlazeRentalStandalone8266/BlazeRentalStandaloneCore.h"
grep -q 'role=="multicoin"' "$ROOT/esp8266/BlazeRentalStandalone8266/BlazeRentalStandaloneCore.h"
grep -q 'BLAZE_SLOT_COUNT 2' "$ROOT/esp8266/BlazeRentalStandalone8266/BlazeRentalStandalone8266.ino"
grep -q 'BLAZE_SLOT_COUNT 4' "$ROOT/esp32/BlazeRentalStandalone32/BlazeRentalStandalone32.ino"
echo "Standalone Rental profile static checks passed"
