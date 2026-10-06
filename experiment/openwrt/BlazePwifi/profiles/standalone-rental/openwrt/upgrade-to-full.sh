#!/bin/sh
set -eu
[ "${1:-}" = "--full" ] || { echo "Usage: $0 --full" >&2; exit 2; }
[ "$(id -u)" = 0 ] || { echo "ERROR: run as root" >&2; exit 1; }
[ -f /etc/blazepwifi/RENTAL_STANDALONE ] || { echo "ERROR: Rental Standalone marker not found." >&2; exit 1; }

STAMP="$(date +%Y%m%d-%H%M%S)"
B="/root/blazepwifi-rental-standalone-backups/full-upgrade-$STAMP"
mkdir -p "$B"
cp -p /etc/config/uhttpd "$B/" 2>/dev/null || true
cp -p /etc/config/firewall "$B/" 2>/dev/null || true
cp -p /etc/config/blazepwifi "$B/" 2>/dev/null || true

command -v nft >/dev/null 2>&1 || {
  if command -v apk >/dev/null 2>&1; then apk -U add nftables >/dev/null;
  elif command -v opkg >/dev/null 2>&1; then opkg update >/dev/null; opkg install nftables >/dev/null;
  else echo "ERROR: cannot install nftables" >&2; exit 1; fi
}

LAN_IP="$(uci -q get network.lan.ipaddr || true)"; [ -n "$LAN_IP" ] || LAN_IP=192.168.1.1
ZONE="$(uci -q get blazepwifi.main.firewall_zone || true)"; [ -n "$ZONE" ] || ZONE=lan

echo "WARNING: this converts Rental Standalone into FULL BlazePwifi."
echo "It activates the captive portal/nftables hotspot gate and writes BlazePwifi firewall rules."
printf "Type UPGRADE to continue: "
read -r answer
[ "$answer" = UPGRADE ] || { echo "Cancelled."; exit 1; }

uci set blazepwifi.main.edition='full'
uci set blazepwifi.main.enabled='1'
uci set blazepwifi.main.portal_port='8080'
uci set blazepwifi.main.admin_port='8443'
uci set blazepwifi.main.vendo_port='4455'
uci commit blazepwifi

for s in blazepwifi_rental_http blazepwifi_rental_admin blazepwifi_rental_vendo blazepwifi blazepwifi_admin blazepwifi_vendo; do uci -q delete "uhttpd.$s" || true; done
uci set uhttpd.blazepwifi='uhttpd'
uci add_list uhttpd.blazepwifi.listen_http="$LAN_IP:8080"
uci set uhttpd.blazepwifi.home='/www/blazepwifi'
uci set uhttpd.blazepwifi.cgi_prefix='/cgi-bin'
uci set uhttpd.blazepwifi.rfc1918_filter='0'
uci set uhttpd.blazepwifi_admin='uhttpd'
uci add_list uhttpd.blazepwifi_admin.listen_https="$LAN_IP:8443"
uci set uhttpd.blazepwifi_admin.home='/www/blazepwifi'
uci set uhttpd.blazepwifi_admin.cgi_prefix='/cgi-bin'
uci set uhttpd.blazepwifi_admin.rfc1918_filter='0'
uci set uhttpd.blazepwifi_admin.cert='/etc/uhttpd.crt'
uci set uhttpd.blazepwifi_admin.key='/etc/uhttpd.key'
uci set uhttpd.blazepwifi_vendo='uhttpd'
uci add_list uhttpd.blazepwifi_vendo.listen_http="$LAN_IP:4455"
uci set uhttpd.blazepwifi_vendo.home='/www/blazepwifi'
uci set uhttpd.blazepwifi_vendo.cgi_prefix='/cgi-bin'
uci set uhttpd.blazepwifi_vendo.rfc1918_filter='0'
uci commit uhttpd

for r in blazepwifi_portal blazepwifi_vendo blazepwifi_admin; do uci -q delete "firewall.$r" || true; done
for spec in "portal:8080" "vendo:4455" "admin:8443"; do
  n="${spec%%:*}"; p="${spec#*:}"
  uci set "firewall.blazepwifi_$n=rule"
  uci set "firewall.blazepwifi_$n.name=Allow-BlazePwifi-$n"
  uci set "firewall.blazepwifi_$n.src=$ZONE"
  uci set "firewall.blazepwifi_$n.proto=tcp"
  uci set "firewall.blazepwifi_$n.dest_port=$p"
  uci set "firewall.blazepwifi_$n.target=ACCEPT"
done
uci commit firewall
/etc/init.d/firewall reload >/dev/null 2>&1 || true
/etc/init.d/uhttpd restart
/etc/init.d/blazepwifi enable
/etc/init.d/blazepwifi restart
sleep 2
nft list table inet blazepwifi >/dev/null 2>&1 || { echo "ERROR: full hotspot gate did not start. Backup: $B" >&2; exit 1; }
mv /etc/blazepwifi/RENTAL_STANDALONE /etc/blazepwifi/RENTAL_STANDALONE.upgraded
echo "Full BlazePwifi activated."
echo "Portal: http://$LAN_IP:8080/"
echo "Admin: https://$LAN_IP:8443/admin.html"
echo "Backup: $B"
