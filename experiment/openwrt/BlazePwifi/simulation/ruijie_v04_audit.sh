#!/bin/bash
set -euo pipefail
DIR="${1:?usage: ruijie_v04_audit.sh ARTIFACT_DIR [OUT]}"
OUT="${2:-ruijie-v04-audit}"
mkdir -p "$OUT"
MAN="$(find "$DIR" -type f -name BUILD-MANIFEST.txt -print -quit)"
SUMS="$(find "$DIR" -type f -name SHA256SUMS -print -quit)"
IMG="$(find "$DIR" -type f -name '*ruijie_rg-ew1200g-pro-v1.1-squashfs-sysupgrade.bin' -print -quit)"
test -n "$MAN" -a -n "$SUMS" -a -n "$IMG" -a -s "$IMG"
grep -Fq 'Target: ruijie' "$MAN"
grep -Fq 'Profile: ruijie_rg-ew1200g-pro-v1.1' "$MAN"
(cd "$(dirname "$SUMS")" && sha256sum -c "$(basename "$SUMS")") | tee "$OUT/checksums.txt"
file "$IMG" | tee "$OUT/file.txt"

mkdir -p "$OUT/sysupgrade"
tar -tf "$IMG" > "$OUT/sysupgrade-list.txt"
grep -Eq '/kernel$' "$OUT/sysupgrade-list.txt"
grep -Eq '/root$' "$OUT/sysupgrade-list.txt"
tar -xf "$IMG" -C "$OUT/sysupgrade"
ROOTIMG="$(find "$OUT/sysupgrade" -type f -name root -print -quit)"
test -n "$ROOTIMG" -a -s "$ROOTIMG"
file "$ROOTIMG" | tee "$OUT/root-file.txt"
mkdir -p "$OUT/rootfs"
unsquashfs -f -d "$OUT/rootfs" "$ROOTIMG" > "$OUT/unsquashfs.txt"
test -x "$OUT/rootfs/etc/init.d/blazepwifi"
test -f "$OUT/rootfs/www/blazepwifi/admin.html"
test -x "$OUT/rootfs/www/blazepwifi/cgi-bin/rental"
test -f "$OUT/rootfs/www/blazepwifi/vendor/tailadmin/blaze-tailadmin.css"

python3 - "$OUT/audit.json" "$IMG" <<'PY'
import hashlib,json,sys,os
out,path=sys.argv[1:]
json.dump({"target":"ruijie_rg-ew1200g-pro-v1.1","release":"0.4.0",
 "validation_level":"sysupgrade-structure-and-rootfs-extraction",
 "firmware":os.path.basename(path),"sha256":hashlib.sha256(open(path,'rb').read()).hexdigest(),
 "checks":{"target_manifest":True,"checksums":True,"sysupgrade_tar":True,"kernel_member":True,
           "root_member":True,"squashfs_extract":True,"blazepwifi_service":True,
           "admin_ui":True,"rental_api":True}},open(out,'w'),indent=2)
PY
echo "Ruijie v0.4 structural audit passed (not a physical MT7621 boot claim)"
