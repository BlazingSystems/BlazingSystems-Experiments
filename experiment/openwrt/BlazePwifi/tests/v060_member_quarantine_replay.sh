#!/bin/sh
# PAY-0631: even a previously ACKed member receipt must not bypass
# a pending financial reconciliation. Real signed Vendo CGI, synthetic state.
set -eu
ROOT="$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)"
T="$(mktemp -d /tmp/blaze-member-quarantine-XXXXXX)"
trap 'rm -rf "$T"' EXIT HUP INT TERM
mkdir -p "$T/bin" "$T/state" "$T/run"
cat > "$T/bin/uci" <<'UCI'
#!/bin/sh
case "$*" in
  *'get blazepwifi.main.vendo_key') echo synthetic-member-secret;;
  *'get blazepwifi.main.vendo_port') echo 4455;;
  *'get blazepwifi.main.durable_sync') echo 0;;
  *) exit 1;;
esac
UCI
chmod +x "$T/bin/uci"
export PATH="$T/bin:$PATH" BP_STATE="$T/state" BP_RUN="$T/run"
export BP_LIB="$ROOT/openwrt/rootfs/usr/lib/blazepwifi/common.sh"
export BP_RENTAL_LIB="$ROOT/openwrt/rootfs/usr/lib/blazepwifi/rental.sh"
export BP_CONTROLLER_LIB="$ROOT/openwrt/rootfs/usr/lib/blazepwifi/controller.sh"
export BP_MEMBER_LIB="$ROOT/openwrt/rootfs/usr/lib/blazepwifi/member.sh"
export REQUEST_METHOD=POST SERVER_PORT=4455 REMOTE_ADDR=10.0.0.9
VENDO="$ROOT/openwrt/rootfs/www/blazepwifi/cgi-bin/vendo"
printf 'alice\tAlice\t1\tsha256i\tsalt\thash\t4096\t2400\t1\t123\tfixture\n' > "$BP_STATE/members.tsv"
printf 'bob\tBob\t1\tsha256i\tsalt\thash\t4096\t1200\t1\t123\tfixture\n' >> "$BP_STATE/members.tsv"
printf '1\n' > "$BP_STATE/member-revision"
printf '0123456789abcdef\t123\talice\tadd\t60\t60\tsofttimer:vendo-01\t2460\n' > "$BP_STATE/member-events.tsv"
printf '0123456789abcdea\t123\talice\trestore_all\t-120\t120\tsofttimer:vendo-01\t0\n' >> "$BP_STATE/member-events.tsv"
printf '0123456789abcdeb\t123\talice\ttransfer\t-30\t30\tsofttimer:vendo-01\t2370:bob:1230\n' >> "$BP_STATE/member-events.tsv"
chmod 600 "$BP_STATE/"*.tsv "$BP_STATE/member-revision"
before="$(sha256sum "$BP_STATE/members.tsv" "$BP_STATE/member-events.tsv")"

call() {
  action="$1"; payload="$2"; pulses="$3"; nonce="$4"
  sig="$(printf 'synthetic-member-secret|%s|vendo-01|%s|%s|%s|synthetic-member-secret' "$action" "$nonce" "$pulses" "$payload" | sha256sum | cut -d' ' -f1)"
  printf 'action=%s&id=vendo-01&nonce=%s&pulses=%s&target=%s&sig=%s' "$action" "$nonce" "$pulses" "$payload" "$sig" | sh "$VENDO"
}
# The signed replay shortcut normally works for genuinely recorded ACKs.
bank="$(call member_bank 'alice:0123456789abcdef:placeholder' 60 11111111)"
printf '%s' "$bank" | grep -q '"replayed":true'
restore="$(call member_restore 'alice:0123456789abcdea:placeholder' 0 22222222)"
printf '%s' "$restore" | grep -q '"replayed":true'
transfer="$(call member_transfer 'alice>bob:0123456789abcdeb:placeholder' 30 33333333)"
printf '%s' "$transfer" | grep -q '"replayed":true'
[ "$(sha256sum "$BP_STATE/members.tsv" "$BP_STATE/member-events.tsv")" = "$before" ]

# Simulate a disputed mid-transaction crash. From now on, *no* financial
# replay may appear to resolve the uncertainty or mint a new signed ACK.
printf 'PENDING\t123\n' > "$BP_STATE/paid-state-uncertain"
for op in bank restore transfer; do
  case "$op" in
    bank) result="$(call member_bank 'alice:0123456789abcdef:placeholder' 60 11111111)" ;;
    restore) result="$(call member_restore 'alice:0123456789abcdea:placeholder' 0 22222222)" ;;
    transfer) result="$(call member_transfer 'alice>bob:0123456789abcdeb:placeholder' 30 33333333)" ;;
  esac
  printf '%s' "$result" | grep -q '"ok":false'
  printf '%s' "$result" | grep -q 'operator reconciliation required'
  if printf '%s' "$result" | grep -q '"replayed":true'; then
    echo "P0 false replay ACK while financial state quarantined: $op" >&2
    exit 1
  fi
done
[ "$(sha256sum "$BP_STATE/members.tsv" "$BP_STATE/member-events.tsv")" = "$before" ]
[ -f "$BP_STATE/paid-state-uncertain" ]
echo 'PAY-0631 signed member CGI PASS: normal replay allowed before quarantine; banking, restore, transfer replay refused under paid uncertainty without state mutation'
echo 'PRODUCTION remains BLOCKED: crash-atomic journal, source v1 recovery, owner signing, real hardware acceptance missing'
