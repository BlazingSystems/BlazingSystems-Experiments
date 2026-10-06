#!/bin/sh
set -eu

ROOT="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
ADMIN="$ROOT/openwrt/rootfs/www/blazepwifi/cgi-bin/admin"
HTML="$ROOT/profiles/standalone-rental/openwrt/rental-standalone.html"
INSTALL="$ROOT/profiles/standalone-rental/openwrt/install.sh"
PROFILE="$ROOT/profiles/standalone-rental"
ANDROID="$ROOT/android/BlazeRentalLauncher"
MANIFEST="$ANDROID/AndroidManifest.xml"
SRC="$ANDROID/src/com/blazesystems/blazerental"
IDENTITY="$ROOT/../../../.github/blazerental-v052-production-identity.json"

sh -n "$ADMIN"
sh -n "$INSTALL"

# Separate public contracts: installed-app binding is not Android provisioning.
grep -Fq 'rental_binding_qr' "$ADMIN"
grep -Fq 'rental_provisioning_status' "$ADMIN"
grep -Fq 'rental_provisioning_qr' "$ADMIN"
grep -Fq 'blazerental.enrollment.v1' "$ADMIN"
grep -Fq 'blazerental.provisioning.v1' "$ADMIN"
grep -Fq 'Standard Enrollment QR' "$HTML"
grep -Fq 'Device Provisioning QR' "$HTML"
grep -Fq "rental_binding_qr" "$HTML"
grep -Fq "rental_provisioning_qr" "$HTML"
! grep -Fq 'createEnrollment(' "$HTML"

# Provisioning must use HTTPS and an exact local certificate pin.
grep -Fq 'Device Owner provisioning server URL must use HTTPS' "$ADMIN"
grep -Fq 'Device Owner provisioning requires the local pinned admin certificate' "$ADMIN"
grep -Fq 'server_cert_sha256' "$ADMIN"
grep -Fq 'server_cert_sha256' "$SRC/BlazeProvisioningContract.java"
grep -Fq 'server_cert_sha256' "$SRC/RentalLeaseStore.java"
grep -Fq 'isValidValues' "$SRC/BlazeProvisioningContract.java"
test -s "$ANDROID/tests/unit/com/blazesystems/blazerental/BlazeProvisioningContractTest.java"

# Source tree fails closed. Exact provisioning metadata is injected only into a
# built release bundle; it is not a mutable checked-in default.
test ! -e "$PROFILE/openwrt/rental-provisioning.tsv"
grep -Fq '$SELF/rental-provisioning.tsv' "$INSTALL"
grep -Fq '/etc/blazepwifi/state/rental-provisioning.tsv' "$INSTALL"
grep -Fq 'BP_RENTAL_PROVISIONING_FILE=' "$ADMIN"
! grep -Fq 'rental-provisioning.env' "$INSTALL"
! grep -Fq 'rental-provisioning.env' "$ADMIN"

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT HUP INT TERM

# Execute the real payload builders using a benign JSON escaper because every
# test value here is restricted ASCII without characters requiring escaping.
bp_json_escape(){ printf '%s' "$1"; }
eval "$(sed -n '/^bp_admin_binding_payload()/,/^}/p' "$ADMIN")"
eval "$(sed -n '/^bp_admin_sha256_b64url()/,/^}/p' "$ADMIN")"
eval "$(sed -n '/^bp_admin_provisioning_line()/,/^}/p' "$ADMIN")"
eval "$(sed -n '/^bp_admin_provisioning_read()/,/^}/p' "$ADMIN")"
eval "$(sed -n '/^bp_admin_provisioning_payload()/,/^}/p' "$ADMIN")"

TOKEN='0123456789ab.0123456789abcdef0123456789abcdef'
PIN='0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef'
APK_SHA='d0ad20bed00ea304db9bff45928542fed574070d416ed65b4fbf3d8ba23d7102'
APK_CHECKSUM="$(bp_admin_sha256_b64url "$APK_SHA")"
[ "$APK_CHECKSUM" = '0K0gvtAOowTbm_9FkoVC_tV0Bw1BbtZbT789i6I9cQI' ]

BINDING="$(bp_admin_binding_payload 'https://192.168.1.1' "$TOKEN" 'Audit phone' "$PIN")"
PROVISIONING="$(bp_admin_provisioning_payload \
  'https://192.168.1.1' "$TOKEN" 'Audit phone' \
  'https://example.invalid/BlazeRental.apk' "$APK_CHECKSUM" 50301 "$PIN" \
  '' '' '' false)"
printf '%s' "$BINDING" > "$TMP/binding.json"
printf '%s' "$PROVISIONING" > "$TMP/provisioning.json"

python3 - "$TMP/binding.json" "$TMP/provisioning.json" <<'PY'
import json,sys
binding=json.load(open(sys.argv[1],encoding="utf-8"))
prov=json.load(open(sys.argv[2],encoding="utf-8"))

assert binding["schema"]=="blazerental.enrollment.v1"
assert binding["server_url"].startswith("https://")
assert binding["server_cert_sha256"]
assert not any(k.startswith("android.app.extra.PROVISIONING_") for k in binding)

assert prov["android.app.extra.PROVISIONING_DEVICE_ADMIN_COMPONENT_NAME"]=="com.blazesystems.blazerental/.BlazeDeviceAdminReceiver"
assert prov["android.app.extra.PROVISIONING_DEVICE_ADMIN_PACKAGE_DOWNLOAD_LOCATION"].startswith("https://")
assert len(prov["android.app.extra.PROVISIONING_DEVICE_ADMIN_PACKAGE_CHECKSUM"])==43
assert prov["android.app.extra.PROVISIONING_DEVICE_ADMIN_MINIMUM_VERSION_CODE"]==50301
extras=prov["android.app.extra.PROVISIONING_ADMIN_EXTRAS_BUNDLE"]
assert extras["blaze_schema"]=="blazerental.provisioning.v1"
assert extras["server_url"].startswith("https://")
assert len(extras["server_cert_sha256"])==64
assert extras["enrollment_token"].startswith("0123456789ab.")
PY

# Execute the real provisioning-metadata validator. Missing metadata must
# retain return code 1 so the admin status endpoint can distinguish
# "not installed" from malformed metadata.
BP_RENTAL_PROVISIONING_FILE="$TMP/rental-provisioning.tsv"
export BP_RENTAL_PROVISIONING_FILE
rm -f "$BP_RENTAL_PROVISIONING_FILE"
if bp_admin_provisioning_read; then
  echo "missing provisioning metadata unexpectedly accepted" >&2
  exit 1
else
  missing_rc=$?
fi
[ "$missing_rc" -eq 1 ]
! grep -Fq 'if ! bp_admin_provisioning_read; then' "$ADMIN"
grep -Fq 'if bp_admin_provisioning_read; then' "$ADMIN"

BP_RENTAL_PROVISIONING_FILE="$TMP/rental-provisioning.tsv"
export BP_RENTAL_PROVISIONING_FILE
TEST_SIGNER='abcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcd'
printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\n' \
  '0.5.3-rental-rc.1' 50301 \
  'https://example.invalid/BlazeRental-v0.5.3-rental-rc.1-TEST.apk' \
  "$APK_SHA" test 0 "$TEST_SIGNER" > "$BP_RENTAL_PROVISIONING_FILE"
bp_admin_provisioning_read
[ "$apk_version" = '0.5.3-rental-rc.1' ]
[ "$apk_code" = 50301 ]
[ "$apk_channel" = test ]
[ "$production_ready" = 0 ]
[ "$signer_sha" = "$TEST_SIGNER" ]

# Unsafe or internally inconsistent metadata must fail closed.
printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\n' \
  '0.5.3-rental-rc.1' 50301 'http://example.invalid/app.apk' \
  "$APK_SHA" test 0 "$TEST_SIGNER" > "$BP_RENTAL_PROVISIONING_FILE"
if bp_admin_provisioning_read; then
  echo "HTTP provisioning metadata unexpectedly accepted" >&2
  exit 1
fi
printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\n' \
  '0.5.3-rental-rc.1' 50301 'https://example.invalid/app.apk' \
  "$APK_SHA" production 0 "$TEST_SIGNER" > "$BP_RENTAL_PROVISIONING_FILE"
if bp_admin_provisioning_read; then
  echo "production channel without production_ready unexpectedly accepted" >&2
  exit 1
fi
printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\n' \
  '0.5.3-rental-rc.1' 50301 'https://example.invalid/app.apk' \
  "$APK_SHA" test 0 'bad-signer' > "$BP_RENTAL_PROVISIONING_FILE"
if bp_admin_provisioning_read; then
  echo "invalid signer fingerprint unexpectedly accepted" >&2
  exit 1
fi

# Android integrated provisioning contract and scanner separation.
grep -Fq 'android.app.action.GET_PROVISIONING_MODE' "$MANIFEST"
grep -Fq 'android.app.action.ADMIN_POLICY_COMPLIANCE' "$MANIFEST"
grep -Fq 'android.app.action.PROVISIONING_SUCCESSFUL' "$MANIFEST"
test "$(grep -c 'android.permission.BIND_DEVICE_ADMIN' "$MANIFEST")" -ge 4
grep -Fq 'MODE_FULLY_MANAGED_DEVICE = 1' "$SRC/BlazeProvisioningContract.java"
grep -Fq 'This is a Device Provisioning QR' "$SRC/QrEnrollmentScannerActivity.java"
grep -Fq 'blazerental.enrollment.v1' "$SRC/QrEnrollmentScannerActivity.java"

# The permanent production identity is locked and is not silently substituted
# for this RC's TEST signer.
python3 - "$IDENTITY" <<'PY'
import json,re,sys
x=json.load(open(sys.argv[1],encoding="utf-8"))
assert x["locked"] is True
assert x["package_id"]=="com.blazesystems.blazerental"
fp=re.sub(r"[^0-9A-Fa-f]","",x["sha256_fingerprint"]).lower()
assert len(fp)==64
assert x["signed_apk_sha256"]=="d0ad20bed00ea304db9bff45928542fed574070d416ed65b4fbf3d8ba23d7102"
PY

echo "BlazeRental v0.5.3 Rental RC1 provisioning split/runtime contract passed"
