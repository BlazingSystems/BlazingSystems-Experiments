#!/bin/sh
set -eu
VER="${IMMORTALWRT_VERSION:-25.12.2}"
TARGET="${1:-ruijie}"
ROOT="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
WORK="${WORKDIR:-/tmp/blazepwifi-imagebuilder}"
case "$TARGET" in
  ruijie)
    SUB="ramips/mt7621"; IB="immortalwrt-imagebuilder-$VER-ramips-mt7621.Linux-x86_64.tar.zst"; PROFILE="ruijie_rg-ew1200g-pro-v1.1" ;;
  x86_64)
    SUB="x86/64"; IB="immortalwrt-imagebuilder-$VER-x86-64.Linux-x86_64.tar.zst"; PROFILE="generic" ;;
  *) echo "usage: $0 {ruijie|x86_64}" >&2; exit 2;;
esac
BASE="https://downloads.immortalwrt.org/releases/$VER/targets/$SUB"
mkdir -p "$WORK"; cd "$WORK"
command -v curl >/dev/null || { echo "curl required" >&2; exit 1; }
command -v zstd >/dev/null || { echo "zstd required" >&2; exit 1; }
[ -f "$IB" ] || curl -fL "$BASE/$IB" -o "$IB"
curl -fsSL "$BASE/sha256sums" -o sha256sums
EXPECTED="$(awk -v f="$IB" '$2=="*"f || $2==f {print $1;exit}' sha256sums)"
[ -n "$EXPECTED" ] || { echo "checksum entry not found" >&2; exit 1; }
echo "$EXPECTED  $IB" | sha256sum -c -
rm -rf imagebuilder
tar --zstd -xf "$IB"; D="$(find . -maxdepth 1 -type d -name 'immortalwrt-imagebuilder-*' | head -n1)"; mv "$D" imagebuilder
cd imagebuilder
if [ "$TARGET" = x86_64 ]; then
  make image PROFILE="$PROFILE" PACKAGES="uhttpd nftables px5g-mbedtls" FILES="$ROOT/openwrt/rootfs" ROOTFS_PARTSIZE=1024
else
  make image PROFILE="$PROFILE" PACKAGES="uhttpd nftables px5g-mbedtls" FILES="$ROOT/openwrt/rootfs"
fi
rm -rf "$ROOT/dist/$TARGET"
mkdir -p "$ROOT/dist/$TARGET"
find bin/targets -type f \( -name '*sysupgrade*' -o -name '*initramfs*' -o -name '*combined*.img.gz' -o -name '*combined-efi*.img.gz' \) -exec cp -v {} "$ROOT/dist/$TARGET/" \;
case "$TARGET" in
  ruijie)
    find "$ROOT/dist/$TARGET" -maxdepth 1 -type f -name '*sysupgrade*.bin' | grep -q . || { echo "ERROR: fresh Ruijie sysupgrade image missing" >&2; exit 1; }
    if find "$ROOT/dist/$TARGET" -maxdepth 1 -type f -name '*initramfs*.bin' | grep -q .; then
      RECOVERY_STATUS='included'
    else
      RECOVERY_STATUS='not-produced-by-imagebuilder'
      echo "NOTE: this ImageBuilder profile produced sysupgrade only; initramfs recovery requires an official prebuilt image or a full ImmortalWrt buildroot." >&2
    fi
    ;;
  x86_64)
    find "$ROOT/dist/$TARGET" -maxdepth 1 -type f -name '*combined-efi*.img.gz' | grep -q . || { echo "ERROR: fresh x86 EFI image missing" >&2; exit 1; }
    RECOVERY_STATUS='not-applicable'
    ;;
esac
(
  cd "$ROOT/dist/$TARGET"
  rm -f SHA256SUMS BUILDINFO.txt
  printf 'BlazePwifi=%s\nBase=ImmortalWrt %s\nTarget=%s\nProfile=%s\nRecoveryImage=%s\nBuiltUTC=%s\n' "$(cat "$ROOT/VERSION")" "$VER" "$TARGET" "$PROFILE" "${RECOVERY_STATUS:-unknown}" "$(date -u +%Y-%m-%dT%H:%M:%SZ)" > BUILDINFO.txt
  for f in *; do
    [ -f "$f" ] || continue
    [ "$f" = SHA256SUMS ] && continue
    sha256sum "$f"
  done > SHA256SUMS
)
