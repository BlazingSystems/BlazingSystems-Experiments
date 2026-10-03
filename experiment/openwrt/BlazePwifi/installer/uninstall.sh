#!/bin/sh
set -eu
[ "$(id -u)" = 0 ] || { echo "run as root" >&2; exit 1; }
/etc/init.d/blazepwifi stop 2>/dev/null || true
/etc/init.d/blazepwifi disable 2>/dev/null || true
nft delete table inet blazepwifi 2>/dev/null || true
uci -q delete uhttpd.blazepwifi || true
uci -q delete uhttpd.blazeadmin || true
uci -q delete uhttpd.blazevendo || true
uci commit uhttpd
/etc/init.d/uhttpd restart 2>/dev/null || true
rm -rf /srv/blazepwifi-public /srv/blazepwifi-admin /srv/blazepwifi-vendo /usr/lib/blazepwifi /usr/sbin/blazepwifi-core /etc/init.d/blazepwifi
printf 'BlazePwifi runtime removed. Persistent state and /etc/config/blazepwifi were retained.\n'
