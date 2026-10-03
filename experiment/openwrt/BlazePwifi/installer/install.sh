#!/bin/sh
set -eu
BASE="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
[ -f /etc/openwrt_release ] || { echo "ERROR: OpenWrt/ImmortalWrt required" >&2; exit 1; }
. /etc/openwrt_release
case "${DISTRIB_RELEASE:-}" in 25.12.*) ;; *) echo "ERROR: BlazePwifi 1.0-rc1 targets OpenWrt/ImmortalWrt 25.12.x; detected ${DISTRIB_RELEASE:-unknown}." >&2; exit 1;; esac
command -v apk >/dev/null || { echo "ERROR: apk package manager not found." >&2; exit 1; }
[ "$(id -u)" = 0 ] || { echo "ERROR: run as root" >&2; exit 1; }

FREE_KB="$(df -k /overlay 2>/dev/null | awk 'NR==2{print $4}')"; [ -n "${FREE_KB:-}" ] || FREE_KB=99999
[ "$FREE_KB" -ge 700 ] || { echo "ERROR: need at least 700 KB free overlay space; found ${FREE_KB} KB." >&2; exit 1; }

echo "Installing runtime packages..."
apk -U add uhttpd nftables >/dev/null
STAMP="$(date +%Y%m%d-%H%M%S)"; BACKUP="/root/blazepwifi-backup-$STAMP"; mkdir -p "$BACKUP"
cp -a /etc/config/uhttpd "$BACKUP/" 2>/dev/null || true
cp -a /etc/config/blazepwifi "$BACKUP/" 2>/dev/null || true

echo "Installing BlazePwifi files..."
cp -a "$BASE/openwrt/rootfs/." /
rm -f /etc/uci-defaults/99-blazepwifi
chmod +x /etc/init.d/blazepwifi /usr/sbin/blazepwifi-core /usr/lib/blazepwifi/common.sh /www/blazepwifi/cgi-bin/*
mkdir -p /etc/blazepwifi/state; chmod 700 /etc/blazepwifi /etc/blazepwifi/state

randkey(){ od -An -N18 -tx1 /dev/urandom | tr -d ' \n'; }
ADMIN="$(uci -q get blazepwifi.main.admin_key || true)"; VENDO="$(uci -q get blazepwifi.main.vendo_key || true)"
[ "$ADMIN" != CHANGE_ME ] && [ -n "$ADMIN" ] || { ADMIN="$(randkey)"; uci set blazepwifi.main.admin_key="$ADMIN"; }
[ "$VENDO" != CHANGE_ME ] && [ -n "$VENDO" ] || { VENDO="$(randkey)"; uci set blazepwifi.main.vendo_key="$VENDO"; }
uci commit blazepwifi

uci -q delete uhttpd.blazepwifi || true
uci -q delete uhttpd.blazevendo || true
uci set uhttpd.blazepwifi='uhttpd'
uci add_list uhttpd.blazepwifi.listen_http='0.0.0.0:8080'
uci add_list uhttpd.blazepwifi.listen_http='[::]:8080'
uci set uhttpd.blazepwifi.home='/www/blazepwifi'
uci set uhttpd.blazepwifi.cgi_prefix='/cgi-bin'
uci set uhttpd.blazepwifi.rfc1918_filter='0'
uci set uhttpd.blazepwifi.max_requests='20'
uci set uhttpd.blazepwifi.max_connections='100'
uci set uhttpd.blazevendo='uhttpd'
uci add_list uhttpd.blazevendo.listen_http='0.0.0.0:4455'
uci set uhttpd.blazevendo.home='/www/blazepwifi-vendo'
uci set uhttpd.blazevendo.cgi_prefix='/cgi-bin'
uci set uhttpd.blazevendo.rfc1918_filter='0'
uci set uhttpd.blazevendo.max_requests='10'
uci set uhttpd.blazevendo.max_connections='32'

mkdir -p /www/blazepwifi-vendo/cgi-bin
ln -sf /www/blazepwifi/cgi-bin/vendo /www/blazepwifi-vendo/cgi-bin/vendo
uci commit uhttpd
/etc/init.d/uhttpd restart
/etc/init.d/blazepwifi enable
/etc/init.d/blazepwifi restart
sleep 1
nft list table inet blazepwifi >/dev/null || { echo "ERROR: nftables gate did not start. Restore from $BACKUP" >&2; exit 1; }
LAN_IP="$(uci -q get network.lan.ipaddr || echo 192.168.1.1)"
echo
echo "BlazePwifi installed."
echo "Portal: http://$LAN_IP:8080/"
echo "Admin:  http://$LAN_IP:8080/admin.html"
echo "ESP API: http://$LAN_IP:4455/cgi-bin/vendo"
echo "Admin key: $ADMIN"
echo "Vendo key: $VENDO"
echo "Backup: $BACKUP"
echo "IMPORTANT: save the two keys now; they are not printed again by this installer if already configured."
