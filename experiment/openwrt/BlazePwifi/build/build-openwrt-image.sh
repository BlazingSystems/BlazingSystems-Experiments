#!/bin/sh
set -eu
VER="${OPENWRT_VERSION:-25.12.5}"
TARGET="${1:-ruijie}"
ROOT="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
WORK="${WORKDIR:-/tmp/blazepwifi-imagebuilder}"
case "$TARGET" in
  ruijie)
    SUB="ramips/mt7621"; IB="openwrt-imagebuilder-$VER-ramips-mt7621.Linux-x86_64.tar.zst"; PROFILE="ruijie_rg-ew1200g-pro-v1.1" ;;
  x86_64)
    SUB="x86/64"; IB="openwrt-imagebuilder-$VER-x86-64.Linux-x86_64.tar.zst"; PROFILE="generic" ;;
  *) echo "usage: $0 {ruijie|x86_64}" >&2; exit 2;;
esac
BASE="https://downloads.openwrt.org/releases/$VER/targets/$SUB"
mkdir -p "$WORK"; cd "$WORK"
command -v curl >/dev/null || { echo "curl required" >&2; exit 1; }
command -v zstd >/dev/null || { echo "zstd required" >&2; exit 1; }
[ -f "$IB" ] || curl -fL "$BASE/$IB" -o "$IB"
curl -fsSL "$BASE/sha256sums" -o sha256sums
EXPECTED="$(awk -v f="$IB" '$2=="*"f || $2==f {print $1;exit}' sha256sums)"
[ -n "$EXPECTED" ] || { echo "checksum entry not found" >&2; exit 1; }
echo "$EXPECTED  $IB" | sha256sum -c -
rm -rf imagebuilder
tar --zstd -xf "$IB"
D="$(find . -maxdepth 1 -type d -name 'openwrt-imagebuilder-*' | head -n1)"
mv "$D" imagebuilder
cd imagebuilder
make image PROFILE="$PROFILE" PACKAGES="uhttpd nftables px5g-mbedtls" FILES="$ROOT/openwrt/rootfs"
mkdir -p "$ROOT/dist/$TARGET"
find bin/targets -type f \( -name '*sysupgrade*' -o -name '*combined*.img.gz' -o -name '*combined-efi*.img.gz' \) -exec cp -v {} "$ROOT/dist/$TARGET/" \;
(cd "$ROOT/dist/$TARGET" && sha256sum * > SHA256SUMS)
