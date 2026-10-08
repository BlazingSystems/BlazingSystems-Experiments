#!/bin/sh
# MIG-0617 RED regression: synthetic-only expected to FAIL on unsafe replay.
# Do not point this at an installed device, and do not silently invert its exit.
set -u
ROOT="$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)"
T="$(mktemp -d)" || exit 1
trap 'rm -rf "$T"' EXIT HUP INT TERM
BP_STATE="$T/state"; BP_RUN="$T/run"; mkdir -p "$BP_STATE" "$BP_RUN"
printf 'BLAZE-SYNTHETIC-FIXTURE-ONLY\n' > "$T/.blaze-fixture-only"
BP_MEMBERS="$BP_STATE/members.tsv"
BP_MEMBER_EVENTS="$BP_STATE/member-events.tsv"
BP_MEMBER_REVISION="$BP_STATE/member-revision"
bp_init_dirs() { :; }
bp_cfg() { case "$1" in member_event_history) printf '128';; *) printf ''; esac; }
bp_tmp_suffix() { printf 'repro'; }
bp_durable_sync() { :; }
bp_now() { printf '123456'; }
# Member module relies on the actual production write/credit/dedupe algorithms;
# only host integration helpers are replaced, all paths are temporary.
. "$ROOT/openwrt/rootfs/usr/lib/blazepwifi/member.sh"
bp_member_init
printf 'alice\tFixture\t1\tsha256i\tsalt\thash\t4096\t100\t1\t123\tfixture\n' > "$BP_MEMBERS"
printf '1\n' > "$BP_MEMBER_REVISION"
# A valid prior credit, followed by 129 unrelated events, ages its ID out.
bp_member_event_record 'original-coin' 1 alice add 10 10 softtimer:fixture 110
i=0
while [ "$i" -lt 129 ]; do
  bp_member_event_record "other-$i" 1 alice patch 0 0 fixture 0
  i=$((i+1))
done
if grep -q '^original-coin[[:space:]]' "$BP_MEMBER_EVENTS"; then
  echo 'REPRO SETUP FAILURE: original event was not evicted' >&2; exit 2
fi
before="$(bp_member_line alice | cut -f8)"
bp_member_balance_change alice add 10 softtimer:fixture original-coin > "$T/result"
after="$(bp_member_line alice | cut -f8)"
if [ "$after" != "$before" ]; then
  echo 'P0 RED: evicted event ID credited again in synthetic fixture' >&2
  exit 1
fi
echo 'PASS: evicted duplicate ID did not mutate account balance'
