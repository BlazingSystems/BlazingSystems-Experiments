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

# PAY-0711: deterministically hold the transaction lock BEFORE its pending
# marker is written, reproducing the old replay fast-path's lock bypass.
# Neither the fake writer nor this test changes any member balance.
(
  exec 8>"$BP_RUN/paid-financial.lock" || exit 1
  flock -x 8 || exit 1
  : > "$T/writer-lock-held"
  while [ ! -f "$T/writer-lock-release" ]; do sleep 0.05; done
) &
writer_pid=$!
tries=0
while [ ! -f "$T/writer-lock-held" ] && [ "$tries" -lt 100 ]; do
  sleep 0.05
  tries=$((tries+1))
done
[ -f "$T/writer-lock-held" ] || { echo 'synthetic writer lock failed' >&2; exit 1; }
for op in bank restore transfer; do
  case "$op" in
    bank) guarded="$(call member_bank 'alice:0123456789abcdef:placeholder' 60 11111111)" ;;
    restore) guarded="$(call member_restore 'alice:0123456789abcdea:placeholder' 0 22222222)" ;;
    transfer) guarded="$(call member_transfer 'alice>bob:0123456789abcdeb:placeholder' 30 33333333)" ;;
  esac
  printf '%s' "$guarded" | grep -q '"ok":false' || {
    echo "P0 false signed replay ACK during paid writer critical section: $op" >&2; exit 1;
  }
  printf '%s' "$guarded" | grep -q 'paid financial operation busy' || exit 1
  ! printf '%s' "$guarded" | grep -q '"replayed":true'
done
: > "$T/writer-lock-release"
wait "$writer_pid"
normal_after_lock="$(call member_bank 'alice:0123456789abcdef:placeholder' 60 11111111)"
printf '%s' "$normal_after_lock" | grep -q '"replayed":true'
[ "$(sha256sum "$BP_STATE/members.tsv" "$BP_STATE/member-events.tsv")" = "$before" ]

# PAY-0635: the very same signed receipt ID with a DIFFERENT amount, or a
# DIFFERENT recipient, cannot return a successful acknowledgement. A success
# here would tell the Windows PC that time went to the wrong recipient.
for collision in bank-amount transfer-amount transfer-recipient; do
  case "$collision" in
    bank-amount)
      response="$(call member_bank 'alice:0123456789abcdef:placeholder' 61 11111111)" ;;
    transfer-amount)
      response="$(call member_transfer 'alice>bob:0123456789abcdeb:placeholder' 31 33333333)" ;;
    transfer-recipient)
      response="$(call member_transfer 'alice>charlie:0123456789abcdeb:placeholder' 30 33333333)" ;;
  esac
  printf '%s' "$response" | grep -q '"ok":false'
  printf '%s' "$response" | grep -q 'member event payload collision'
  if printf '%s' "$response" | grep -q '"replayed":true'; then
    echo "P0 collision falsely acknowledged: $collision" >&2; exit 1
  fi
done
[ "$(sha256sum "$BP_STATE/members.tsv" "$BP_STATE/member-events.tsv")" = "$before" ]

# Bypass the CGI replay fast path and verify the two underlying core member
# functions fail with a dedicated collision result instead of applying money.
set +e
sh -c '. "$BP_LIB"; . "$BP_MEMBER_LIB"; bp_member_balance_change alice add 61 softtimer:vendo-01 0123456789abcdef' > "$T/core-bank" 2>&1
bank_rc=$?
sh -c '. "$BP_LIB"; . "$BP_MEMBER_LIB"; bp_member_transfer alice charlie 30 softtimer:vendo-01 0123456789abcdeb' > "$T/core-transfer" 2>&1
transfer_rc=$?
set -e
[ "$bank_rc" -eq 5 ] && [ "$transfer_rc" -eq 5 ] || {
  echo "P0 core member replay collision mismatch bank=$bank_rc transfer=$transfer_rc" >&2
  cat "$T/core-bank" "$T/core-transfer" >&2
  exit 1
}
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
