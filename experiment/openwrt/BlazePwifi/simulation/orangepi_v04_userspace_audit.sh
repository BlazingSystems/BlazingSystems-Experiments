#!/bin/bash
set -euo pipefail
DIR="${1:?usage: orangepi_v04_userspace_audit.sh ARTIFACT_DIR target [OUT]}"
TARGET="${2:?missing target}"
OUT="${3:-orangepi-v04-audit}"
mkdir -p "$OUT"
MAN="$(find "$DIR" -type f -name BUILD-MANIFEST.txt -print -quit)"
SUMS="$(find "$DIR" -type f -name SHA256SUMS -print -quit)"
GZ="$(find "$DIR" -type f -name '*-ext4-sdcard.img.gz' -print -quit)"
[ -n "$GZ" ] || GZ="$(find "$DIR" -type f -name '*.img.gz' -print -quit)"
test -n "$MAN" -a -n "$SUMS" -a -n "$GZ" -a -s "$GZ"
grep -Fq "Target: $TARGET" "$MAN"
(cd "$(dirname "$SUMS")" && sha256sum -c "$(basename "$SUMS")") | tee "$OUT/checksums.txt"
gzip -t "$GZ"
IMG="$OUT/candidate.img"
gzip -dc "$GZ" > "$IMG"
fdisk -l "$IMG" > "$OUT/fdisk.txt" 2>&1 || true

LOOP="$(sudo losetup --show -Pf "$IMG")"
MNT="$OUT/mnt"
mkdir -p "$MNT"
cleanup(){
  sudo umount "$MNT" 2>/dev/null || true
  sudo losetup -d "$LOOP" 2>/dev/null || true
}
trap cleanup EXIT

ROOTDEV=""
for p in "${LOOP}"p*; do
  [ -b "$p" ] || continue
  if sudo mount -o ro "$p" "$MNT" 2>/dev/null; then
    if [ -f "$MNT/etc/openwrt_release" ] || [ -x "$MNT/etc/init.d/blazepwifi" ]; then
      ROOTDEV="$p"
      break
    fi
    sudo umount "$MNT"
  fi
done
test -n "$ROOTDEV" || { echo "could not locate OpenWrt rootfs partition" >&2; exit 1; }
test -x "$MNT/etc/init.d/blazepwifi"
test -x "$MNT/usr/sbin/blazepwifi-gpio-agent"
test -d "$MNT/usr/share/blazepwifi/orangepi"
test -f "$MNT/www/blazepwifi/admin.html"
test -x "$MNT/bin/busybox"

ARCH="$(file "$MNT/bin/busybox")"
printf '%s\n' "$ARCH" > "$OUT/busybox-file.txt"
if printf '%s' "$ARCH" | grep -qi 'aarch64\|ARM aarch64'; then
  QEMU="$(command -v qemu-aarch64-static)"
else
  QEMU="$(command -v qemu-arm-static)"
fi
"$QEMU" -L "$MNT" "$MNT/bin/busybox" echo BLAZE_ARM_USERSPACE_OK > "$OUT/qemu-user.txt"
grep -Fq BLAZE_ARM_USERSPACE_OK "$OUT/qemu-user.txt"

python3 - "$OUT/audit.json" "$TARGET" "$GZ" "$ROOTDEV" <<'PY'
import hashlib,json,sys,os
out,target,gz,rootdev=sys.argv[1:]
json.dump({"target":target,"release":"0.4.0",
 "validation_level":"disk-structure-rootfs-and-qemu-user",
 "image":os.path.basename(gz),"sha256_gzip":hashlib.sha256(open(gz,'rb').read()).hexdigest(),
 "root_partition":rootdev,
 "checks":{"target_manifest":True,"checksums":True,"gzip":True,"rootfs_mount":True,
           "blazepwifi_service":True,"gpio_agent":True,"admin_ui":True,"qemu_user_busybox":True}},
 open(out,'w'),indent=2)
PY
echo "$TARGET v0.4 image/userspace audit passed"
