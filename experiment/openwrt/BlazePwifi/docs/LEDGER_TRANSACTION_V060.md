# BlazePwifi v0.6.0 — prepaid ledger transaction safety contract
Status: **DESIGN / NOT IMPLEMENTED** · 2026-10-09 (Asia/Manila) · P0 issue #31

## Why this contract exists
The current v0.5.x-style `member.sh` mutates money/time rows and then appends a
bounded event history. This cannot promise that a paid transaction is recorded
exactly once. GitHub CI [#37810302638](https://github.com/BlazingSystems/BlazingSystems-Experiments/actions/runs/37810302638)
reproduced **duplicate prepaid credit** after an event ID aged out and a
**partial sender debit** when the process died between two transfers.

An isolated development fix at `5782937deeb1651d45204d446a9851179be9d6c3`
replaces both sides of a transfer in one rename; staged test
[#37810785263](https://github.com/BlazingSystems/BlazingSystems-Experiments/actions/runs/37810785263)
shows that particular interruption boundary passing. It is NOT sufficient
for reboot-safe event receipt or durability: `member-events.tsv` remains
a separate, fallible write. Staged CI
[#37811179871](https://github.com/BlazingSystems/BlazingSystems-Experiments/actions/runs/37811179871)
also reproduced a failed receipt write followed by a successful credit response.

## Mandatory invariants (apply to all financial operations)
1. A validated, authenticated operation either makes **both** the balance
   effect and a durable receipt visible on recovery, or makes neither visible.
   No acknowledgment before a durable commit.
2. A retry of an accepted transaction must never reapply its financial delta.
   Reusing the ID/sequence with changed amount, member, destination, or
   controller is rejected. A previously committed operation may return its
   original result and signature.
3. Transfer preserves the total across both accounts, including crash and
   disk-full boundaries. Debit and credit are one logical operation.
4. Concurrent events are serialized through a tested lock. Readers never see
   a partially applied financial transition. Stale state revisions are
   rejected, not silently overwritten by a backup or second process.
5. Every accepted paid event is either durably committed or explicitly
   rejected; no over-credit or lost seconds under an uncertain ACK.
6. Corrupt or insufficient storage goes **read-only/fail-closed for paid
   mutations**, with operator recovery instructions; never default a corrupt
   money balance to zero or silently truncate authoritative journal records.
7. A bounded device must not silently forget IDs that it can subsequently
   accept as new. Arbitrarily old random IDs and finite replay storage
   cannot simultaneously guarantee indefinitely remembered receipts.

## Proposed v2 transaction structure — not a production API
- **Server authoritative:** a versioned write-ahead transaction journal is
  the source of truth. Each record carries a protocol version, strict
  controller identity, authenticated monotonic sequence, immutable event ID,
  source/destination members, signed delta, previous revision, after-state or
  deterministic update, result/ACK digest and integrity framing.
- **Atomic commit:** write one complete financial operation **and its receipt**
  as a single journal transaction with integrity framing; durably flush the
  record and metadata before returning ACK. Materialize `members.tsv` as a
  verified read model *after* commit, reconstructable on boot. Do not
  treat independently updated `member-events.tsv` as authoritative.
- **Crash scanning:** accept only complete valid committed records in order;
  truncate/quarantine a verifiably incomplete unacknowledged tail using a
  tested procedure; never discard an already acknowledged record. Verify
  snapshot epoch, checksum, previous journal hash/revision and write ordering.
- **Bounded storage:** use bounded retained journal segments + checkpoints;
  persist a **per-controller high-water mark and bounded replay window**.
  IDs/sequences older than the admissible window must be rejected as stale,
  *never* accepted as new. A still-outstanding ambiguous operation must keep
  the controller paused/frozen until reconciled rather than issuing a new ID.
  Before reclaiming segments, prove that checkpoints retain all balances,
  controller floors, sequence-window receipt data and recovery metadata.
  On quota exhaustion reject new paid events safely; **never** evict an
  admissible receipt to create space.
- **Protocol compatibility:** current SoftTimer v0.4.x uses random persisted
  event IDs, so simply adding a sequence check on the server would break
  legitimate clients. Introduce negotiated v2 protocol and durable
  controller sequence/ACK journal, with an explicit v1 quiescence/migration
  plan. Binding and source/controller mismatch checks remain mandatory.
- **Other callers:** admin set/add/transfer/restore must have stable idempotency
  keys and the same ledger transaction mechanism. Rental lease/coin changes
  in `rental.sh` and `common.sh` need an equivalent P0 assessment; fixing
  members alone does not certify the other money stores.

## Implementation acceptance, in strict order
1. Prove failing old-code fixtures: trimmed ID replay, interrupted transfer,
   receipt EIO, event-ID collision across users/controllers, concurrent writes,
   out-of-order ACK, old/stale sequence, storage full, corrupt/incomplete tail.
2. Prototype journal off-device with fictional balances and deterministic
   crash injection **before/after** intent, commit flush, materialized view,
   ACK, compaction and restart; assert exact once, total conservation, no
   lost-ACK re-credit. A green mock test is only engineering evidence.
3. Determine target-specific durable write mechanism. Today
   `bp_durable_sync` can be **disabled** via `durable_sync` config;
   this is inadequate for a guaranteed prepaid ACK. Verify write/fsync and
   parent-directory durability on target OpenWrt/ImmortalWrt filesystems.
   Do not assume `mv` alone guarantees power-loss persistence.
4. Version, migrate and verify old member/event/controller/rental state
   under an offline, transaction-quiesced signed migration. Previously
   evicted v0.5 receipts **cannot be reconstructed** from a truncated
   history: do not silently certify historic exactly-once semantics.
5. Expand required CI on the exact source SHA, including SoftTimer reconnect,
   Windows installer, firmware/ESP, Android, x86/Ruijie/Orange Pi, admin API,
   portable profile safety, and 30-device accounting soak. Add real power-cut
   testing on supported flash/storage before unblocking shipping.
6. Encrypted private backup must cover journal, controller sequence floors,
   retained receipts, balances, signer identity and migration epoch. Restore
   must fail closed if newer paid transactions occurred after snapshot.
   Exercise signed release/rescue/rollback using the unchanged Lineage-2 signer.

## Explicit prohibition
Do not advertise this document, the staging test, or the one-rename transfer
patch as complete journal support or production-quality money safety.
No live database migration, firmware flash, real customer files, production
release, signer/key rotation, or default-account changes are authorized.
Existing v0.6-family update preflight must remain blocked.

## Next concrete source step
Build a new isolated, source-controlled v2 journal **fixture prototype**
and fault-injection test harness, with exact acceptance vectors above.
Only integrate it behind a disabled-by-default migration guard after the
prototype passes and actual v1 controller compatibility has been analyzed.
Do not patch only the rolling `member-events.tsv` cache and assume the
P0 problem is solved.

## ROLLBACK-0691 — valid older snapshot loses ACKed member + rental credits (EXPECTED UNSAFE / OPEN)

Source-controlled, off-device, LAB-ONLY reproduction: `tests/v060_v2_snapshot_rollback_repro.sh` compiles the `-DBLAZE_FIXTURE_ONLY` authenticated v2 journal. It acknowledges a fictional member credit, snapshots `ledger.tsv`, then acknowledges another member credit plus a rental lease from another private fixture controller. A manual restore of the first **checksum-valid** snapshot erases the two later paid operations **and their receipt/controller sequence high-water state**. Retrying the identical signed operations now produces **new `COMMIT`** responses rather than `REPLAY`. The earlier known source paths have no independent freshness attestation; the snapshot's SHA-256 proves integrity of its bytes, not that it is the latest paid state. Full GitHub Actions [#37990879058](https://github.com/BlazingSystems/BlazingSystems-Experiments/actions/runs/37990879058) at source head `b4ca34ad8dd30fafcd0e888b629152ed02cee1f6` completed **26 success, 4 production skips, 0 failures**. Its specifically named `ROLLBACK-0691 EXPECTED UNSAFE` step **passed because the flaw was reproduced**, not because it was fixed.

Before a v2 state restore or migration can ever take payment, require all of these independently verified conditions:

1. Capture a **trusted anti-rollback epoch / per-controller committed sequence floor** that cannot be silently replaced along with `ledger.tsv`. Define its custody and durability boundary; a second unprotected file in the same snapshot or directory is not independent authority. Authenticate any off-device witness, including scope to exact appliance and controller generation. Offline/absent witness must block reactivation rather than silently trust an old checksum-valid snapshot.
2. Freeze and drain **all** coin, member, rental, Windows and admin paid-state writers before snapshot/migration. Record unresolved ACK outcomes and treat them as UNKNOWN, not new receipts. Independently validate every last-ACKed high-water floor against the restored snapshot.
3. **Fail closed** when presented with a stale but internally valid snapshot: never mint missing paid time, rewrite the trusted sequence floor downward, auto-replay unacknowledged transactions as if new, or overwrite newer prepaid state. Require private owner-authorized reconciliation with controller receipts and device leases.
4. Extend synthetic fault-injection for: restore-to-older epoch; missing/corrupt witness; conflicting controller floors; interrupted two-phase witness update; acknowledged payment between backup and attempted restore; lost ACK before witness persistence; backup from another device; source-version mismatch; retention/compaction; concurrent write during snapshot. A new independent witness scheme must prove no false ACK and no accepted rollback under these cases **before** its guard could be enabled on any real device.
5. Prove on isolated disposable physical storage with real independent power-control telemetry, signed current+rescue Android enrollment, original signer continuity, and 30+ real client/24-hour acceptance before any 0.6 release. An unverified synthetic result is never physical acceptance.

**Status: OPEN P0, NO PRODUCTION v0.6.0; migration/update preflight denial remains intact.** This reproduction involves deliberate manual file replacement inside a 0700 fake `/tmp` lab and does not establish a remote compromise or actual customer event. Linked trackers: member [#31](https://github.com/BlazingSystems/BlazingSystems-Experiments/issues/31), rental [#32](https://github.com/BlazingSystems/BlazingSystems-Experiments/issues/32), hardware [#34](https://github.com/BlazingSystems/BlazingSystems-Experiments/issues/34).
