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

OUT2="$(printf 'action=enroll&enroll_id=%s&nonce=%s&sig=%s' "$EID" "$N" "$SIG" | REQUEST_METHOD=POST sh "$CGI")"
echo "$OUT2" | grep -q 'invalid or used'

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
echo "$OUT" | grep -q '"coin_window_expires_ms":0'
echo "$OUT" | grep -q '"coin_window_sig":"[0-9a-f]'

# Opening a rental coin window is authenticated, server-timed and recoverable
# through status. The returned reservation state has its own HMAC.
NC=coinopen123
SIGC="$(bp_rental_hmac "$DSEC" "coin_start|$NC|$DSEC")"
COIN="$(printf 'action=coin_start&device_id=%s&nonce=%s&sig=%s' "$DID" "$NC" "$SIGC" | REQUEST_METHOD=POST sh "$CGI")"
echo "$COIN" | grep -q '"ok":true'
echo "$COIN" | grep -q '"vendo":"vendo-02"'
CS="$(printf '%s' "$COIN" | sed -n 's/.*"server_time_ms":\([0-9]*\).*/\1/p')"
CE="$(printf '%s' "$COIN" | sed -n 's/.*"expires_ms":\([0-9]*\).*/\1/p')"
CG="$(printf '%s' "$COIN" | sed -n 's/.*"coin_window_sig":"\([^"]*\)".*/\1/p')"
[ -n "$CS" ] && [ -n "$CE" ] && [ "$CE" -gt "$CS" ]
[ "$CG" = "$(bp_rental_hmac "$DSEC" "coin_window|$DID|$CS|$CE|vendo-02")" ]
[ -f "$BP_TARGET_DIR/vendo-02.tsv" ]
[ "$(cut -f6 "$BP_TARGET_DIR/vendo-02.tsv")" = rental ]

NS=coinstatus123
SIGS="$(bp_rental_hmac "$DSEC" "status|$NS|$DSEC")"
COINSTATUS="$(printf 'action=status&device_id=%s&nonce=%s&sig=%s' "$DID" "$NS" "$SIGS" | REQUEST_METHOD=POST sh "$CGI")"
SS="$(printf '%s' "$COINSTATUS" | sed -n 's/.*"server_time_ms":\([0-9]*\).*/\1/p')"
SE="$(printf '%s' "$COINSTATUS" | sed -n 's/.*"coin_window_expires_ms":\([0-9]*\).*/\1/p')"
SV="$(printf '%s' "$COINSTATUS" | sed -n 's/.*"coin_window_vendo":"\([^"]*\)".*/\1/p')"
SG="$(printf '%s' "$COINSTATUS" | sed -n 's/.*"coin_window_sig":"\([^"]*\)".*/\1/p')"
[ "$SE" = "$CE" ] && [ "$SV" = vendo-02 ]
[ "$SG" = "$(bp_rental_hmac "$DSEC" "coin_window|$DID|$SS|$SE|$SV")" ]

NX=coinstop123
SIGX="$(bp_rental_hmac "$DSEC" "coin_stop|$NX|$DSEC")"
STOP="$(printf 'action=coin_stop&device_id=%s&nonce=%s&sig=%s' "$DID" "$NX" "$SIGX" | REQUEST_METHOD=POST sh "$CGI")"
echo "$STOP" | grep -q '"ok":true'
XS="$(printf '%s' "$STOP" | sed -n 's/.*"server_time_ms":\([0-9]*\).*/\1/p')"
XG="$(printf '%s' "$STOP" | sed -n 's/.*"coin_window_sig":"\([^"]*\)".*/\1/p')"
[ "$XG" = "$(bp_rental_hmac "$DSEC" "coin_window|$DID|$XS|0|")" ]
[ ! -f "$BP_TARGET_DIR/vendo-02.tsv" ]

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
