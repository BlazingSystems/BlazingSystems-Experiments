#!/bin/sh
set -eu
ROOT="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
WF="$ROOT/../../../.github/workflows/blazepwifi-build.yml"
[ "$(cat "$ROOT/VERSION")" = "0.4.0" ]
test -f "$ROOT/releases/0.4.0/README.md"
test -f "$ROOT/releases/0.4.0/ASSETS.md"
test -f "$ROOT/releases/0.4.0/manifest.json"
test -d "$ROOT/releases/0.3.0"
for t in ruijie x86_64 orangepi_zero3 orangepi_one orangepi_pc; do
  grep -q "$t" "$WF"
done
grep -q 'BlazeRentalLauncher' "$WF"
grep -q 'esp8266' "$WF"
grep -q 'esp32' "$WF"
grep -q 'BlazeRental-v0.4.0' "$WF"
grep -q '"release": "0.4.0"' "$ROOT/releases/0.4.0/manifest.json"
echo "v0.4 build matrix contract passed"
