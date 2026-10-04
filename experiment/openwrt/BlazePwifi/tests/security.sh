#!/bin/sh
set -eu
ROOT="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
T="$(mktemp -d)"; trap 'rm -rf "$T"' EXIT
mkdir -p "$T/bin" "$T/state" "$T/run"

cat > "$T/bin/uci" <<'UCI'
#!/bin/sh
case "$*" in
  *'get blazepwifi.main.admin_port') echo 8443;;
  *'get blazepwifi.main.auth_max_attempts') echo 5;;
  *'get blazepwifi.main.auth_window_seconds') echo 300;;
  *'get blazepwifi.main.auth_lock_seconds') echo 900;;
  *'get blazepwifi.main.auth_idle_seconds') echo 900;;
  *'get blazepwifi.main.auth_absolute_seconds') echo 28800;;
  *'get blazepwifi.main.auth_kdf_rounds') echo 8;;
  *'get blazepwifi.main.auth_bind_ip') echo 1;;
  *'get blazepwifi.main.durable_sync') echo 0;;
  *) exit 1;;
esac
UCI
chmod +x "$T/bin/uci"

# Keep this test deterministic and representative of constrained OpenWrt builds
# where the optional openssl CLI is not installed.
cat > "$T/bin/openssl" <<'OPENSSL'
#!/bin/sh
exit 1
OPENSSL
chmod +x "$T/bin/openssl"
# deterministic auth backend
export PATH="$T/bin:$PATH"
export BP_STATE="$T/state" BP_RUN="$T/run"
export BP_LIB="$ROOT/openwrt/rootfs/usr/lib/blazepwifi/common.sh"
export BP_AUTH_LIB="$ROOT/openwrt/rootfs/usr/lib/blazepwifi/auth.sh"
export BP_CONFIG_LIB="$ROOT/openwrt/rootfs/usr/lib/blazepwifi/config.sh"
export BP_RENTAL_LIB="$ROOT/openwrt/rootfs/usr/lib/blazepwifi/rental.sh"
export SERVER_PORT=8443 REMOTE_ADDR=10.0.0.9 BP_AUTH_NOW=2000000000

AUTH="$ROOT/openwrt/rootfs/usr/lib/blazepwifi/auth.sh"
LOGIN="$ROOT/openwrt/rootfs/www/blazepwifi/cgi-bin/admin-login"
SESSION="$ROOT/openwrt/rootfs/www/blazepwifi/cgi-bin/admin-session"
LOGOUT="$ROOT/openwrt/rootfs/www/blazepwifi/cgi-bin/admin-logout"
ADMIN="$ROOT/openwrt/rootfs/www/blazepwifi/cgi-bin/admin"

[ -x "$AUTH" ] || { echo "missing executable auth.sh" >&2; exit 1; }
for x in "$LOGIN" "$SESSION" "$LOGOUT" "$ADMIN"; do
  [ -x "$x" ] || { echo "missing executable admin endpoint: $x" >&2; exit 1; }
done

echo "security: provision admin"
sh "$AUTH" --set-password admin admin 'Correct-Horse-123!'

echo "security: lockout"
i=1
while [ "$i" -le 5 ]; do
  OUT="$(printf 'username=admin&password=wrong-%s' "$i" | REQUEST_METHOD=POST sh "$LOGIN")"
  CLASS="$(printf '%s' "$OUT" | sed -n 's/.*"error":"\([^"]*\)".*/\1/p')"
  echo "security: attempt $i => ${CLASS:-no-error-class}"
  [ -f "$T/run/auth-failures.tsv" ] && sed 's/^/security: counter /' "$T/run/auth-failures.tsv" || true
  echo "$OUT" | grep -Eq 'invalid credentials|locked'
  i=$((i+1))
done
OUT="$(printf 'username=admin&password=Correct-Horse-123!' | REQUEST_METHOD=POST sh "$LOGIN")"
CLASS="$(printf '%s' "$OUT" | sed -n 's/.*"error":"\([^"]*\)".*/\1/p')"
echo "security: correct-during-lock => ${CLASS:-no-error-class}"
[ -f "$T/run/auth-failures.tsv" ] && sed 's/^/security: final-counter /' "$T/run/auth-failures.tsv" || true
echo "$OUT" | grep -q 'locked'

echo "security: post-lock login"
export BP_AUTH_NOW=2000000901
OUT="$(printf 'username=admin&password=Correct-Horse-123!' | REQUEST_METHOD=POST sh "$LOGIN")"
echo "$OUT" | grep -q '"ok":true'
echo "$OUT" | grep -q 'Secure'
echo "$OUT" | grep -q 'HttpOnly'
echo "$OUT" | grep -q 'SameSite=Strict'
COOKIE="$(printf '%s\n' "$OUT" | sed -n 's/^Set-Cookie: \(blaze_admin=[^;]*\).*/\1/p' | tr -d '\r')"
CSRF="$(printf '%s' "$OUT" | sed -n 's/.*"csrf":"\([^"]*\)".*/\1/p')"
[ -n "$COOKIE" ] && [ -n "$CSRF" ]
COOKIE_TOKEN="${COOKIE#blaze_admin=}"
[ "${#COOKIE_TOKEN}" -eq 64 ]
[ "${#CSRF}" -eq 48 ]
case "$COOKIE_TOKEN" in *[!0-9a-f]*) echo "non-hex admin session token" >&2; exit 1;; esac
case "$CSRF" in *[!0-9a-f]*) echo "non-hex csrf token" >&2; exit 1;; esac

echo "security: session lookup"
awk -F '\t' 'NF{printf "security: stored-session user=%s role=%s created=%s last=%s absolute=%s ip=%s must=%s token_len=%s\n",$2,$3,$5,$6,$7,$8,$9,length($1)}' "$T/run/admin-sessions.tsv" || true
COOKIE_TOKEN="${COOKIE#blaze_admin=}"
COOKIE_FP="$(printf '%s' "$COOKIE_TOKEN" | sha256sum | cut -c1-12)"
STORED_FP="$(awk -F '\t' 'NF{print $1; exit}' "$T/run/admin-sessions.tsv" | sha256sum | cut -c1-12)"
echo "security: cookie token_len=${#COOKIE_TOKEN} fp=$COOKIE_FP stored_fp=$STORED_FP"
OUT="$(HTTP_COOKIE="$COOKIE" REQUEST_METHOD=GET sh "$SESSION")"
SCLASS="$(printf '%s' "$OUT" | sed -n 's/.*"error":"\([^"]*\)".*/\1/p')"
SUSER="$(printf '%s' "$OUT" | sed -n 's/.*"username":"\([^"]*\)".*/\1/p')"
SROLE="$(printf '%s' "$OUT" | sed -n 's/.*"role":"\([^"]*\)".*/\1/p')"
echo "security: session-result => ${SCLASS:-ok-or-unclassified} user=${SUSER:-missing} role=${SROLE:-missing}"
echo "$OUT" | grep -q '"username":"admin"'
echo "$OUT" | grep -q '"role":"admin"'

echo "security: admin status and csrf"
OUT="$(printf 'action=status' | HTTP_COOKIE="$COOKIE" HTTP_X_BLAZE_CSRF="$CSRF" REQUEST_METHOD=POST sh "$ADMIN")"
echo "$OUT" | grep -q '"ok":true'
OUT="$(printf 'action=voucher_create&cents=100' | HTTP_COOKIE="$COOKIE" HTTP_X_BLAZE_CSRF=wrong REQUEST_METHOD=POST sh "$ADMIN")"
echo "$OUT" | grep -q 'csrf'

echo "security: viewer role"
sh "$AUTH" --set-password viewer viewer 'Viewer-Pass-123!'
VOUT="$(printf 'username=viewer&password=Viewer-Pass-123!' | REQUEST_METHOD=POST sh "$LOGIN")"
VCOOKIE="$(printf '%s\n' "$VOUT" | sed -n 's/^Set-Cookie: \(blaze_admin=[^;]*\).*/\1/p' | tr -d '\r')"
VCSRF="$(printf '%s' "$VOUT" | sed -n 's/.*"csrf":"\([^"]*\)".*/\1/p')"
OUT="$(printf 'action=voucher_create&cents=100' | HTTP_COOKIE="$VCOOKIE" HTTP_X_BLAZE_CSRF="$VCSRF" REQUEST_METHOD=POST sh "$ADMIN")"
echo "$OUT" | grep -q 'insufficient role'

echo "security: logout"
OUT="$(printf 'csrf=%s' "$CSRF" | HTTP_COOKIE="$COOKIE" HTTP_X_BLAZE_CSRF="$CSRF" REQUEST_METHOD=POST sh "$LOGOUT")"
echo "$OUT" | grep -q '"ok":true'
OUT="$(HTTP_COOKIE="$COOKIE" REQUEST_METHOD=GET sh "$SESSION")"
echo "$OUT" | grep -q 'unauthorized'

echo "security: idle expiry"
OUT="$(printf 'username=admin&password=Correct-Horse-123!' | REQUEST_METHOD=POST sh "$LOGIN")"
COOKIE2="$(printf '%s\n' "$OUT" | sed -n 's/^Set-Cookie: \(blaze_admin=[^;]*\).*/\1/p' | tr -d '\r')"
export BP_AUTH_NOW=2000001802
OUT="$(HTTP_COOKIE="$COOKIE2" REQUEST_METHOD=GET sh "$SESSION")"
echo "$OUT" | grep -q 'unauthorized'

grep -q 'login_failure' "$T/state/audit.tsv"
grep -q 'lockout' "$T/state/audit.tsv"
grep -q 'login_success' "$T/state/audit.tsv"

echo "BlazePwifi v0.3 admin security checks passed"
