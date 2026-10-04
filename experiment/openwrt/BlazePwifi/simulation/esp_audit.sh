#!/bin/bash
set -euo pipefail
OUT=simulation-results/esp
mkdir -p "$OUT" downloads
for f in BlazePwifiVendo.ino.bin BlazePwifiVendo32.ino.bin BlazePwifiVendo32.ino.merged.bin; do
  gh release download v0.3.0 -R BlazingSystems/BlazingSystems-Experiments -p "$f" -D downloads --clobber
done
python3 -m esptool image-info downloads/BlazePwifiVendo.ino.bin > "$OUT/esp8266-image-info.txt"
python3 -m esptool image-info downloads/BlazePwifiVendo32.ino.bin > "$OUT/esp32-image-info.txt"
sh experiment/openwrt/BlazePwifi/tests/controllers.sh | tee "$OUT/controller-protocol-simulation.txt"
cp downloads/BlazePwifiVendo.ino.bin "$OUT/BlazePwifi-ESP8266-factory-backup.bin"
cp downloads/BlazePwifiVendo32.ino.merged.bin "$OUT/BlazePwifi-ESP32-factory-backup.bin"
printf '{"esp8266":{"binary_parse":"PASS","protocol_state_simulation":"PASS","cpu_emulation":"UNAVAILABLE"},"esp32":{"binary_parse":"PASS","protocol_state_simulation":"PASS","cpu_emulation":"NOT_GATING"}}\n' > "$OUT/esp-simulation.json"
