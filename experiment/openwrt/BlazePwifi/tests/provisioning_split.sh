#!/bin/sh
set -eu
ROOT="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
ADMIN="$ROOT/openwrt/rootfs/www/blazepwifi/cgi-bin/admin"
HTML="$ROOT/profiles/standalone-rental/openwrt/rental-standalone.html"
META="$ROOT/openwrt/rootfs/usr/share/blazepwifi/rental-provisioning.env"
LAUNCHER="$ROOT/android/BlazeRentalLauncher"
MANIFEST="$LAUNCHER/AndroidManifest.xml"
SRC="$LAUNCHER/src/com/blazesystems/blazerental"

grep -q 'rental_standard_qr' "$ADMIN"
grep -q 'rental_provisioning_status' "$ADMIN"
grep -q 'rental_provisioning_qr' "$ADMIN"
grep -q 'blazerental.enrollment.v1' "$ADMIN"
grep -q 'blazerental.provisioning.v1' "$ADMIN"
grep -q 'PROVISIONING_DEVICE_ADMIN_COMPONENT_NAME' "$ADMIN"
grep -q 'PROVISIONING_DEVICE_ADMIN_PACKAGE_DOWNLOAD_LOCATION' "$ADMIN"
grep -q 'PROVISIONING_DEVICE_ADMIN_PACKAGE_CHECKSUM' "$ADMIN"
grep -q 'PROVISIONING_DEVICE_ADMIN_MINIMUM_VERSION_CODE' "$ADMIN"

STANDARD="$(sed -n '/bp_admin_standard_qr_payload()/,/^}/p' "$ADMIN")"
! printf '%s' "$STANDARD" | grep -q 'PROVISIONING_DEVICE_ADMIN'

grep -q 'Standard Enrollment QR' "$HTML"
grep -q 'Device Provisioning QR' "$HTML"
grep -q "api('rental_standard_qr'" "$HTML"
grep -q "api('rental_provisioning_qr'" "$HTML"
grep -q "api('rental_provisioning_status'" "$HTML"
grep -q 'renderQr(j.qr_payload,4)' "$HTML"

grep -q 'android.app.action.GET_PROVISIONING_MODE' "$MANIFEST"
grep -q 'android.app.action.ADMIN_POLICY_COMPLIANCE' "$MANIFEST"
grep -q 'android.app.action.PROVISIONING_SUCCESSFUL' "$MANIFEST"
test -s "$SRC/BlazeProvisioningContract.java"
test -s "$SRC/BlazeProvisioningModeActivity.java"
test -s "$SRC/BlazeProvisioningComplianceActivity.java"
grep -q 'MODE_FULLY_MANAGED_DEVICE = 1' "$SRC/BlazeProvisioningContract.java"
grep -q 'blazerental.provisioning.v1' "$SRC/BlazeProvisioningContract.java"
grep -q 'device_owner_provisioning' "$SRC/RentalLeaseStore.java"
grep -q 'standard_manual' "$SRC/RentalLeaseStore.java"
grep -q 'This is a Device Provisioning QR' "$SRC/QrEnrollmentScannerActivity.java"
grep -q 'Manual first-run administrator setup is disabled' "$SRC/BlazeAdminActivity.java"

test -f "$META"
grep -q '^READY=0$' "$META"
grep -q '^APK_URL=$' "$META"
grep -q '^APK_CHECKSUM=$' "$META"

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT HUP INT TERM
printf 'dummy-apk-bytes-for-provisioning-contract' > "$TMP/app.apk"
python3 "$ROOT/tools/make-provisioning.py" \
  --apk "$TMP/app.apk" \
  --apk-url 'https://example.invalid/BlazeRental.apk' \
  --server-url 'http://192.168.1.1' \
  --enrollment-token '0123456789ab.0123456789abcdef0123456789abcdef' \
  --device-name 'Audit phone' \
  --version-code 50203 \
  --out "$TMP/provisioning.json"
python3 - "$TMP/provisioning.json" <<'PY'
import json,sys
p=json.load(open(sys.argv[1],encoding="utf-8"))
assert p["android.app.extra.PROVISIONING_DEVICE_ADMIN_COMPONENT_NAME"]=="com.blazesystems.blazerental/.BlazeDeviceAdminReceiver"
assert p["android.app.extra.PROVISIONING_DEVICE_ADMIN_MINIMUM_VERSION_CODE"]==50203
assert len(p["android.app.extra.PROVISIONING_DEVICE_ADMIN_PACKAGE_CHECKSUM"])==43
x=p["android.app.extra.PROVISIONING_ADMIN_EXTRAS_BUNDLE"]
assert x["blaze_schema"]=="blazerental.provisioning.v1"
assert x["server_url"]=="http://192.168.1.1"
assert x["enrollment_token"].startswith("0123456789ab.")
PY

# Runtime regression: a one-time enrollment record must have exactly one
# successful claimant even when two processes race it.
STATE="$TMP/state"
RUN="$TMP/run"
mkdir -p "$STATE" "$RUN"
EID=0123456789ab
printf '%s\t%s\t%s\t%s\n' "$EID" \
  0123456789abcdef0123456789abcdef0123 \
  4102444800 "Race phone" > "$STATE/rental-enroll.tsv"
: > "$TMP/claims"

cat > "$TMP/claim.sh" <<'EOF'
#!/bin/sh
set -eu
STATE="$1"; RUN="$2"; ROOT="$3"; EID="$4"; OUT="$5"
BP_STATE="$STATE"; BP_RUN="$RUN"; export BP_STATE BP_RUN
. "$ROOT/openwrt/rootfs/usr/lib/blazepwifi/common.sh"
. "$ROOT/openwrt/rootfs/usr/lib/blazepwifi/rental.sh"
bp_rental_init
bp_rental_enroll_lock || exit 3
line="$(bp_rental_enroll_lookup "$EID")"
if [ -n "$line" ]; then
  sleep 1
  bp_rental_enroll_consume "$EID"
  printf 'claimed\n' >> "$OUT"
fi
bp_rental_enroll_unlock
EOF
chmod +x "$TMP/claim.sh"

"$TMP/claim.sh" "$STATE" "$RUN" "$ROOT" "$EID" "$TMP/claims" &
P1=$!
"$TMP/claim.sh" "$STATE" "$RUN" "$ROOT" "$EID" "$TMP/claims" &
P2=$!
wait "$P1"
wait "$P2"
[ "$(wc -l < "$TMP/claims" | tr -d ' ')" = 1 ]
! grep -q "^$EID$(printf '\t')" "$STATE/rental-enroll.tsv"

echo "BlazeRental provisioning/enrollment split audit passed"
