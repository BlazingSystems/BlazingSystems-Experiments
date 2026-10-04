#!/bin/sh
set -eu
ROOT="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
E6="$ROOT/esp8266/BlazePwifiVendo/BlazePwifiVendo.ino"
E32="$ROOT/esp32/BlazePwifiVendo32/BlazePwifiVendo32.ino"
[ -f "$E6" ] || { echo "missing ESP8266 controller" >&2; exit 1; }
[ -f "$E32" ] || { echo "missing ESP32 controller" >&2; exit 1; }

for f in "$E6" "$E32"; do
  grep -q 'cgi-bin/vendo' "$f"
  grep -q 'register' "$f"
  grep -q 'poll' "$f"
  grep -q 'coin' "$f"
  grep -q 'target' "$f"
  grep -q 'sig' "$f"
  grep -q 'pending' "$f"
  grep -q 'coinPin' "$f"
  grep -q 'relayPin' "$f"
done

grep -q 'Preferences' "$E32"
grep -q 'LittleFS' "$E32"
grep -q 'coinDebounceMs' "$E32"
grep -q 'pulseGroupMs' "$E32"
grep -q 'coinActiveLow' "$E32"
grep -q 'relayActiveHigh' "$E32"
grep -q 'ledActiveHigh' "$E32"

DOC="$ROOT/docs/PROTOCOL.md"
grep -q 'ESP8266' "$DOC"
grep -q 'ESP32' "$DOC"
grep -q 'Linux GPIO' "$DOC"

echo "BlazePwifi controller protocol parity checks passed"
