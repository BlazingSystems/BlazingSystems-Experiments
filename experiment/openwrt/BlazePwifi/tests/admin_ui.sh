#!/bin/sh
set -eu
ROOT="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
ADMIN="$ROOT/openwrt/rootfs/www/blazepwifi/admin.html"
PREP="$ROOT/build/prepare-tabler.sh"
BUILD="$ROOT/build/build-openwrt-image.sh"
VENDOR="$ROOT/ui/vendor/tabler"

[ -x "$PREP" ] || { echo "missing prepare-tabler.sh" >&2; exit 1; }
[ "$(cat "$VENDOR/VERSION")" = "1.6.1" ]
grep -q 'The MIT License' "$VENDOR/LICENSE"
grep -q '@tabler/core@1.6.1' "$PREP"
grep -q 'dist/css/tabler.min.css' "$PREP"
! grep -qi 'apexcharts' "$PREP"
! grep -qi 'fullcalendar' "$PREP"
! grep -qi 'libs/' "$PREP"

grep -q '/vendor/tabler/tabler.min.css' "$ADMIN"
grep -q 'loadOptionalTabler' "$ADMIN"
grep -q 'data-tabler' "$ADMIN"
! grep -qE 'https?://.*tabler' "$ADMIN"

# Full x86 staging gets Tabler; the constrained Ruijie overlay stays direct.
grep -q 'prepare-tabler.sh' "$BUILD"
grep -q 'FILES_DIR="$ROOT/openwrt/rootfs"' "$BUILD"
grep -q 'case "$TARGET" in' "$BUILD"
grep -q 'x86_64)' "$BUILD"
grep -q 'FILES="$FILES_DIR"' "$BUILD"

echo "BlazePwifi v0.3 admin UI checks passed"
