#!/bin/bash
set -euo pipefail
OUT=simulation-results/orangepi
mkdir -p "$OUT" downloads
ASSETS=(
openwrt-25.12.5-sunxi-cortexa7-xunlong_orangepi-zero-ext4-sdcard.img.gz
openwrt-25.12.5-sunxi-cortexa7-xunlong_orangepi-one-ext4-sdcard.img.gz
openwrt-25.12.5-sunxi-cortexa7-xunlong_orangepi-pc-ext4-sdcard.img.gz
openwrt-25.12.5-sunxi-cortexa7-xunlong_orangepi-pc-plus-ext4-sdcard.img.gz
openwrt-25.12.5-sunxi-cortexa53-xunlong_orangepi-one-plus-ext4-sdcard.img.gz
openwrt-25.12.5-sunxi-cortexa53-xunlong_orangepi-pc2-ext4-sdcard.img.gz
openwrt-25.12.5-sunxi-cortexa53-xunlong_orangepi-zero2-ext4-sdcard.img.gz
openwrt-25.12.5-sunxi-cortexa53-xunlong_orangepi-zero2w-ext4-sdcard.img.gz
openwrt-25.12.5-sunxi-cortexa53-xunlong_orangepi-zero3-ext4-sdcard.img.gz
)
for asset in "${ASSETS[@]}"; do
  echo "=== AUDIT $asset ==="
  gh release download v0.3.0 -R BlazingSystems/BlazingSystems-Experiments -p "$asset" -D downloads --clobber
  img="downloads/${asset%.gz}"
  gzip -dkf "downloads/$asset"
  size=$(stat -c%s "$img")
  rem=$((size % 512))
  [ "$rem" -eq 0 ] || truncate -s $((size + 512 - rem)) "$img"
  fdisk -l "$img" | tee "$OUT/$(basename "$asset" .img.gz)-partitions.txt"
  rootline=$(partx -g -o START,SECTORS,NR "$img" | tail -n1)
  read -r start sectors nr <<< "$rootline"
  test -n "$start"
  offset=$((start*512))
  sizelimit=$((sectors*512))
  mnt=$(mktemp -d)
  sudo mount -o loop,offset="$offset",sizelimit="$sizelimit" "$img" "$mnt"
  for required in etc/openwrt_release etc/config/blazepwifi usr/sbin/blazepwifi-core www/blazepwifi/index.html www/blazepwifi/admin.html; do
    sudo test -e "$mnt/$required"
  done
  if [[ "$asset" == *cortexa7* ]]; then qemu=$(command -v qemu-arm-static); else qemu=$(command -v qemu-aarch64-static); fi
  sudo cp "$qemu" "$mnt/usr/bin/$(basename "$qemu")"
  sudo chroot "$mnt" "/usr/bin/$(basename "$qemu")" /bin/busybox echo userspace-exec-ok | grep -q userspace-exec-ok
  sudo mkdir -p "$mnt/etc/blazepwifi"
  echo 'GitHub Actions Orange Pi userspace/image audit passed' | sudo tee "$mnt/etc/blazepwifi/SIMULATION_OK" >/dev/null
  sudo sed -i "/config blazepwifi 'main'/a\\\toption simulation_verified '1'" "$mnt/etc/config/blazepwifi"
  sudo rm -f "$mnt/usr/bin/$(basename "$qemu")"
  sync
  sudo umount "$mnt"
  rmdir "$mnt"
  name=$(basename "$asset" .img.gz)
  gzip -c "$img" > "$OUT/${name}-configured-backup.img.gz"
  printf '{"asset":"%s","status":"PASS","level":"userspace-image","root_partition":%s}\n' "$asset" "$nr" > "$OUT/${name}-audit.json"
  rm -f "$img"
done
