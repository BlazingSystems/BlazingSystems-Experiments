#!/bin/sh
set -eu
ROOT="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"

for f in $(find "$ROOT" -type f \( -name '*.sh' -o -path '*/etc/init.d/*' -o -name 'api' -o -name 'admin' -o -name 'vendo' -o -name 'blazepwifi-core' \)); do
  sh -n "$f"
done

grep -q 'table inet blazepwifi' "$ROOT/openwrt/rootfs/usr/sbin/blazepwifi-core"
grep -q 'priority 10' "$ROOT/openwrt/rootfs/usr/sbin/blazepwifi-core"
grep -q 'walled_v4' "$ROOT/openwrt/rootfs/usr/sbin/blazepwifi-core"
grep -q 'bp_device_norm' "$ROOT/openwrt/rootfs/usr/lib/blazepwifi/common.sh"
grep -q 'bp_self_pid' "$ROOT/openwrt/rootfs/usr/lib/blazepwifi/common.sh"
grep -q 'bp_tmp_suffix' "$ROOT/openwrt/rootfs/usr/lib/blazepwifi/common.sh"
grep -q 'tmp="$BP_STATE/.accounts.$(bp_tmp_suffix)"' "$ROOT/openwrt/rootfs/usr/lib/blazepwifi/common.sh"
grep -q "option durable_sync '1'" "$ROOT/openwrt/rootfs/etc/config/blazepwifi"
grep -q "option firewall_zone 'lan'" "$ROOT/openwrt/rootfs/etc/config/blazepwifi"
grep -q "Allow-BlazePwifi-Portal" "$ROOT/installer/install.sh"
grep -q 'coin target mismatch' "$ROOT/openwrt/rootfs/www/blazepwifi/cgi-bin/vendo"
grep -q 'vendo API requires dedicated port' "$ROOT/openwrt/rootfs/www/blazepwifi/cgi-bin/vendo"
grep -q 'admin API requires HTTPS' "$ROOT/openwrt/rootfs/www/blazepwifi/cgi-bin/admin"
grep -q 'listen_https' "$ROOT/installer/install.sh"
grep -q 'px5g-mbedtls' "$ROOT/build/build-openwrt-image.sh"
grep -q 'WiFi.softAP(ap.c_str(),cfg.apPass)' "$ROOT/esp8266/BlazePwifiVendo/BlazePwifiVendo.ino"
grep -q '#include <LittleFS.h>' "$ROOT/esp8266/BlazePwifiVendo/BlazePwifiVendo.ino"
grep -q 'Recovered unacknowledged coin event from flash' "$ROOT/esp8266/BlazePwifiVendo/BlazePwifiVendo.ino"
grep -q 'BP_TARGET_DIR="$BP_STATE/targets"' "$ROOT/openwrt/rootfs/usr/lib/blazepwifi/common.sh"
grep -q '25.12' "$ROOT/installer/install.sh"

for x in \
  openwrt/rootfs/etc/init.d/blazepwifi \
  openwrt/rootfs/etc/uci-defaults/99-blazepwifi \
  openwrt/rootfs/usr/sbin/blazepwifi-core \
  openwrt/rootfs/www/blazepwifi/cgi-bin/api \
  openwrt/rootfs/www/blazepwifi/cgi-bin/admin \
  openwrt/rootfs/www/blazepwifi/cgi-bin/vendo
do
  [ -x "$ROOT/$x" ] || { echo "required executable bit missing: $x" >&2; exit 1; }
done

if grep -q 'tmp="$BP_RUN/accounts' "$ROOT/openwrt/rootfs/usr/lib/blazepwifi/common.sh"; then
  echo 'persistent account temp files must stay on the state filesystem' >&2
  exit 1
fi

if grep -q '0.0.0.0:8443' "$ROOT/installer/install.sh"; then
  echo 'admin listener must not bind WAN wildcard' >&2
  exit 1
fi

echo 'BlazePwifi v0.2 static checks passed'
