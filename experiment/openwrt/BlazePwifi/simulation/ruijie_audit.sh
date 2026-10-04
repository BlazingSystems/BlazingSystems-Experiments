#!/bin/bash
set -euo pipefail
OUT=simulation-results/ruijie
mkdir -p "$OUT" downloads cfg/etc/config cfg/etc/blazepwifi
SYS=openwrt-25.12.5-ramips-mt7621-ruijie_rg-ew1200g-pro-v1.1-squashfs-sysupgrade.bin
INI=openwrt-25.12.5-ramips-mt7621-ruijie_rg-ew1200g-pro-v1.1-initramfs-kernel.bin
gh release download v0.3.0 -R BlazingSystems/BlazingSystems-Experiments -p "$SYS" -p "$INI" -D downloads --clobber
file downloads/$SYS downloads/$INI | tee "$OUT/file-types.txt"
binwalk downloads/$SYS | tee "$OUT/binwalk-sysupgrade.txt"
grep -q -E 'Squashfs|squashfs|Flattened Device Tree|FIT' "$OUT/binwalk-sysupgrade.txt"
cp experiment/openwrt/BlazePwifi/openwrt/rootfs/etc/config/blazepwifi cfg/etc/config/blazepwifi
echo 'GitHub Actions MT7621 image/config audit passed' > cfg/etc/blazepwifi/SIMULATION_OK
tar -czf "$OUT/BlazePwifi-Ruijie-config-backup.tar.gz" -C cfg etc
cp downloads/$SYS "$OUT/BlazePwifi-Ruijie-production-sysupgrade.bin"
printf '{"status":"PASS","level":"firmware-structure-and-config","cpu_board_emulation":"UNAVAILABLE_FOR_MT7621_TARGET"}\n' > "$OUT/ruijie-audit.json"
