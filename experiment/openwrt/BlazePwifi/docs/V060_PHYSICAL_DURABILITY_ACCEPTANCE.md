# BlazePwifi v0.6.0 — Physical durability & reversible migration acceptance

**Status:** TEST PROTOCOL ONLY / NOT EXECUTED / NOT CUSTOMER AUTHORIZED  
**Work item:** MULTICTL-0673 (2026-10-09, Asia/Manila)  
**Evidence baseline:** v0.6.0 draft PR #30, source `2ad44a61e978b86be8b19c0f98a34e9517684c0b`. The first three-target SDK binary compilation is proven by GitHub CI; persistent-media powercut validation is NOT.

## Critical distinction: /tmp is not persistent flash

The existing native journal is deliberately **fixture-only** and its root is restricted to `/tmp/blaze-v2-native-*` (`BLAZE_FIXTURE_ONLY`, private synthetic marker). On common OpenWrt targets `/tmp` is **tmpfs**. Unplugging such a device destroys the synthetic directory. Therefore simply power-cutting the current fixture under plain `/tmp` **cannot prove power-loss durability**.

A legitimate hardware experiment needs a disposable, physically persistent scratch filesystem, with a single synthetic fixture directory bind-mounted *at the existing /tmp guard path*, after explicitly verifying the bind mount resolves to the scratch storage. Do not change the program's permitted root prefix or remove its fixture guard to obtain a passing result. Do not use customer `/overlay`, `/etc`, real payment directories, live router flash partitions, or shared persistent state. Mount setup and partition handling require operator review; this document intentionally does **not** supply destructive partitioning commands or authorize remote execution.

No test result is valid unless the backing mount/flash device, filesystem, and actual persistence after unclean reboot are evidenced. A successful GitHub-hosted simulation or clean software restart is not physical power-loss evidence.

## Equipment & operator authorization (hard preflight)

All items must be recorded for *each physical target* — Ruijie RG-EW1200G Pro MIPS, Orange Pi Zero 3 AArch64 and x86-64:

- Dedicated non-customer hardware, isolated LAN, no production coin acceptor or active vending/rental stations.
- Physical power controller capable of removing supply power at recorded checkpoints; safe supply protection and recovery access. Never disconnect power to equipment holding customer balances.
- Dedicated disposable persistent storage with explicit capacity, mount source, filesystem (and barriers/journaling mode), kernel and storage model. Prove the `/tmp/blaze-v2-native-*` path is a bind mount into **this** scratch storage, not plain tmpfs.
- Verified SHA-256 of lab executable and package, target ELF machine, OpenWrt 25.12.5 ABI, target-specific SDK run, and no source from another architecture. Lab `.apk` must never be distributed to customers.
- Fixture-only fake controllers/accounts, randomly generated **test** HMAC keys, private marker, private directory 0700/files 0600. Use no exported live accounts, member secrets, signing keys, enrollments or transaction IDs.
- Authorized operator, fixture backup/snapshot plan and immutable off-device logging. Abort if mount/fixture/source ownership checks fail.
- Confirm the running binary has **no** customer CGI endpoint, init service or packet listener. A local synthetic CLI is not live payment authority.

## Required test cases, each with independent recorded start/end state

1. **Baseline/replay:** independent controller A and B keys, interleaved paid-credit, spend, transfer and lease operations on a shared synthetic bank. Record unique event IDs, exact signed input, durable ACK/replay classification, expected and actual balances, controller high-water marks and immutable receipt identity. Never log test keys or actual HMAC secrets.
2. **Bad input:** altered signed payload, wrong controller key, stale sequence outside the retained receipt window, same event with changed amount, skipped sequence, missing protected marker, symlink/hardlink/permission tamper. Each must fail with **zero ledger mutation and zero payment ACK**.
3. **Synthetic deterministic fault stages:** `before-source-fsync`, `before-rename`, `after-rename-before-dir-fsync`, and `after-dir-fsync-before-ack` (the names currently supported by the fixture). These software faults test state-machine behavior but are NOT evidence of a real power cut.
4. **Actual supply interruption on scratch persistent mount:** use instrumented operator-controlled shutdown at corresponding write/rename/dirsync/ACK boundaries (not arbitrary wall-clock delays). On reboot, mount/recover scratch storage without rewriting it; record ledger bytes before any replay attempt. Old state or new state may be valid at uncertain commit boundaries, but **never a partially valid balance/receipt pair**. No success ACK may be asserted for unknown durability.
5. **Replay after uncertain outcome:** resend the **same** signed controller ID, sequence and payload. If committed, return the stored outcome without new money/time; if not committed, the retry may commit once. Controller sequence high-water, member sums and rental lease must remain coherent. Never resolve uncertainty by minting an extra credit or overwriting a corrupt journal.
6. **Unavailable or full storage:** read-only mount, ENOSPC, EIO and sudden disconnection must fail closed and preserve an auditable uncertain state. Safe recovery is required before resuming paid ingress. Restore only from validated isolated snapshots.
7. **Sustained soak:** operate 30 synthetic mixed device identities (Wi-Fi, two independent Windows controllers, Android rental lease fixtures) with network loss, process restarts and concurrent requests. Performance, accuracy, and lost/duplicate ACK counts require genuine captured measurements; do not report synthetic input as successful real device enrollment.

Each physical platform should complete **at least 10 independent power interruptions at each of five checkpoint classes** (including post-commit/ACK-lost), plus a 24-hour isolated mixed-client run before being considered for field qualification. More iterations may be necessary for SSD wear-leveling, flash translation layers or flaky power supplies. These are minimum proposed acceptance targets, not completed test claims.

## v1 financial migration design gate (do not execute on customer data yet)

1. **No live conversion without explicit release approval.** Freeze coin/rental/Windows incoming writes, let in-flight events resolve and obtain evidence that no writer or pending unacknowledged event remains. If a pending/uncertain payment exists, block migration and reconcile manually.
2. Take encrypted **off-device** snapshot of existing v1 member, account, voucher, rental, controller replay and audit records, configuration and owner credentials through an owner-reviewed backup process. Do not print sensitive payloads into Actions logs or Git.
3. Under a throwaway synthetic copy first, perform deterministic mapping with an immutable migration ID/source snapshot digest, idempotent per-record identity and collision rules. Refuse unknown columns, duplicate owners, out-of-range seconds, corrupt history, key mismatches or ambiguous receipt status; do not silently reset credit to zero.
4. Check exact conservation across every supported unit: total banked seconds, active paid session expiry policy, outstanding rental lease time, unredeemed vouchers, controller high-water/event receipt history, and pending refunds/chargebacks; a cash amount is not interchangeable with seconds without a locked rate revision.
5. Stage v2 files on the same scratch filesystem, fsync file and parent directories, write a non-bypassable migration commit marker referencing the source digest and destination digest. Any interrupted conversion remains resolvable to exactly one authoritative version; no dual writer and no automatic replay before reconciliation.
6. Validate restoration in both directions **using the untouched encrypted source snapshot** and original signer/identity. A rollback must not discard paid v2 transactions made since migration; require quiescence and a replay/reconciliation plan before falling back.
7. Record manual owner sign-off separately for money integrity, operational recovery and native Android Lineage-2 Device Owner enrollment. All three are required before production promotion.

**Current state:** No v1-to-v2 migration converter or owner-approved rollback has passed a real hardware/financial cutover. This checklist is acceptance design only.

## Evidence record (one per target *and* physical trial)

Store a redacted immutable JSON report off-device with:
- `candidate_git_sha`, `build_run_id`, `sdk_job_id`, `package_sha256`, `native_elf_sha256`, `target_arch`, `firmware_version`;
- `hardware_model`, `hardware_revision`, `storage_model`, `persistent_mount_source`, `filesystem_type`, `scratch_only_verified`;
- `test_case`, `trial_index`, `power_controller_event_time`, `fault_checkpoint`, `pre_state_sha256`, `post_state_sha256`;
- `controller_id_redacted`, `event_id_redacted`, `expected_ack_kind`, `actual_ack_kind`, `credit_delta_seconds`, `total_seconds_before`, `total_seconds_after`, `receipts_consistent`, `replay_duplicate_count`;
- `operator_signoff`, `test_outcome` = `pass` or `fail`, `failure_log_reference`, `recovery_steps`.

Do not store plaintext keys, customer identifying information, production HMACs, transfer-password recovery contents or private Android signing material in these reports or public Git.

## Release NO-GO checklist

**PASS requires actual evidence, not self-assertion.** Any incomplete/failed case leaves `PRODUCTION_v0.6.0_RELEASED=0` and `CUSTOMER_INSTALL_AUTHORIZED=0`.

- [ ] All three named physical targets with persistent-media, power-cut and recovery evidence
- [ ] All shared-ledger financial invariants and duplicate/replay protections confirmed
- [ ] Reversible/quiesced encrypted v1 cutover on disposable copy and owner-approved paid migration
- [ ] 30-client/24h real controller + rental + Windows interoperability and network resilience
- [ ] Permanent Lineage-2 signed Android current/rescue APK, factory-reset Device Owner and standard binding acceptance
- [ ] Exact-SHA release build, installable per-target image/EXE/APK/INO, SHA256SUMS, transparent risk disclosure and owner production sign-off

If interrupted, resume by reviewing `PROJECT_HANDOVER.md`, `docs/handover/CURRENT_STATE.md` and `docs/handover/CHANGE_LEDGER.md`. Do not claim these tests were run merely because this protocol exists.
