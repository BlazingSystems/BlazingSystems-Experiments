#!/bin/sh
set -eu
ROOT="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
for f in $(find "$ROOT" -type f \( -name '*.sh' -o -path '*/etc/init.d/*' -o -name 'api' -o -name 'admin' -o -name 'vendo' -o -name 'blazepwifi-core' \)); do sh -n "$f"; done
grep -q 'table inet blazepwifi' "$ROOT/openwrt/rootfs/usr/sbin/blazepwifi-core"
grep -q 'replayed coin event' "$ROOT/openwrt/rootfs/www/blazepwifi/cgi-bin/vendo"
grep -q '25.12' "$ROOT/installer/install.sh"
echo "BlazePwifi static checks passed"
