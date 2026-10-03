#!/bin/sh
set -eu
ROOT="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"; T="$(mktemp -d)"; trap 'rm -rf "$T"' EXIT
mkdir -p "$T/bin" "$T/state" "$T/run"
cat >"$T/bin/uci" <<'UCI'
#!/bin/sh
case "$*" in
 *'get blazepwifi.main.lan_if') echo br-lan;; *'get blazepwifi.main.coin_window') echo 120;; *'get blazepwifi.main.pulse_value_centavos') echo 100;; *'get blazepwifi.main.vendo_key') echo vendokey;; *'show blazepwifi') echo "blazepwifi.p1=rate";; *'get blazepwifi.p1.cents') echo 100;; *'get blazepwifi.p1.seconds') echo 60;; *) exit 1;; esac
UCI
cat >"$T/bin/ip" <<'IP'
#!/bin/sh
echo '10.0.0.2 dev br-lan lladdr aa:bb:cc:dd:ee:ff REACHABLE'
IP
printf '#!/bin/sh\nexit 0\n' >"$T/bin/nft"; chmod +x "$T/bin/"*
export PATH="$T/bin:$PATH" BP_STATE="$T/state" BP_RUN="$T/run" BP_LIB="$ROOT/openwrt/rootfs/usr/lib/blazepwifi/common.sh" REMOTE_ADDR=10.0.0.2 REQUEST_METHOD=POST
API="$ROOT/openwrt/rootfs/srv/blazepwifi-public/cgi-bin/api"; V="$ROOT/openwrt/rootfs/srv/blazepwifi-vendo/cgi-bin/vendo"
OUT="$(printf 'action=coin_start&mac=de:ad:be:ef:00:01'|sh "$API")"; grep -q '^aa:bb:cc:dd:ee:ff|' "$T/run/coin-target.tsv"
TN="$(cut -d'|' -f2 "$T/run/coin-target.tsv")"; N=aaaaaaaa11111111
sig(){ printf 'vendokey|coin|vendo-01|%s|1|%s|%s|vendokey' "$N" "$1" "$2"|sha256sum|awk '{print $1}'; }
S="$(sig "$TN" 1)"; OUT="$(printf 'action=coin&id=vendo-01&nonce=%s&pulses=1&target=%s&seq=1&sig=%s' "$N" "$TN" "$S"|sh "$V")"; echo "$OUT"|grep -q '"ok":true'
OUT="$(printf 'action=coin&id=vendo-01&nonce=%s&pulses=1&target=%s&seq=1&sig=%s' "$N" "$TN" "$S"|sh "$V")"; echo "$OUT"|grep -q 'replayed coin event'
OLD="$TN"; printf 'action=coin_start'|sh "$API" >/dev/null; NEW="$(cut -d'|' -f2 "$T/run/coin-target.tsv")"; [ "$NEW" != "$OLD" ]
S="$(sig "$OLD" 2)"; OUT="$(printf 'action=coin&id=vendo-01&nonce=%s&pulses=1&target=%s&seq=2&sig=%s' "$N" "$OLD" "$S"|sh "$V")"; echo "$OUT"|grep -q 'stale target'
echo 'BlazePwifi security regression checks passed'
