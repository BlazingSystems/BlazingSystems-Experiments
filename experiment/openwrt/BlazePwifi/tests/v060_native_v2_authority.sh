#!/bin/sh
# V2NATIVE-0668 — compiled HMAC/fsync journal fixture, not real customer money.
set -eu
ROOT="$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)"
SRC="$ROOT/tools/v060_journal_authority_native.c"
T="$(mktemp -d /tmp/blaze-v2-native-XXXXXX)"
trap 'rm -rf "$T"' EXIT HUP INT TERM
umask 077
chmod 700 "$T"
command -v cc >/dev/null || { echo 'C compiler missing';exit 1; }
command -v openssl >/dev/null || { echo 'OpenSSL test signer missing';exit 1; }
# An unguarded build must be rejected at compile time.
if cc -std=c11 -Wall -Wextra -Werror -O2 "$SRC" -lcrypto -o "$T/unguarded" 2>"$T/compile-error"; then
  echo 'native fixture compiled without LAB-ONLY guard' >&2; exit 1
fi
cc -std=c11 -Wall -Wextra -Werror -O2 -DBLAZE_FIXTURE_ONLY "$SRC" \
  -lcrypto -o "$T/native"
printf 'BLAZE-V2-SYNTHETIC-ONLY\n' >"$T/.blaze-v2-fixture-only"
key=3333333333333333333333333333333333333333333333333333333333333333
printf 'ctrlOne\t%s\n' "$key" > "$T/controller-keys.tsv"
printf 'V\t2\nA\talice\t100\nA\tbob\t200\nL\tdev01\t0\n' >"$T/ledger.tsv"
base="$(sha256sum "$T/ledger.tsv" | cut -d' ' -f1)"
printf 'H\t%s\n' "$base" >>"$T/ledger.tsv"
chmod 600 "$T/.blaze-v2-fixture-only" "$T/controller-keys.tsv" "$T/ledger.tsv"
sign() {
  printf 'BLAZE-V2-AUTH-FIXTURE/1\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n' \
    "$1" "$2" "$3" "$4" "$5" "$6" "$7" "$8" |
    openssl dgst -sha256 -mac HMAC -macopt "hexkey:$key" -r | awk '{print $1}'
}
run() {
  signed="$(sign "$@")"
  "$T/native" "$T" "$@" "$signed"
}
digest() { sha256sum "$T/ledger.tsv" | cut -d' ' -f1; }
bank() { awk -F '\t' -v u="$1" '$1=="A" && $2==u {print $3;exit}' "$T/ledger.tsv"; }
lease() { awk -F '\t' -v u="$1" '$1=="L" && $2==u {print $3;exit}' "$T/ledger.tsv"; }
refuse() {
  before="$(digest)"
  if run "$@" > "$T/out" 2>"$T/err"; then
    echo "unexpected signed transaction accepted: $*" >&2;exit 1
  fi
  [ ! -s "$T/out" ] || { echo 'refusal emitted ACK' >&2;exit 1; }
  [ "$(digest)" = "$before" ] || { echo 'refusal changed ledger' >&2;exit 1; }
}
[ "$(run ctrlOne 1 ctrlOne:1 AM alice - 40 1000)" = "$(printf 'COMMIT\t140')" ]
[ "$(bank alice):$(bank bob)" = '140:200' ]
first="$(digest)"
[ "$(run ctrlOne 1 ctrlOne:1 AM alice - 40 1000)" = "$(printf 'REPLAY\t140')" ]
[ "$(digest)" = "$first" ]
# A real signed payload collision cannot reuse an old controller sequence.
refuse ctrlOne 1 ctrlOne:1 AM alice - 41 1000
refuse ctrlOne 3 ctrlOne:3 TM alice bob 30 1000
refuse ctrlOne 01 ctrlOne:01 TM alice bob 30 1000
refuse ctrlOne 2 ctrlOne:2 TM alice alice 30 1000
# HMAC must reject tampering before any journal state change.
wrong=0000000000000000000000000000000000000000000000000000000000000000
if "$T/native" "$T" ctrlOne 2 ctrlOne:2 TM alice bob 30 1000 "$wrong" >"$T/out" 2>"$T/err"; then
  echo 'unauthenticated paid event accepted' >&2;exit 1
fi
[ ! -s "$T/out" ] && [ "$(digest)" = "$first" ]
export BLAZE_V2_NATIVE_TEST_FAULT=before-source-fsync
refuse ctrlOne 2 ctrlOne:2 TM alice bob 30 1000
export BLAZE_V2_NATIVE_TEST_FAULT=before-rename
refuse ctrlOne 2 ctrlOne:2 TM alice bob 30 1000
unset BLAZE_V2_NATIVE_TEST_FAULT
# After-rename dirsync uncertainty is not a false success ACK. On recovery
# the committed receipt is available for exact retransmission.
export BLAZE_V2_NATIVE_TEST_FAULT=after-rename-before-dir-fsync
if run ctrlOne 2 ctrlOne:2 TM alice bob 30 1000 >"$T/out" 2>"$T/err"; then
  echo 'uncertain payment produced success ACK' >&2;exit 1
fi
[ ! -s "$T/out" ]
grep -Fq UNCERTAIN "$T/err"
unset BLAZE_V2_NATIVE_TEST_FAULT
[ "$(bank alice):$(bank bob)" = '110:230' ]
[ "$(run ctrlOne 2 ctrlOne:2 TM alice bob 30 1000)" = "$(printf 'REPLAY\t110')" ]
[ "$(( $(bank alice) + $(bank bob) ))" -eq 340 ]
# Lease/receipt/highwater all share the same fsync'd snapshot.
[ "$(run ctrlOne 3 ctrlOne:3 LR dev01 - 600 1000)" = "$(printf 'COMMIT\t1600')" ]
[ "$(lease dev01)" = 1600 ]
[ "$(run ctrlOne 3 ctrlOne:3 LR dev01 - 600 1000)" = "$(printf 'REPLAY\t1600')" ]
[ "$(awk -F '\t' '$1=="C"&&$2=="ctrlOne"{print $3}' "$T/ledger.tsv")" = 3 ]
[ "$(awk -F '\t' '$1=="R"&&$2=="ctrlOne"{a++}END{print a+0}' "$T/ledger.tsv")" = 3 ]
# A real post-dir-fsync lost response cannot duplicate paid time.
export BLAZE_V2_NATIVE_TEST_FAULT=after-dir-fsync-before-ack
if run ctrlOne 4 ctrlOne:4 SM alice - 10 1000 >"$T/out" 2>"$T/err"; then
  echo 'simulated lost ACK returned success' >&2;exit 1
fi
unset BLAZE_V2_NATIVE_TEST_FAULT
[ ! -s "$T/out" ] && [ "$(bank alice)" = 100 ]
[ "$(run ctrlOne 4 ctrlOne:4 SM alice - 10 1000)" = "$(printf 'REPLAY\t100')" ]
base="$(digest)"
# The test must never operate on a real or non-synthetic financial directory.
if "$T/native" /etc ctrlOne 5 ctrlOne:5 AM alice - 10 1000 "$wrong" >"$T/out" 2>"$T/err"; then
  echo 'external root accepted' >&2;exit 1
fi
ln "$T/ledger.tsv" "$T/alias"
refuse ctrlOne 5 ctrlOne:5 AM alice - 10 1000
rm "$T/alias"
chmod 644 "$T/controller-keys.tsv"
refuse ctrlOne 5 ctrlOne:5 AM alice - 10 1000
chmod 600 "$T/controller-keys.tsv"
chmod 750 "$T"
refuse ctrlOne 5 ctrlOne:5 AM alice - 10 1000
chmod 700 "$T"
[ "$(digest)" = "$base" ]
# V2NATIVE-0669: signed rolling receipt window is bounded, but the durable
# controller sequence floor must never be rolled back or reused.
expected=100
for seq in 5 6 7 8 9 10 11 12 13 14 15; do
  expected=$((expected-1))
  [ "$(run ctrlOne "$seq" "ctrlOne:$seq" SM alice - 1 1000)" = "$(printf 'COMMIT\t%s' "$expected")" ]
done
[ "$expected" -eq 89 ]
[ "$(bank alice):$(bank bob)" = '89:230' ]
[ "$(awk -F '\t' '$1=="C"&&$2=="ctrlOne"{print $3}' "$T/ledger.tsv")" -eq 15 ]
[ "$(awk -F '\t' '$1=="R"&&$2=="ctrlOne"{c++}END{print c+0}' "$T/ledger.tsv")" -eq 8 ]
# Sequence 1 and sequence 5 have aged out; their authentic signed payloads
# must still be rejected as stale, not credited or replayed as new.
refuse ctrlOne 1 ctrlOne:1 AM alice - 40 1000
refuse ctrlOne 5 ctrlOne:5 SM alice - 1 1000
[ "$(run ctrlOne 15 ctrlOne:15 SM alice - 1 1000)" = "$(printf 'REPLAY\t89')" ]
[ "$(bank alice)" -eq 89 ]
# Another process holding the durable lock cannot race a new paid write.
(
  exec 9>"$T/.v2-native-lock"
  flock -x 9
  printf 'HELD\n' >"$T/.lockready"
  sleep 2
) &
locker=$!
while [ ! -e "$T/.lockready" ]; do sleep 0.1; done
refuse ctrlOne 16 ctrlOne:16 AM alice - 10 1000
wait "$locker"
[ "$(bank alice)" -eq 89 ]
# Data corruption must not be treated as a zero-balance fallback.
sed 's/A\talice\t89/A\talice\t90/' "$T/ledger.tsv" > "$T/bad"
mv "$T/bad" "$T/ledger.tsv"
refuse ctrlOne 5 ctrlOne:5 AM alice - 10 1000
grep -Fq 'SHA-256 integrity footer mismatch' "$T/err"
echo 'V2NATIVE-0669 PASS: native HMAC/fsync boundary, replay floor after receipt compaction, lock contention, tamper and crash no-ACK'
echo 'LAB ONLY: fixture binary never installed; no target OpenWrt cross build, migration, or physical power-cut proof'
