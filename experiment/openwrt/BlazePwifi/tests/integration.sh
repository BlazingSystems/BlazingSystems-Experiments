#!/bin/sh
set -eu
ROOT="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
T="$(mktemp -d)"; trap 'rm -rf "$T"' EXIT
mkdir -p "$T/bin" "$T/state" "$T/run"
cat > "$T/bin/uci" <<'UCI'
#!/bin/sh
# Minimal fixture for BlazePwifi tests.
case "$*" in
  *'get blazepwifi.main.lan_if') echo br-lan;;
  *'get blazepwifi.main.coin_window') echo 120;;
  *'get blazepwifi.main.pulse_value_centavos') echo 100;;
  *'get blazepwifi.main.admin_key') echo adminkey;;
  *'get blazepwifi.main.vendo_key') echo vendokey;;
  *'get blazepwifi.p1.cents') echo 100;;
  *'get blazepwifi.p1.seconds') echo 600;;
  *'get blazepwifi.p1.label') echo 'P1 / 10 minutes';;
  *'show blazepwifi') echo "blazepwifi.p1=rate"; echo "blazepwifi.p1.cents='100'"; echo "blazepwifi.p1.seconds='600'"; echo "blazepwifi.p1.label='P1 / 10 minutes'";;
  *) exit 1;;
esac
UCI
cat > "$T/bin/ip" <<'IP'
#!/bin/sh
echo '10.0.0.2 dev br-lan lladdr aa:bb:cc:dd:ee:ff REACHABLE'
IP
cat > "$T/bin/nft" <<'NFT'
#!/bin/sh
exit 0
NFT
chmod +x "$T/bin/"*
export PATH="$T/bin:$PATH" BP_STATE="$T/state" BP_RUN="$T/run" BP_LIB="$ROOT/openwrt/rootfs/usr/lib/blazepwifi/common.sh" REMOTE_ADDR=10.0.0.2 REQUEST_METHOD=POST
API="$ROOT/openwrt/rootfs/www/blazepwifi/cgi-bin/api"
VENDO="$ROOT/openwrt/rootfs/www/blazepwifi/cgi-bin/vendo"
OUT="$(printf 'action=coin_start' | sh "$API")"; echo "$OUT" | grep -q '"ok":true'
NONCE="$(printf '%s' "$OUT" | sed -n 's/.*"nonce":"\([0-9a-f]*\)".*/\1/p')"; [ -n "$NONCE" ]
REQNONCE=1122334455667788
SIG="$(printf 'vendokey|coin|vendo-01|%s|1|%s|1|vendokey' "$REQNONCE" "$NONCE" | sha256sum | awk '{print $1}')"
OUT="$(printf 'action=coin&id=vendo-01&nonce=%s&pulses=1&target=%s&seq=1&sig=%s' "$REQNONCE" "$NONCE" "$SIG" | sh "$VENDO")"; echo "$OUT" | grep -q '"credited_cents":100'
OUT="$(printf 'action=coin&id=vendo-01&nonce=%s&pulses=1&target=%s&seq=1&sig=%s' "$REQNONCE" "$NONCE" "$SIG" | sh "$VENDO")"; echo "$OUT" | grep -q 'replayed coin event'
OUT="$(printf 'action=connect&cents=100' | sh "$API")"; echo "$OUT" | grep -q '"ok":true'
OUT="$(printf 'action=me' | sh "$API")"; echo "$OUT" | grep -q '"remaining_seconds":'
echo 'BlazePwifi integration checks passed'
