#!/bin/sh
# v0.3 foundation release gate
set -eu
ROOT="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"

[ "$(cat "$ROOT/VERSION")" = "0.3.0-rc.1" ] || {
  echo "VERSION must be 0.3.0-rc.1" >&2; exit 1;
}

if grep -RniE 'WiFi5|wifi5-soft\.com' "$ROOT"   --exclude-dir=.git --exclude='2026-10-04-blazepwifi-v0.3-design.md'   --exclude='2026-10-04-blazepwifi-v0.3-plan.md' >/tmp/blaze-prohibited.$$ 2>/dev/null; then
  cat /tmp/blaze-prohibited.$$ >&2
  rm -f /tmp/blaze-prohibited.$$
  echo "prohibited commercial reference remains in public BlazePwifi tree" >&2
  exit 1
fi
rm -f /tmp/blaze-prohibited.$$

CFG="$ROOT/openwrt/rootfs/etc/config/blazepwifi"
grep -q "option capability_tier 'auto'" "$CFG"
! grep -q "option admin_key 'CHANGE_ME'" "$CFG"
! grep -q "option vendo_key 'CHANGE_ME'" "$CFG"

CAP="$ROOT/openwrt/rootfs/usr/lib/blazepwifi/capabilities.sh"
[ -f "$CAP" ] || { echo "missing capabilities.sh" >&2; exit 1; }

BP_CAP_TIER=auto BP_CAP_ARCH=mips BP_CAP_MEM_KB=131072 BP_CAP_OVERLAY_KB=8192 sh "$CAP" --detect | grep -qx lite
BP_CAP_TIER=auto BP_CAP_ARCH=aarch64 BP_CAP_MEM_KB=524288 BP_CAP_OVERLAY_KB=1048576 sh "$CAP" --detect | grep -qx standard
BP_CAP_TIER=auto BP_CAP_ARCH=x86_64 BP_CAP_MEM_KB=2097152 BP_CAP_OVERLAY_KB=2097152 sh "$CAP" --detect | grep -qx full
BP_CAP_TIER=lite BP_CAP_ARCH=x86_64 BP_CAP_MEM_KB=2097152 BP_CAP_OVERLAY_KB=2097152 sh "$CAP" --detect | grep -qx lite

echo "BlazePwifi v0.3 foundation checks passed"
