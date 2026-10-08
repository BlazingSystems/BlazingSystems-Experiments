# BlazePwifi v0.6.0 production release decision — 2026-10-09 Asia/Manila

**Decision: BLOCKED — no public GitHub v0.6.0 production release; no installation authorized.**

```text
BUILD_MATRIX_SUCCESS=1
WINDOWS_BUILD_SUCCESS=1
PRODUCTION_SIGNING_VERIFIED=0
V060_VERSION_METADATA_READY=0
V060_UPDATER_MIGRATION_READY=0
PREPAID_ACCOUNTING_CORRECTNESS=0
PHYSICAL_HARDWARE_ACCEPTANCE=0
PRODUCTION_RELEASE_PUBLISHED=0
SUCCESS_REPORT=0
```

## Verified exact-source GitHub evidence

- Repo: `BlazingSystems/BlazingSystems-Experiments`; draft PR #30, branch `blazepwifi-v0.6.0-audit-foundation`; inspected implementation SHA `21670d3cf1fe9af8910c712a8b257f5f1061d63f`.
- Full build [run #37815563919](https://github.com/BlazingSystems/BlazingSystems-Experiments/actions/runs/37815563919): **completed SUCCESS**, HEAD `21670d3cf1fe9af8910c712a8b257f5f1061d63f`, including `validate`, firmware/simulations, Android/ESP, and `v04_candidate_gate`. Production signing and publication jobs were SKIPPED.
- Windows SoftTimer [run #37815571724](https://github.com/BlazingSystems/BlazingSystems-Experiments/actions/runs/37815571724): **completed SUCCESS**, same HEAD; `handover` and `build-windows` passed. Windows artifact is labeled v0.4.0; do not relabel it v0.6.0.
- Separate Full run #37815571766 was still in progress at the point checked, but #37815563919 provides an independent completed success on the exact SHA.
- GitHub release lookup `v0.6.0` returned 404 at inspection; do not invent download links.

## Why CI success cannot be promoted to release success

1. Source `VERSION` still says `0.5.3`; Android `build.gradle` still declares `versionCode 50300`, `versionName "0.5.3"`. Tagging these binaries `0.6.0` would be misleading.
2. The `tests/v060_migration_guard.sh` deliberately verifies that existing update.sh rejects `0.6` and `0.6.x` before any paid data mutation. A v0.6 bundle is therefore **not installable via the supported update route**.
3. Real `member.sh` event history replays old coin events after eviction (expected RED). `bp_member_balance_change` may report success if event receipt fails (expected RED). Real `rental.sh` lease credit and event receipt likewise diverge on failed append (expected RED). P0 issues [#31](https://github.com/BlazingSystems/BlazingSystems-Experiments/issues/31) and [#32](https://github.com/BlazingSystems/BlazingSystems-Experiments/issues/32) remain release blockers.
4. The isolated `tools/v060_journal_fixture.sh` and SQLite reference model PASS synthetic tests, but are **not integrated into runtime**. Their unkeyed SHA-256 and Linux `sync` do not prove authenticated, crash-durable account/rental receipts on target flash; no validated owner-approved v1-to-v2 migration.
5. Production Lineage-2 Android current/rescue pairing was not signed and verified for v0.6.0, and device-owner enrollment, installer rollback and real hardware power-cut/coin acceptance have no current verified signoff.

## Required path to SUCCESS_REPORT=1

- Implement a single server-authoritative, authenticated journal for member, rental and ordinary coin credits; preserve durable idempotency floors/receipts across retention and crash.
- Convert all three current *expected RED* runtime tests into required GREEN tests, with storage-full, lost ACK, concurrent and corruption negative tests.
- Execute quiesced, encrypted, owner-verifiable migration and rollback of real v0.5.x persistent state, plus per-target fsync/parent directory behavior; do not ship `update.sh` 0.6 bypass merely to make installation green.
- Complete real hardware tests (Ruijie R281/EW1200G Pro, x86 BIOS/UEFI, supported Orange Pi models and 30-device settlement/power-cut soak), preserve network connectivity/credential identity.
- Set versionCode/versionName and OpenWrt release manifest to 0.6.0, permanently sign current+rescue APKs under verified Lineage-2 identity, verify SHA-256/provenance, require exact-head Full+Windows+hardware gate success, then publish matching installable release assets without changing any old tag.

**No public installation, production tag or permission to risk customer time is granted by the two green development CI workflows.**

Audit continuation: `@GitHub Resume PR #30 P0 #31/#32. Read PROJECT_HANDOVER.md top, CURRENT_STATE.md, CHANGE_LEDGER.md, HANDOVER_POLICY.md, LEDGER_TRANSACTION_V060.md and this release decision. Exact previous Full CI #37815563919 + Windows #37815571724 passed at 21670d3cf1fe9af8910c712a8b257f5f1061d63f but production SUCCESS_REPORT=0. Fix runtime financial journal and physical/signing/migration acceptance; do not tag until ALL release invariants are verified.`
