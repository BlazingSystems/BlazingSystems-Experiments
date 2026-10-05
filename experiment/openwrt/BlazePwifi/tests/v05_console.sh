#!/bin/sh
set -eu
ROOT="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
W="$ROOT/openwrt/rootfs/www/blazepwifi"
ADMIN="$W/admin.html"
CGI="$W/cgi-bin/admin"
PORTAL="$W/index.html"

[ "$(cat "$ROOT/VERSION")" = "0.5.0" ]
test -f "$W/admin/console-v05.js"
test -f "$W/media.html"
test -f "$W/games.html"

for label in   "Clients & Sessions" "Sales & Reports" "WAN & Internet" "LAN · VLAN · Wi-Fi"   "Worldwide Remote Access" "Vouchers & Rates" "Rental Devices" "Coin Controllers"   "Portal Designer" "Multimedia Manager" "BlazeGames Manager" "Storage" "Backups"   "Tools & Terminal" "Alerts & Logs" "System & Security"
do
  grep -Fq "$label" "$ADMIN"
done

grep -Fq 'WireGuard · Recommended' "$ADMIN"
grep -Fq 'ZeroTier · Easy mesh' "$ADMIN"
grep -Fq 'Advanced Terminal' "$ADMIN"
grep -Fq 'tool_run)' "$CGI"
grep -Fq 'system_info)' "$CGI"
grep -Fq 'storage_list)' "$CGI"
grep -Fq 'remote_status)' "$CGI"
grep -Fq 'unsupported safe command' "$CGI"
grep -Fq 'invalid diagnostic target' "$CGI"

grep -Fq '>Movies<' "$PORTAL"
grep -Fq '>Games<' "$PORTAL"
grep -Fq 'detailVlan' "$PORTAL"
grep -Fq 'detailSpeed' "$PORTAL"
grep -Fq 'detailLoad' "$PORTAL"
grep -Fq 'detailRam' "$PORTAL"
grep -Fq 'detailUptime' "$PORTAL"
grep -Fq 'active, unpaused paid session' "$W/media.html"
grep -Fq 'active, unpaused paid time' "$W/games.html"

! grep -Eq 'https?://[^" ]+\.(css|js)' "$ADMIN"
! grep -Eq 'bootstrap(\.min)?\.(css|js)' "$ADMIN"

echo "BlazePwifi v0.5 console and portal contract passed"
