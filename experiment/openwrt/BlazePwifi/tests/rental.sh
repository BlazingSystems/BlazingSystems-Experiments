#!/bin/sh
set -eu
ROOT="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
T="$(mktemp -d)"; trap 'rm -rf "$T"' EXIT
mkdir -p "$T/bin" "$T/state" "$T/run"
cat > "$T/bin/uci" <<'UCI'
#!/bin/sh
case "$*" in
 *'get blazepwifi.main.durable_sync') echo 0;;
 *'get blazepwifi.main.rental_seconds_per_pulse') echo 600;;
 *) exit 1;;
esac
UCI
chmod +x "$T/bin/"*
export PATH="$T/bin:$PATH" BP_STATE="$T/state" BP_RUN="$T/run"
export BP_LIB="$ROOT/openwrt/rootfs/usr/lib/blazepwifi/common.sh"
export BP_AUTH_LIB="$ROOT/openwrt/rootfs/usr/lib/blazepwifi/auth.sh"
export BP_RENTAL_LIB="$ROOT/openwrt/rootfs/usr/lib/blazepwifi/rental.sh"
export BP_RENTAL_POLICY_LIB="$ROOT/openwrt/rootfs/usr/lib/blazepwifi/rental_policy.sh"
. "$BP_LIB"; . "$BP_AUTH_LIB"; . "$BP_RENTAL_LIB"
bp_rental_init

TOKEN="$(bp_rental_enroll_create 'Phone 01' 600)"
EID="${TOKEN%%.*}"
N=abcDEF123
SIG="$(bp_rental_hmac "$TOKEN" "enroll|$N|$TOKEN")"
CGI="$ROOT/openwrt/rootfs/www/blazepwifi/cgi-bin/rental"
OUT="$(printf 'action=enroll&enroll_id=%s&nonce=%s&sig=%s' "$EID" "$N" "$SIG" | REQUEST_METHOD=POST sh "$CGI")"
echo "$OUT" | grep -q '"ok":true'
DID="$(printf '%s' "$OUT" | sed -n 's/.*"device_id":"\([^"]*\)".*/\1/p')"
DSEC="$(printf '%s' "$OUT" | sed -n 's/.*"device_secret":"\([^"]*\)".*/\1/p')"
[ "${#DID}" -eq 24 ]
[ "${#DSEC}" -eq 48 ]

# A lost response must be retry-safe: the exact same authenticated request
# nonce returns the same permanent identity rather than burning the one-time QR.
OUT2="$(printf 'action=enroll&enroll_id=%s&nonce=%s&sig=%s' "$EID" "$N" "$SIG" | REQUEST_METHOD=POST sh "$CGI")"
echo "$OUT2" | grep -q '"ok":true'
echo "$OUT2" | grep -q '"reused":true'
DID2="$(printf '%s' "$OUT2" | sed -n 's/.*"device_id":"\([^"]*\)".*/\1/p')"
DSEC2="$(printf '%s' "$OUT2" | sed -n 's/.*"device_secret":"\([^"]*\)".*/\1/p')"
[ "$DID2" = "$DID" ]
[ "$DSEC2" = "$DSEC" ]

# The identity response itself is authenticated by the original one-time token.
SERVER_MS="$(printf '%s' "$OUT" | sed -n 's/.*"server_time_ms":\([0-9]*\).*/\1/p')"
LEASE_MS="$(printf '%s' "$OUT" | sed -n 's/.*"lease_until_ms":\([0-9]*\).*/\1/p')"
ENROLL_SIG="$(printf '%s' "$OUT" | sed -n 's/.*"enroll_sig":"\([^"]*\)".*/\1/p')"
[ -n "$SERVER_MS" ] && [ -n "$LEASE_MS" ] && [ -n "$ENROLL_SIG" ]
EXPECTED_ENROLL_SIG="$(bp_rental_hmac "$TOKEN" "enroll_response|$N|$DID|$DSEC|$SERVER_MS|$LEASE_MS|false")"
[ "$ENROLL_SIG" = "$EXPECTED_ENROLL_SIG" ]

# A different request nonce cannot steal an already redeemed enrollment.
N_BAD=otherNonce123
SIG_BAD="$(bp_rental_hmac "$TOKEN" "enroll|$N_BAD|$TOKEN")"
OUT_BAD="$(printf 'action=enroll&enroll_id=%s&nonce=%s&sig=%s' "$EID" "$N_BAD" "$SIG_BAD" | REQUEST_METHOD=POST sh "$CGI")"
echo "$OUT_BAD" | grep -q 'enrollment already claimed'

bp_rental_policy_ensure "$DID"
bp_rental_admin_password_set "$DID" 'admin-strong-123'
bp_rental_policy_set "$DID" 'com.android.chrome,com.example.game' 'vendo-02'
bp_rental_inventory_write "$DID" 'com.android.chrome,com.example.game,com.example.other'
bp_rental_device_write "$DID" "$DSEC" 2000003600 'Phone 01' 2000000000

N2=stat123
SIG2="$(bp_rental_hmac "$DSEC" "status|$N2|$DSEC")"
OUT="$(printf 'action=status&device_id=%s&nonce=%s&sig=%s&inventory=com.android.chrome%%2Ccom.example.game' "$DID" "$N2" "$SIG2" | REQUEST_METHOD=POST sh "$CGI")"
echo "$OUT" | grep -q '"ok":true'
echo "$OUT" | grep -q '"allowed_packages":"com.android.chrome,com.example.game"'
echo "$OUT" | grep -q '"preferred_vendo":"vendo-02"'
echo "$OUT" | grep -q '"admin_salt":"[0-9a-f]'
echo "$OUT" | grep -q '"policy_sig":"[0-9a-f]'

OUT_USED="$(printf 'action=enroll&enroll_id=%s&nonce=%s&sig=%s' "$EID" "$N" "$SIG" | REQUEST_METHOD=POST sh "$CGI")"
echo "$OUT_USED" | grep -q 'enrollment invalid or used'

R1="$(bp_rental_apply_coin "$DID" vendo-02 aabbccdd 11223344 2)"
echo "$R1" | grep -q '^credited'
LEASE="$(printf '%s' "$R1" | cut -f2)"
[ "$LEASE" -eq 2000004800 ]

R2="$(bp_rental_apply_coin "$DID" vendo-02 aabbccdd 11223344 2)"
echo "$R2" | grep -q '^duplicate'
[ "$(printf '%s' "$R2" | cut -f2)" -eq "$LEASE" ]

LIST="$(bp_rental_list_json)"
printf '%s' "$LIST" | grep -q '"admin_password_set":true'
printf '%s' "$LIST" | grep -q '"preferred_vendo":"vendo-02"'
printf '%s' "$LIST" | grep -q '"inventory":"com.android.chrome,com.example.game"'

# An expired rental must still be able to synchronize so it can receive a new
# lease later. The server reports lease_until_ms == server_time_ms while
# retaining the expired authoritative lease in state.
bp_rental_device_write "$DID" "$DSEC" 1 'Phone 01' 1
N3=expired123
SIG3="$(bp_rental_hmac "$DSEC" "status|$N3|$DSEC")"
OUT3="$(printf 'action=status&device_id=%s&nonce=%s&sig=%s' "$DID" "$N3" "$SIG3" | REQUEST_METHOD=POST sh "$CGI")"
echo "$OUT3" | grep -q '"ok":true'
S3="$(printf '%s' "$OUT3" | sed -n 's/.*"server_time_ms":\([0-9]*\).*/\1/p')"
L3="$(printf '%s' "$OUT3" | sed -n 's/.*"lease_until_ms":\([0-9]*\).*/\1/p')"
[ -n "$S3" ] && [ "$L3" = "$S3" ]
[ "$(printf '%s' "$(bp_rental_device_line "$DID")" | cut -f3)" -eq 1 ]

# Operator helpers used by the R281 rental deployment profile.
bp_rental_device_rename "$DID" 'Owner Test Phone'
printf '%s' "$(bp_rental_device_line "$DID")" | grep -q 'Owner Test Phone'
ADDED="$(bp_rental_lease_add "$DID" 120)"
[ "$ADDED" -gt "$(bp_now)" ]
EXPIRED="$(bp_rental_lease_expire "$DID")"
[ "$EXPIRED" -le "$(bp_now)" ]
EVENTS="$(bp_rental_events_json 16)"
printf '%s' "$EVENTS" | grep -q '"kind":"rename"'
printf '%s' "$EVENTS" | grep -q '"kind":"lease_add"'
printf '%s' "$EVENTS" | grep -q '"kind":"expire"'

echo "BlazeRental production server checks passed"
