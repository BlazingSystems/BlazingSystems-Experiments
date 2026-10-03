#!/bin/sh
set -eu
ROOT="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
for f in $(find "$ROOT" -type f \( -name '*.sh' -o -path '*/etc/init.d/*' -o -name 'api' -o -name 'admin' -o -name 'vendo' -o -name 'blazepwifi-core' \)); do sh -n "$f"; done
grep -q 'table inet blazepwifi' "$ROOT/openwrt/rootfs/usr/sbin/blazepwifi-core"
grep -q 'iifname.*meta nfproto ipv6 drop' "$ROOT/openwrt/rootfs/usr/sbin/blazepwifi-core"
grep -q 'replayed coin event' "$ROOT/openwrt/rootfs/srv/blazepwifi-vendo/cgi-bin/vendo"
grep -q '25.12' "$ROOT/installer/install.sh"
grep -q '25.12.2' "$ROOT/build/build-openwrt-image.sh"
grep -q 'fresh Ruijie sysupgrade image missing' "$ROOT/build/build-openwrt-image.sh"
grep -q 'IRAM_ATTR void onCoinPulse' "$ROOT/esp8266/BlazePwifiVendo/BlazePwifiVendo.ino"
grep -q 'uhttpd.blazevendo' "$ROOT/installer/uninstall.sh"
grep -q 'listen_https' "$ROOT/installer/install.sh"
grep -q "home='/srv/blazepwifi-admin'" "$ROOT/installer/install.sh"
[ ! -e "$ROOT/openwrt/rootfs/www/blazepwifi" ]
echo "BlazePwifi static checks passed"
