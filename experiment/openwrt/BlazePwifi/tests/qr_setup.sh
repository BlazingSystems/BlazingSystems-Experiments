#!/bin/sh
set -eu
ROOT="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
T="$ROOT/tools/BlazeRental-QR-Setup.template.html"
B="$ROOT/tools/build-rental-qr-tool.py"
Q="$ROOT/ui/vendor/qrcode/qrcode.js"
[ -f "$T" ] && [ -f "$B" ] && [ -f "$Q" ]
grep -q 'PROVISIONING_DEVICE_ADMIN_COMPONENT_NAME' "$T"
grep -q 'PROVISIONING_DEVICE_ADMIN_PACKAGE_CHECKSUM' "$T"
grep -q 'PROVISIONING_ADMIN_EXTRAS_BUNDLE' "$T"
grep -q 'PROVISIONING_DEVICE_ADMIN_MINIMUM_VERSION_CODE' "$T"
grep -q 'blazerental.provisioning.v2' "$T"
grep -q '__APK_VERSION_CODE__' "$T"
grep -q 'PROVISIONING_WIFI_SSID' "$T"
grep -q '__APK_CHECKSUM__' "$T"
grep -q '__QRCODE_JS__' "$T"
echo "BlazeRental PC QR tool source checks passed"

grep -q -- '--version-code' "$ROOT/tools/make-provisioning.py"
grep -q 'blazerental.provisioning.v2' "$ROOT/tools/make-provisioning.py"

grep -q 'urlsafe_b64encode' "$ROOT/tools/make-provisioning.py"
! grep -q 'rstrip' "$ROOT/tools/make-provisioning.py"
grep -q 'Device Provisioning QR' "$T"

grep -q 'server_cert_sha256' "$T"
grep -q 'server-cert-sha256' "$ROOT/tools/make-provisioning.py"
grep -q 'HTTPS Rental Server URL' "$T"
grep -q 'server_cert_sha256' "$ROOT/tools/make-provisioning.py"
! grep -q 'rstrip' "$B"
