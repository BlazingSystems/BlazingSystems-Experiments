#!/bin/sh
set -eu
ROOT="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
T="$(mktemp -d)"; trap 'rm -rf "$T"' EXIT
mkdir -p "$T/bin" "$T/state" "$T/run"
cat > "$T/bin/uci" <<'UCI'
#!/bin/sh
case "$*" in
 *'get blazepwifi.main.durable_sync') echo 0;;
 *) exit 1;;
esac
UCI
cat > "$T/bin/openssl" <<'OPENSSL'
#!/bin/sh
exit 1
OPENSSL
chmod +x "$T/bin/"*
export PATH="$T/bin:$PATH" BP_STATE="$T/state" BP_RUN="$T/run"
export BP_LIB="$ROOT/openwrt/rootfs/usr/lib/blazepwifi/common.sh"
export BP_AUTH_LIB="$ROOT/openwrt/rootfs/usr/lib/blazepwifi/auth.sh"
export BP_RENTAL_LIB="$ROOT/openwrt/rootfs/usr/lib/blazepwifi/rental.sh"
. "$BP_LIB"; . "$BP_AUTH_LIB"; . "$BP_RENTAL_LIB"
bp_rental_init
TOKEN="$(bp_rental_enroll_create 'Phone 01' 600)"
EID="${TOKEN%%.*}"
N=abcDEF123_-x
SIG="$(bp_rental_hmac "$TOKEN" "enroll|$N|$TOKEN")"
CGI="$ROOT/openwrt/rootfs/www/blazepwifi/cgi-bin/rental"
OUT="$(printf 'action=enroll&enroll_id=%s&nonce=%s&sig=%s&device=test' "$EID" "$N" "$SIG" | REQUEST_METHOD=POST sh "$CGI")"
echo "$OUT" | grep -q '"ok":true'
DID="$(printf '%s' "$OUT" | sed -n 's/.*"device_id":"\([^"]*\)".*/\1/p')"
DSEC="$(printf '%s' "$OUT" | sed -n 's/.*"device_secret":"\([^"]*\)".*/\1/p')"
[ "${#DID}" -eq 24 ] && [ "${#DSEC}" -eq 48 ]
OUT2="$(printf 'action=enroll&enroll_id=%s&nonce=%s&sig=%s' "$EID" "$N" "$SIG" | REQUEST_METHOD=POST sh "$CGI")"
echo "$OUT2" | grep -q 'invalid or used'

bp_rental_device_write "$DID" "$DSEC" 2000003600 'Phone 01' 2000000000
export BP_RENTAL_NOW=2000000000
N2=stat123
SIG2="$(bp_rental_hmac "$DSEC" "status|$N2|$DSEC")"
OUT="$(printf 'action=status&device_id=%s&nonce=%s&sig=%s' "$DID" "$N2" "$SIG2" | REQUEST_METHOD=POST sh "$CGI")"
echo "$OUT" | grep -q '"ok":true'
echo "$OUT" | grep -q '"lease_until_ms"'
echo "BlazeRental server protocol checks passed"
