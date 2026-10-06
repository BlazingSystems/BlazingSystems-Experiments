#!/bin/sh
set -eu
ROOT="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
ADMIN="$ROOT/openwrt/rootfs/www/blazepwifi/cgi-bin/admin"
RENTAL_API="$ROOT/openwrt/rootfs/www/blazepwifi/cgi-bin/rental"
RENTAL_LIB="$ROOT/openwrt/rootfs/usr/lib/blazepwifi/rental.sh"
HTML="$ROOT/profiles/standalone-rental/openwrt/rental-standalone.html"
META="$ROOT/profiles/standalone-rental/openwrt/rental-provisioning.env"
LAUNCHER="$ROOT/android/BlazeRentalLauncher"
MANIFEST="$LAUNCHER/AndroidManifest.xml"
SRC="$LAUNCHER/src/com/blazesystems/blazerental"
LEASE="$SRC/LeaseClient.java"
STORE="$SRC/RentalLeaseStore.java"
CONTRACT="$SRC/BlazeProvisioningContract.java"
SCANNER="$SRC/QrEnrollmentScannerActivity.java"
SERVICE="$SRC/BlazeDeviceAdminService.java"

sh -n "$ADMIN"
sh -n "$RENTAL_API"
sh -n "$RENTAL_LIB"

echo "audit: QR contracts remain separate"
grep -q 'rental_standard_qr' "$ADMIN"
grep -q 'rental_provisioning_status' "$ADMIN"
grep -q 'rental_provisioning_qr' "$ADMIN"
grep -q 'blazerental.enrollment.v1' "$ADMIN"
grep -q 'blazerental.provisioning.v1' "$ADMIN"
STANDARD="$(sed -n '/bp_admin_standard_qr_payload()/,/^}/p' "$ADMIN")"
! printf '%s' "$STANDARD" | grep -q 'PROVISIONING_DEVICE_ADMIN'

grep -q 'Standard Enrollment QR' "$HTML"
grep -q 'Device Provisioning QR' "$HTML"
grep -q "api('rental_standard_qr'" "$HTML"
grep -q "api('rental_provisioning_qr'" "$HTML"
grep -q 'CUSTOM DPC / GMS WARNING' "$HTML"
grep -q 'ack_custom_dpc' "$HTML"
! grep -q 'createEnrollment(' "$HTML"

echo "audit: OpenWrt-generated onboarding uses pinned HTTPS"
grep -q 'bp_admin_cert_sha256()' "$ADMIN"
grep -q 'bp_admin_local_cert_pin()' "$ADMIN"
grep -q 'server_cert_sha256' "$ADMIN"
grep -q 'Standard Enrollment requires the pinned local HTTPS certificate' "$ADMIN"
grep -q 'Device Provisioning server URL must use HTTPS' "$ADMIN"
grep -q 'Device Provisioning requires the pinned local HTTPS certificate' "$ADMIN"
grep -q "location.protocol==='https:'" "$HTML"
! grep -q "return 'http://'+location.hostname" "$HTML"

grep -q 'HttpsURLConnection' "$LEASE"
grep -q 'X509TrustManager' "$LEASE"
grep -q 'BlazePwifi TLS certificate pin mismatch' "$LEASE"
grep -q 'server_cert_sha256' "$STORE"
grep -q 'server_cert_sha256' "$SCANNER"
grep -q '!server.startsWith("https://")' "$CONTRACT"
grep -q '\[0-9a-f\]{64}' "$CONTRACT"

echo "audit: modern Android Device Owner contract"
grep -q 'android.app.action.GET_PROVISIONING_MODE' "$MANIFEST"
grep -q 'android.app.action.ADMIN_POLICY_COMPLIANCE' "$MANIFEST"
grep -q 'android.app.action.PROVISIONING_SUCCESSFUL' "$MANIFEST"
grep -q 'MODE_FULLY_MANAGED_DEVICE = 1' "$CONTRACT"
grep -q 'blazerental.provisioning.v1' "$CONTRACT"
grep -q 'device_owner_provisioning' "$STORE"
grep -q 'standard_manual' "$STORE"
grep -q 'This is a Device Provisioning QR' "$SCANNER"

echo "audit: retry-safe authenticated enrollment"
grep -q 'bp_rental_enroll_mark_redeemed' "$RENTAL_LIB"
grep -q 'bp_rental_enroll_consume_device' "$RENTAL_LIB"
grep -q 'enrollment already claimed' "$RENTAL_API"
grep -q 'enrollment device identity conflict' "$RENTAL_API"
grep -q 'enrollment device verification failed' "$RENTAL_API"
grep -q 'enroll_response|' "$RENTAL_API"
grep -q '"enroll_sig":"%s"' "$RENTAL_API"
grep -q 'enrollment_request_nonce' "$STORE"
grep -q 'public static boolean setDeviceIdentity' "$STORE"
grep -q 'enrollmentRequestNonce(context)' "$LEASE"
grep -q 'response.optString("enroll_sig", "")' "$LEASE"
grep -q 'public static synchronized boolean sync(Context context)' "$LEASE"
grep -q 'syncInFlight.compareAndSet(false, true)' "$SERVICE"

SIG_LINE="$(grep -n 'Hmac.sha256Hex(authSecret, enrollCanonical)' "$LEASE" | head -n1 | cut -d: -f1)"
IDENTITY_LINE="$(grep -n 'RentalLeaseStore.setDeviceIdentity(context, deviceId, newSecret)' "$LEASE" | head -n1 | cut -d: -f1)"
[ -n "$SIG_LINE" ] && [ -n "$IDENTITY_LINE" ] && [ "$SIG_LINE" -lt "$IDENTITY_LINE" ]

# All enrollment TSV writers must use the same global lock domain.
grep -A35 '^bp_rental_enroll_create()' "$RENTAL_LIB" | grep -q 'bp_lock'
! grep -q 'bp_rental_enroll_lock' "$RENTAL_LIB"

echo "audit: fail-closed source-tree provisioning metadata"
test -f "$META"
grep -qx 'READY=0' "$META"
grep -qx 'APK_URL=' "$META"
grep -qx 'APK_CHECKSUM=' "$META"
grep -qx 'GMS_DPC_APPROVED=0' "$META"

echo "audit: offline Device Provisioning JSON generator"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT HUP INT TERM
printf 'dummy-apk-bytes-for-provisioning-contract' > "$TMP/app.apk"
PIN=0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef
TOKEN=0123456789ab.0123456789abcdef0123456789abcdef0123
python3 "$ROOT/tools/make-provisioning.py" \
  --apk "$TMP/app.apk" \
  --apk-url 'https://example.invalid/BlazeRental.apk' \
  --server-url 'https://192.168.1.1' \
  --server-cert-sha256 "$PIN" \
  --enrollment-token "$TOKEN" \
  --device-name 'Audit phone' \
  --version-code 50206 \
  --out "$TMP/provisioning.json"

python3 - "$TMP/provisioning.json" "$TMP/app.apk" "$PIN" "$TOKEN" <<'PY'
import base64,hashlib,json,pathlib,sys
p=json.load(open(sys.argv[1],encoding="utf-8"))
assert p["android.app.extra.PROVISIONING_DEVICE_ADMIN_COMPONENT_NAME"]=="com.blazesystems.blazerental/.BlazeDeviceAdminReceiver"
assert p["android.app.extra.PROVISIONING_DEVICE_ADMIN_MINIMUM_VERSION_CODE"]==50206
checksum=p["android.app.extra.PROVISIONING_DEVICE_ADMIN_PACKAGE_CHECKSUM"]
assert len(checksum)==44 and checksum.endswith("=")
assert base64.urlsafe_b64decode(checksum)==hashlib.sha256(pathlib.Path(sys.argv[2]).read_bytes()).digest()
x=p["android.app.extra.PROVISIONING_ADMIN_EXTRAS_BUNDLE"]
assert x["blaze_schema"]=="blazerental.provisioning.v1"
assert x["server_url"]=="https://192.168.1.1"
assert x["server_cert_sha256"]==sys.argv[3]
assert x["enrollment_token"]==sys.argv[4]
PY

# Generator must reject cleartext provisioning and missing/invalid TLS identity.
if python3 "$ROOT/tools/make-provisioning.py" \
  --apk "$TMP/app.apk" --apk-url 'https://example.invalid/a.apk' \
  --server-url 'http://192.168.1.1' --server-cert-sha256 "$PIN" \
  --enrollment-token "$TOKEN" --version-code 50206 --out "$TMP/bad.json" 2>/dev/null; then
  echo "cleartext Device Provisioning unexpectedly accepted" >&2
  exit 1
fi

echo "audit: release metadata generator"
APK_SHA="$(sha256sum "$TMP/app.apk" | awk '{print $1}')"
APK_CHECKSUM="$(python3 -c 'import base64,hashlib,pathlib,sys; print(base64.urlsafe_b64encode(hashlib.sha256(pathlib.Path(sys.argv[1]).read_bytes()).digest()).decode())' "$TMP/app.apk")"
printf '%s\n' \
  'PACKAGE_NAME=com.blazesystems.blazerental' \
  'APK_VERSION=0.5.2-rental.2-rc.5' \
  'APK_VERSION_CODE=50206' \
  'APK_CHANNEL=test' \
  'PRODUCTION_READY=0' \
  'GMS_DPC_APPROVED=0' \
  "APK_SHA256=$APK_SHA" \
  "APK_CHECKSUM=$APK_CHECKSUM" \
  'SIGNER_CERT_SHA256=0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef' \
  > "$TMP/build-meta.txt"

python3 "$ROOT/profiles/standalone-rental/build/make-release-provisioning-meta.py" \
  --apk "$TMP/app.apk" \
  --metadata "$TMP/build-meta.txt" \
  --tag 'v0.5.2-rental.2-rc.5' \
  --repository 'BlazingSystems/BlazingSystems-Experiments' \
  --out "$TMP/release-meta.env"

grep -qx "APK_SHA256=$APK_SHA" "$TMP/release-meta.env"
grep -qx "APK_CHECKSUM=$APK_CHECKSUM" "$TMP/release-meta.env"
grep -qx 'APK_VERSION=0.5.2-rental.2-rc.5' "$TMP/release-meta.env"
grep -qx 'APK_VERSION_CODE=50206' "$TMP/release-meta.env"
grep -qx 'GMS_DPC_APPROVED=0' "$TMP/release-meta.env"

echo "BlazeRental RC5 provisioning/security audit passed"
