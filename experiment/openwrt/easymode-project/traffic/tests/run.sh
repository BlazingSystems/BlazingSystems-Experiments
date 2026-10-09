#!/bin/sh
set -eu
ucode traffic/tests/accounting.uc
node --test traffic/tests/ui-model.test.mjs
node --check traffic/root/www/traffic/app.js
for f in traffic/root/usr/libexec/* traffic/root/etc/init.d/* traffic/root/etc/uci-defaults/*; do sh -n "$f"; done
python3 traffic/tools/build.py --check
