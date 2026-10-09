#!/bin/sh
# SHADOW-0666. Real installed script, synthetic v1 account/member/rental data.
# It must never write paid state, emit secrets, or authorize migration.
set -eu
ROOT="$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)"
SCRIPT="$ROOT/openwrt/rootfs/usr/lib/blazepwifi/v2_shadow.sh"
CONFIG="$ROOT/openwrt/rootfs/etc/config/blazepwifi"
T="$(mktemp -d /tmp/blaze-v2-shadow-XXXXXX)"
trap 'rm -rf "$T"' EXIT HUP INT TERM
printf 'BLAZE-SHADOW-READ-ONLY-FIXTURE\n' > "$T/.blaze-shadow-fixture-only"
chmod 700 "$T"
chmod 600 "$T/.blaze-shadow-fixture-only"
[ "$(grep -c "option v2_shadow_diagnostics '0'" "$CONFIG")" -eq 1 ]
# Synthetic identities and secrets are intentionally sensitive test markers:
# none may appear in operator-visible diagnostics, successful or failed.
printf '%s\t250\t0\t0\t0\t0\taa:bb:cc:dd:ee:ff\t10.1.1.2\tsecretReceipt\n' \
 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa' > "$T/accounts.tsv"
printf '%s\t180\t0\t0\t0\t0\tbb:bb:cc:dd:ee:ff\t10.1.1.3\tsecretReceipt2\n' \
 'bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb' >> "$T/accounts.tsv"
printf 'alice\tAlice\t1\tsha256i\tPrivateSalt\tPrivateHash\t4096\t200\t1\t100\tfixture\n' > "$T/members.tsv"
printf 'bob\tBob\t1\tsha256i\tPrivateSalt2\tPrivateHash2\t4096\t0\t1\t100\tfixture\n' >> "$T/members.tsv"
printf 'dev01\tPrivateDeviceSecret\t999999\tTerminal 1\t100\n' > "$T/rental-devices.tsv"
chmod 600 "$T/"*.tsv
snapshot() { sha256sum "$T/accounts.tsv" "$T/members.tsv" "$T/rental-devices.tsv"; }
baseline="$(snapshot)"
fixture() { BLAZE_V2_SHADOW_FIXTURE=1 BP_V2_SHADOW_TEST_ROOT="$T" sh "$SCRIPT" "$@"; }
refuse() {
  old="$(snapshot)"
  if fixture status >"$T/stdout" 2>"$T/stderr"; then
    echo "unsafe v2 shadow input was accepted: $1" >&2
    exit 1
  fi
  [ ! -s "$T/stdout" ] || { echo 'refusal emitted incomplete snapshot' >&2;exit 1; }
  [ "$(snapshot)" = "$old" ] || { echo 'refusal altered paid data' >&2;exit 1; }
  grep -q 'SHADOW BLOCKED' "$T/stderr"
}
result="$(fixture status)"
printf '%s\n' "$result" | grep -Fqx 'status=NON_AUTHORITATIVE_READ_ONLY'
printf '%s\n' "$result" | grep -Fqx 'wallet_accounts=2'
printf '%s\n' "$result" | grep -Fqx 'member_accounts=2'
printf '%s\n' "$result" | grep -Fqx 'rental_devices=1'
printf '%s\n' "$result" | grep -Fqx 'payment_write_authorized=0'
printf '%s\n' "$result" | grep -Fqx 'migration_authorized=0'
[ "$(snapshot)" = "$baseline" ]
if printf '%s\n' "$result" | grep -Eiq 'Private|secretReceipt|alice|dev01|aaaaaaaa'; then
 echo 'SHADOW LEAK: financial identities or key material in diagnostics' >&2;exit 1
fi
# Refuse direct nonfixture invocation and any attempt to use a money operation.
if BLAZE_V2_SHADOW_FIXTURE=1 BP_V2_SHADOW_TEST_ROOT=/etc sh "$SCRIPT" status >"$T/stdout" 2>"$T/stderr"; then
 echo 'arbitrary live state override accepted' >&2;exit 1
fi
if fixture credit >"$T/stdout" 2>"$T/stderr"; then
 echo 'paid write command accidentally supported' >&2;exit 1
fi

cp -p "$T/accounts.tsv" "$T/a.good"
printf '%s\t20\t0\t0\t0\t0\t\t\t\n' 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa' >> "$T/accounts.tsv"
refuse duplicate-account
cp -p "$T/a.good" "$T/accounts.tsv"
printf 'bad\t1\n' >> "$T/accounts.tsv"
refuse truncated-account
cp -p "$T/a.good" "$T/accounts.tsv"

cp -p "$T/members.tsv" "$T/m.good"
printf 'alice\tDuplicate\t1\tsha256i\tx\ty\t4096\t0\t1\t100\tfixture\n' >> "$T/members.tsv"
refuse duplicate-member
cp -p "$T/m.good" "$T/members.tsv"

cp -p "$T/rental-devices.tsv" "$T/r.good"
printf 'dev01\tOtherSecret\t100\tduplicate\t10\n' >> "$T/rental-devices.tsv"
refuse duplicate-rental
cp -p "$T/r.good" "$T/rental-devices.tsv"
printf 'dev02\tOtherSecret\tbogus\tinvalid-lease\t10\n' >> "$T/rental-devices.tsv"
refuse invalid-rental
cp -p "$T/r.good" "$T/rental-devices.tsv"

mv "$T/accounts.tsv" "$T/old-accounts"
ln -s "$T/old-accounts" "$T/accounts.tsv"
refuse symlink-money-store
rm "$T/accounts.tsv"; mv "$T/old-accounts" "$T/accounts.tsv"
printf 'PENDING\t100\n' > "$T/paid-state-uncertain"
refuse uncertain-payment
rm "$T/paid-state-uncertain"
rm "$T/.blaze-shadow-fixture-only"
refuse missing-marker

[ "$(snapshot)" = "$baseline" ] || {
  echo 'v2 shadow diagnostics unexpectedly changed final paid records' >&2; exit 1
}
[ ! -e "$T/v2-ledger.tsv" ] && [ ! -e "$T/v2-shadow-ledger" ]
echo 'SHADOW-0666 PASS: installed read-only diagnostic opted out by default; 3 paid stores validated without mutation, no IDs or secrets leaked, corrupt/duplicate/uncertain/symlink refused'
echo 'NOT PRODUCTION: no coherent financial migration or authenticated crash-atomic powercut ledger'
