#!/bin/sh
# TRUST-0694. Diagnostic ONLY. No payment authority, TPM ownership operation or network I/O.
# Presence of a device node is NEVER evidence of an independent trusted witness.
set -eu

usage() {
    printf '%s\n' 'Usage: v060_trust_capability_inventory.sh {x86_64|orangepi|ruijie|r281|generic}' >&2
    printf '%s\n' '       BLAZE_TRUST_TEST_FIXTURE=1 ... --fixture-root /tmp/fixture TARGET (synthetic tests only)' >&2
    exit 64
}

mode=live
root=
if [ "$#" -eq 1 ]; then
    target=$1
elif [ "$#" -eq 3 ] && [ "$1" = "--fixture-root" ]; then
    [ "${BLAZE_TRUST_TEST_FIXTURE:-0}" = 1 ] || usage
    mode=synthetic
    root=$2
    target=$3
    case "$root" in
        /*) [ -d "$root" ] || usage ;;
        *) usage ;;
    esac
else
    usage
fi

case "$target" in
    x86_64|orangepi|ruijie|r281|generic) ;;
    *) usage ;;
esac

# Fixed booleans and fixed-choice target only. Never expose serial numbers,
# TPM EK credentials, any key material, filesystem UUIDs, or live account data.
tpm_node=false
tpm2_candidate=false
rpmb_candidate=false

if [ "$mode" = synthetic ]; then
    # Inert files emulate candidate nodes; they NEVER establish hardware evidence.
    [ -e "$root/dev/tpm0" ] || [ -e "$root/dev/tpmrm0" ] || : 
    if [ -e "$root/dev/tpm0" ] || [ -e "$root/dev/tpmrm0" ]; then
        tpm_node=true
    fi
else
    if [ -c /dev/tpm0 ] || [ -c /dev/tpmrm0 ]; then
        tpm_node=true
    fi
fi

major_file="$root/sys/class/tpm/tpm0/tpm_version_major"
if [ "$tpm_node" = true ] && [ -r "$major_file" ]; then
    IFS= read -r major < "$major_file" || major=
    if [ "$major" = 2 ]; then
        tpm2_candidate=true
    fi
fi

# RPMB may be indicated by a Linux block-class device, but no capability,
# monotonic counter access, antirollback independence or driver validity
# is established by a sysfs entry.
for entry in "$root"/sys/class/block/mmcblk*rpmb "$root"/sys/block/mmcblk*rpmb; do
    if [ -e "$entry" ]; then
        rpmb_candidate=true
        break
    fi
done

printf '{"schema":"BLAZE_TRUST_CAPABILITY_V1","target":"%s","evidence_mode":"%s","tpm_node_observed":%s,"tpm2_candidate":%s,"rpmb_candidate":%s,"independent_witness_verified":false,"paid_ack_authorized":false,"financial_migration_authorized":false,"customer_install_authorized":false,"physical_powercut_verified":false,"decision":"BLOCKED_UNVERIFIED_TRUST_ROOT"}\n' \
    "$target" "$mode" "$tpm_node" "$tpm2_candidate" "$rpmb_candidate"

# A diagnostic tool must not return success as an installation gate.
# 2 means NO validated trust root, including when a candidate is present.
exit 2
