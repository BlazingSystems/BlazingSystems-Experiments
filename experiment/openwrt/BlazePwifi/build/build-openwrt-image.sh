#!/bin/sh
set -eu
VER="${OPENWRT_VERSION:-25.12.5}"
TARGET="${1:-ruijie}"
ROOT="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
WORK="${WORKDIR:-/tmp/blazepwifi-imagebuilder}"

case "$TARGET" in
  ruijie)
    SUB="ramips/mt7621"
    IB="openwrt-imagebuilder-$VER-ramips-mt7621.Linux-x86_64.tar.zst"
    PROFILE="ruijie_rg-ew1200g-pro-v1.1"
    ;;
  x86_64)
    SUB="x86/64"
    IB="openwrt-imagebuilder-$VER-x86-64.Linux-x86_64.tar.zst"
    PROFILE="generic"
    ;;
  *) echo "usage: $0 {ruijie|x86_64}" >&2; exit 2;;
esac

BASE="https://downloads.openwrt.org/releases/$VER/targets/$SUB"
mkdir -p "$WORK"
cd "$WORK"

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
[ -n "$D" ] || { echo "ImageBuilder extraction failed" >&2; exit 1; }
mv "$D" imagebuilder
cd imagebuilder

make image PROFILE="$PROFILE" PACKAGES="uhttpd nftables px5g-mbedtls" FILES="$ROOT/openwrt/rootfs"

OUT="$ROOT/dist/$TARGET"
rm -rf "$OUT"
mkdir -p "$OUT"

case "$TARGET" in
  ruijie)
    find bin/targets -type f -name '*ruijie_rg-ew1200g-pro-v1.1-squashfs-sysupgrade.bin' -exec cp -v {} "$OUT/" \;
    ls "$OUT/"*squashfs-sysupgrade.bin >/dev/null 2>&1 || { echo "Ruijie BlazePwifi sysupgrade image missing" >&2; exit 1; }

    BOOTSTRAP="openwrt-$VER-ramips-mt7621-ruijie_rg-ew1200g-pro-v1.1-initramfs-kernel.bin"
    BOOTSTRAP_SHA="$(awk -v f="$BOOTSTRAP" '$2=="*"f || $2==f {print $1;exit}' "$WORK/sha256sums")"
    [ -n "$BOOTSTRAP_SHA" ] || { echo "Official Ruijie bootstrap checksum entry missing" >&2; exit 1; }
    curl -fL "$BASE/$BOOTSTRAP" -o "$OUT/$BOOTSTRAP"
    echo "$BOOTSTRAP_SHA  $OUT/$BOOTSTRAP" | sha256sum -c -

    cat > "$OUT/RUIJIE-FLASH-NOTES.txt" <<EOF
BlazePwifi Ruijie RG-EW1200G Pro v1.1 release set

1. $BOOTSTRAP
   Origin: official OpenWrt $VER release.
   Purpose: bootstrap/recovery into OpenWrt on supported installation paths.
   This bootstrap does NOT contain BlazePwifi.

2. $(basename "$(ls "$OUT/"*squashfs-sysupgrade.bin | head -n1)")
   Origin: BlazePwifi CI ImageBuilder output.
   Purpose: install/upgrade the persistent BlazePwifi OpenWrt system.

Never flash these files to a different Ruijie hardware revision.
Confirm a serial/TFTP recovery path before replacing stock firmware.
EOF
    ;;
  x86_64)
    find bin/targets -type f \( -name '*combined.img.gz' -o -name '*combined-efi.img.gz' \) -exec cp -v {} "$OUT/" \;
    ls "$OUT/"*combined.img.gz >/dev/null 2>&1 || { echo "x86 combined image missing" >&2; exit 1; }
    ls "$OUT/"*combined-efi.img.gz >/dev/null 2>&1 || { echo "x86 EFI image missing" >&2; exit 1; }
    for image in "$OUT/"*.img.gz; do gzip -t "$image"; done
    ;;
esac

cat > "$OUT/BUILD-MANIFEST.txt" <<EOF
BlazePwifi version: $(cat "$ROOT/VERSION")
OpenWrt version: $VER
Target: $TARGET
Profile: $PROFILE
Ruijie bootstrap source (when applicable): official OpenWrt release, checksum verified
BlazePwifi persistent image source: this CI build
Generated: $(date -u +%Y-%m-%dT%H:%M:%SZ)
EOF

(cd "$OUT" && sha256sum * | grep -v ' SHA256SUMS$' > SHA256SUMS)
echo "BlazePwifi $TARGET images ready in $OUT"
