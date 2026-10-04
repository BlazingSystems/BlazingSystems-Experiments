#!/bin/sh
set -eu
BASE="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
[ -f /etc/openwrt_release ] || { echo "ERROR: OpenWrt required" >&2; exit 1; }
. /etc/openwrt_release
case "${DISTRIB_RELEASE:-}" in 25.12.*) ;; *) echo "ERROR: BlazePwifi 0.2 targets OpenWrt 25.12.x; detected ${DISTRIB_RELEASE:-unknown}." >&2; exit 1;; esac
command -v apk >/dev/null || { echo "ERROR: apk package manager not found." >&2; exit 1; }
[ "$(id -u)" = 0 ] || { echo "ERROR: run as root" >&2; exit 1; }

FREE_KB="$(df -k /overlay 2>/dev/null | awk 'NR==2{print $4}')"; [ -n "${FREE_KB:-}" ] || FREE_KB=99999
[ "$FREE_KB" -ge 900 ] || { echo "ERROR: need at least 900 KB free overlay space; found ${FREE_KB} KB." >&2; exit 1; }

echo "Installing runtime packages..."
apk -U add uhttpd nftables px5g-mbedtls >/dev/null

STAMP="$(date +%Y%m%d-%H%M%S)"
BACKUP="/root/blazepwifi-backup-$STAMP"
mkdir -p "$BACKUP"
cp -a /etc/config/uhttpd "$BACKUP/" 2>/dev/null || true
cp -a /etc/config/blazepwifi "$BACKUP/" 2>/dev/null || true
cp -a /etc/blazepwifi "$BACKUP/" 2>/dev/null || true

echo "Installing BlazePwifi files..."
cp -a "$BASE/openwrt/rootfs/." /
rm -f /etc/uci-defaults/99-blazepwifi
chmod +x /etc/init.d/blazepwifi /usr/sbin/blazepwifi-core /usr/lib/blazepwifi/common.sh /www/blazepwifi/cgi-bin/*
mkdir -p /etc/blazepwifi/state /tmp/blazepwifi
chmod 700 /etc/blazepwifi /etc/blazepwifi/state /tmp/blazepwifi

randkey(){ hexdump -n 18 -e '18/1 "%02x"' /dev/urandom; }
ADMIN="$(uci -q get blazepwifi.main.admin_key || true)"
VENDO="$(uci -q get blazepwifi.main.vendo_key || true)"
[ "$ADMIN" != CHANGE_ME ] && [ -n "$ADMIN" ] || { ADMIN="$(randkey)"; uci set blazepwifi.main.admin_key="$ADMIN"; }
[ "$VENDO" != CHANGE_ME ] && [ -n "$VENDO" ] || { VENDO="$(randkey)"; uci set blazepwifi.main.vendo_key="$VENDO"; }
uci commit blazepwifi

LAN_IP="$(uci -q get network.lan.ipaddr || true)"
[ -n "$LAN_IP" ] || LAN_IP=192.168.1.1
PORTAL="$(uci -q get blazepwifi.main.portal_port || echo 8080)"
VENDO_PORT="$(uci -q get blazepwifi.main.vendo_port || echo 4455)"
ADMIN_PORT="$(uci -q get blazepwifi.main.admin_port || echo 8443)"

for s in blazepwifi blazepwifi_vendo blazepwifi_admin; do uci -q delete "uhttpd.$s" || true; done

uci set uhttpd.blazepwifi='uhttpd'
uci add_list uhttpd.blazepwifi.listen_http="$LAN_IP:$PORTAL"
uci set uhttpd.blazepwifi.home='/www/blazepwifi'
uci set uhttpd.blazepwifi.cgi_prefix='/cgi-bin'
uci set uhttpd.blazepwifi.rfc1918_filter='0'
uci set uhttpd.blazepwifi.max_requests='32'
uci set uhttpd.blazepwifi.max_connections='128'

uci set uhttpd.blazepwifi_vendo='uhttpd'
uci add_list uhttpd.blazepwifi_vendo.listen_http="$LAN_IP:$VENDO_PORT"
uci set uhttpd.blazepwifi_vendo.home='/www/blazepwifi'
uci set uhttpd.blazepwifi_vendo.cgi_prefix='/cgi-bin'
uci set uhttpd.blazepwifi_vendo.rfc1918_filter='0'
uci set uhttpd.blazepwifi_vendo.max_requests='32'
uci set uhttpd.blazepwifi_vendo.max_connections='64'

uci set uhttpd.blazepwifi_admin='uhttpd'
uci add_list uhttpd.blazepwifi_admin.listen_https="$LAN_IP:$ADMIN_PORT"
uci set uhttpd.blazepwifi_admin.home='/www/blazepwifi'
uci set uhttpd.blazepwifi_admin.cgi_prefix='/cgi-bin'
uci set uhttpd.blazepwifi_admin.rfc1918_filter='0'
uci set uhttpd.blazepwifi_admin.cert='/etc/uhttpd.crt'
uci set uhttpd.blazepwifi_admin.key='/etc/uhttpd.key'
uci set uhttpd.blazepwifi_admin.max_requests='16'
uci set uhttpd.blazepwifi_admin.max_connections='32'

uci -q get uhttpd.defaults >/dev/null 2>&1 || uci set uhttpd.defaults='cert'
uci set uhttpd.defaults.days='1825'
uci set uhttpd.defaults.bits='2048'
uci set uhttpd.defaults.country='PH'
uci set uhttpd.defaults.commonname="$LAN_IP"
uci set uhttpd.defaults.organization='BlazePwifi'
uci commit uhttpd

/etc/init.d/uhttpd restart
/etc/init.d/blazepwifi enable
/etc/init.d/blazepwifi restart
sleep 2

nft list table inet blazepwifi >/dev/null || { echo "ERROR: nftables gate did not start. Restore from $BACKUP" >&2; exit 1; }
[ -s /etc/uhttpd.crt ] && [ -s /etc/uhttpd.key ] || { echo "ERROR: HTTPS certificate was not generated. Restore from $BACKUP" >&2; exit 1; }

echo
echo "BlazePwifi installed."
echo "Portal:   http://$LAN_IP:$PORTAL/"
echo "Admin:    https://$LAN_IP:$ADMIN_PORT/admin.html"
echo "ESP API:  http://$LAN_IP:$VENDO_PORT/cgi-bin/vendo"
echo "Admin key: $ADMIN"
echo "Vendo key: $VENDO"
echo "Backup: $BACKUP"
echo "A browser warning for the local self-signed admin certificate is expected."
echo "IMPORTANT: save the two keys now; existing configured keys are never regenerated during upgrades."
