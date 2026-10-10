#!/bin/sh
# TRUST-0694 negative/synthetic-only regression. Never touches real TPM or paid state.
set -eu
BASE="$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)"
SCANNER="$BASE/tools/v060_trust_capability_inventory.sh"
[ -r "$SCANNER" ] || exit 1
sh -n "$SCANNER"
TMP="$(mktemp -d /tmp/blaze-trust-0694-XXXXXX)"
trap 'rm -rf "$TMP"' EXIT HUP INT TERM
chmod 700 "$TMP"
mkdir -p "$TMP/root/dev" "$TMP/root/sys/class/tpm/tpm0" "$TMP/root/sys/class/block"
run_blocked() {
    label=$1
    shift
    code=0
    BLAZE_TRUST_TEST_FIXTURE=1 sh "$SCANNER" "$@" >"$TMP/out" 2>"$TMP/err" || code=$?
    [ "$code" -eq 2 ] || { echo "TRUST-0694 unexpectedly accepted $label ($code)" >&2; exit 1; }
    grep -Fq '"decision":"BLOCKED_UNVERIFIED_TRUST_ROOT"' "$TMP/out"
    grep -Fq '"paid_ack_authorized":false' "$TMP/out"
    grep -Fq '"independent_witness_verified":false' "$TMP/out"
    grep -Fq '"financial_migration_authorized":false' "$TMP/out"
    grep -Fq '"physical_powercut_verified":false' "$TMP/out"
    grep -Fq '"customer_install_authorized":false' "$TMP/out"
    [ ! -s "$TMP/err" ]
}
run_blocked 'no trust candidates' --fixture-root "$TMP/root" generic
grep -Fq '"tpm2_candidate":false' "$TMP/out"
grep -Fq '"rpmb_candidate":false' "$TMP/out"
grep -Fq '"evidence_mode":"synthetic"' "$TMP/out"
: > "$TMP/root/dev/tpm0"
printf '2\n' > "$TMP/root/sys/class/tpm/tpm0/tpm_version_major"
run_blocked 'synthetic TPM2 candidate' --fixture-root "$TMP/root" x86_64
grep -Fq '"tpm2_candidate":true' "$TMP/out"
printf '1\n' > "$TMP/root/sys/class/tpm/tpm0/tpm_version_major"
run_blocked 'TPM1 does not claim TPM2' --fixture-root "$TMP/root" x86_64
grep -Fq '"tpm2_candidate":false' "$TMP/out"
mkdir "$TMP/root/sys/class/block/mmcblk0rpmb"
run_blocked 'synthetic RPMB candidate' --fixture-root "$TMP/root" orangepi
grep -Fq '"rpmb_candidate":true' "$TMP/out"
code=0
sh "$SCANNER" --fixture-root "$TMP/root" r281 >"$TMP/out" 2>"$TMP/err" || code=$?
[ "$code" -eq 64 ] || { echo 'Fixture mode accepted without explicit fixture flag' >&2; exit 1; }
code=0
sh "$SCANNER" unknown-device >"$TMP/out" 2>"$TMP/err" || code=$?
[ "$code" -eq 64 ] || { echo 'Unknown hardware target accepted' >&2; exit 1; }
# Do not run against the live CI host: no physical evidence is available from CI.
echo 'TRUST-0694 PASS: absent, synthetic TPM2/RPMB, TPM1 and fixture guard remain blocked'
echo 'PHYSICAL_POWER_CUT_VERIFIED=0 CUSTOMER_INSTALL_AUTHORIZED=0'
