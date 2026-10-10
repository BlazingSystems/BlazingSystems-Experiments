## P0-0710 — RED regression candidate, code fix NOT YET APPLIED (2026-10-11 Asia/Manila)

- **State:** IMPLEMENTED_UNTESTED regression, isolated branch `lab/p0-0710-paid-numeric-guard`; parent `ffd069f9cf228ff6dccd564f2b2f59e547e868e3`, five workflows SUCCESS at parent. Pre-change checkpoint `f522c3f4be084b57f8c9ec806c328788ab0e11d2`.
- **Negative source-path fixture:** `tests/v060_paid_numeric_guard.sh` commit `c936fe59aca89d9d2db91421c5f205ca6b417c13`; Full validate insertion `.github/workflows/blazepwifi-build.yml` commit `229f9535e00e3b3b2e3d4a7e2177f1a9c51054cb`. Targets malformed/padded/overlimit member banked seconds, transfer overflow, malformed/padded/overlimit rental lease, padded pulses or configuration; asserts no paid transaction boundary, no state change, no ACK and confirms valid values still reach boundary.
- **Expected RED on old source:** member invalid balances currently reset to 0; rental invalid lease is interpreted as expired, leading-zero/padded quantity can be misparsed. **Actual CI result not yet known.** This is synthetic-only, does not access customer state or authorize v0.6.
- **Next exact action:** Open draft PR, inspect named P0-0710 red step and source-path failure, implement bounded canonical decimal validation before replay and financial mutations, sync handover and rerun exact Full. Keep #31/#32/#34/#43 open and no production release.

---
## P0-0710 — IN PROGRESS: fail closed on malformed paid balances and lease arithmetic (2026-10-11 Asia/Manila)

- **Isolated from verified development** `ffd069f9cf228ff6dccd564f2b2f59e547e868e3` in `lab/p0-0710-paid-numeric-guard`. Main draft PR #30 stays open and protected. Parent exact-HEAD five workflows are SUCCESS: Full #38052381243, Windows #38052381247, SDK #38052381260, native #38052381259, sealed #38052381264.
- **Root cause from live source:** `member.sh:bp_member_balance_change` and `bp_member_transfer` convert any non-decimal stored banked seconds to **zero** rather than refusing the mutation. Member credits and rental leases use POSIX shell arithmetic without prior bounded canonical-decimal checks; octal leading zeros, overflow or malformed on-disk values can produce invalid paid time. Rental `bp_rental_apply_coin` uses stored lease and signed pulse input in arithmetic, and must reject ambiguities before money mutation.
- **Goal:** synthetic-only source-path tests reproduce malformed `NaN`/`000100`/out-of-range member balances, transfer overflow, rental lease/cap overflow and `08` pulses as *non-ACK and no write*. Use bounded canonical decimal range **0..2147483647** (portable signed 32-bit ceiling) and existing 31,536,000-second input cap. Reject invalid persistent member/rental state, never reset paid balances to zero; preserve existing normal inputs and past receipts. Do not change physical prepaid data or unfreeze migration.
- **Paths:** `tests/v060_paid_numeric_guard.sh`, `openwrt/rootfs/usr/lib/blazepwifi/member.sh`, `openwrt/rootfs/usr/lib/blazepwifi/rental.sh`, Full workflow `.github/workflows/blazepwifi-build.yml` test step and canonical handovers. Initial test first, expect it to expose a failure; then narrowly fix source and rerun. Source change and tests must precede final handover sync per `HANDOVER_POLICY.md`.
- **Limitations:** rejecting malformed paid state prevents one silent-loss path but does NOT make separate financial receipts crash-atomic, fix stale backups (#43), or establish power-cut/30-device physical acceptance (#34). Both #31 and #32 remain open. No owner hardware action or actual financial data in this step.
- **NEXT EXACT ACTION:** write isolated negative source-path fixture, confirm red condition against unchanged code; add bounded decimal guards before `bp_paid_begin` and before rental duplicate ACK, run GitHub Full test and compare signed lease/balance outputs, integrate development-only if green. Rollback: revert branch only; no production state affected.

---

## CI-0701 — IMPLEMENTED_AND_VERIFIED (Full CI loop guard only)

- Development branch `blazepwifi-v0.6.0-audit-foundation`, draft PR #30; [PR #47](https://github.com/BlazingSystems/BlazingSystems-Experiments/pull/47) safely fast-forward integrated at `d8e698624abbac8786185c34a35a6cff48995380`. Last exact verified **code-bearing Full SHA** `fd0a4e3689faf4a1f2ac16a0a50793c1d7772210` and [Actions Full #38051770616](https://github.com/BlazingSystems/BlazingSystems-Experiments/actions/runs/38051770616): COMPLETED SUCCESS, 26 pass/4 intentional production skips. New guard ran in `RUN_FULL` mode for real code changes and its negative cases passed.
- [Doc-only sync #38052136719](https://github.com/BlazingSystems/BlazingSystems-Experiments/actions/runs/38052136719) at `d8e698624abbac8786185c34a35a6cff48995380`: COMPLETED SUCCESS; 1 classifier job passed, 19 other Full jobs skipped. Actual log: `SKIP_REDUNDANT_HEAVY`, after verifying prior Full SUCCESS at SHA `fd0a4e3`, PR before/after and source tree unchanged since proof. Manual release candidate/full source changes always run Full. No false production certification.
- Active documents are compact; exact historical PROJECT_HANDOVER/CURRENT_STATE blobs archived under [dated archive](archive/), full append-only [ledger](CHANGE_LEDGER.md) and [policy](HANDOVER_POLICY.md) preserved. The current repo HEAD may have newer docs-only commits; query GitHub for exact HEAD. **No release v0.6.0; VERSION=0.5.3**; stable v0.5.2 frozen. P0 [#31](https://github.com/BlazingSystems/BlazingSystems-Experiments/issues/31), [#32](https://github.com/BlazingSystems/BlazingSystems-Experiments/issues/32), [#34](https://github.com/BlazingSystems/BlazingSystems-Experiments/issues/34), [#43](https://github.com/BlazingSystems/BlazingSystems-Experiments/issues/43) all OPEN. No hardware evidence, independent antirollback witness, customer money mutation or production signing.
- **Remaining CI limitation:** four dedicated Windows/SDK/native/sealed workflows still see PR's cumulative three-dot source diff and can trigger for docs-only head commits. Main Full guards expensive jobs, but whole matrix is not yet optimized.
- **NEXT EXACT ACTION:** apply source-success-verified docs-only PR guard to four remaining dedicated workflows with fail-closed tests, or advance #31/#32 corrupt paid-balance numeric default-to-zero and overflow fixes on synthetic isolated branch. Real P0 #43/#34 require explicitly owner-authorized noncustomer devices; do not claim simulation is field acceptance.
- **NEW CHAT:** @GitHub read this short live state, current branch PR #30 SHA, Full source #38051770616 and docs-only #38052136719; keep 0.6 deployment blocked and proceed from the unresolved next P0/CI task.


---

# BlazePwifi — authoritative active checkpoint

**Status:** IMPLEMENTED_AND_VERIFIED (HND-0700 narrow scope) · 2026-10-10; P0 production blockers still OPEN · 2026-10-10 Asia/Manila
**Repository:** `BlazingSystems/BlazingSystems-Experiments`
**Development:** `blazepwifi-v0.6.0-audit-foundation` · draft [PR #30](https://github.com/BlazingSystems/BlazingSystems-Experiments/pull/30)
**Integrated source revision:** `fd0a4e3689faf4a1f2ac16a0a50793c1d7772210` (CI-0701 guarded Full tested source; HND-0700 previously at `9c02522d91475b42c1fad17975cc52bc48fc6612`) on development; [PR #46](https://github.com/BlazingSystems/BlazingSystems-Experiments/pull/46) merged. The live HEAD may include newer **documentation-only** commits; query the GitHub branch ref, since a commit cannot self-embed its own SHA.
**Source VERSION:** `0.5.3` · public preserved stable release: [v0.5.2](https://github.com/BlazingSystems/BlazingSystems-Experiments/releases/tag/v0.5.2) · [v0.6.0-alpha.4 LAB ONLY](https://github.com/BlazingSystems/BlazingSystems-Experiments/releases/tag/v0.6.0-alpha.4); no customer-ready v0.6.0.
**Latest verified *parent* exact-SHA workflows:** [Full #38047647153](https://github.com/BlazingSystems/BlazingSystems-Experiments/actions/runs/38047647153), [Windows #38047647167](https://github.com/BlazingSystems/BlazingSystems-Experiments/actions/runs/38047647167), [OpenWrt SDK #38047647186](https://github.com/BlazingSystems/BlazingSystems-Experiments/actions/runs/38047647186), [native #38047647160](https://github.com/BlazingSystems/BlazingSystems-Experiments/actions/runs/38047647160), [sealed #38047647179](https://github.com/BlazingSystems/BlazingSystems-Experiments/actions/runs/38047647179): all SUCCESS at `5144f6b`. This is *not* evidence for HND-0700.

## Current blocker matrix

| Issue | Actual current state | Release disposition |
| --- | --- | --- |
| [#31](https://github.com/BlazingSystems/BlazingSystems-Experiments/issues/31) | Legacy member receipt/transfer atomicity and bounded-id replay; native v2 is lab-only | P0 BLOCKED |
| [#32](https://github.com/BlazingSystems/BlazingSystems-Experiments/issues/32) | Rental lease and paid receipt separate persistent mutations; may diverge on crash | P0 BLOCKED |
| [#43](https://github.com/BlazingSystems/BlazingSystems-Experiments/issues/43) | ROLLBACK-0691 reproduces checksum-valid older ledger replay; TRUST-0694/0695 only observe TPM/RPMB candidates, never verified witness | P0 BLOCKED |
| [#34](https://github.com/BlazingSystems/BlazingSystems-Experiments/issues/34) | Physical abrupt power-loss, 30-client soak, migration, Android signing continuity unverified | P0 BLOCKED |

**Production gates:** `VERSION=0.5.3`; 0.6 migration denied; no paid ACK using an unverified witness; `PRODUCTION_v0.6.0_RELEASED=0`; `CUSTOMER_INSTALL_AUTHORIZED=0`; `PHYSICAL_POWER_CUT_VERIFIED=0`. No live customer access, signing secrets, Standalone Rental modifications, production update or release.

## Verified engineering change — HND-0700

- **IMPLEMENTED_AND_VERIFIED in CI** for handover compactness and docs-only GitHub trigger exclusion; not a P0 monetary fix. [Full PR #38050783968](https://github.com/BlazingSystems/BlazingSystems-Experiments/actions/runs/38050783968) SUCCESS at exact source `9c02522d91475b42c1fad17975cc52bc48fc6612` (26 passed, 4 intentional production-only skips, 0 failed). Mandatory handover freshness, `HND-0700` path regression, firmware, x86 QEMU and Android emulator passed. Initial failed #38050659671 revealed comment-handling bug in new regression; corrected at `d32ab244d70ca7907495e8aeeb911aa0ba16ec9a`, failure preserved in ledger.
- **Verified lossless archives:** [old root handover](archive/2026-10-10-PROJECT_HANDOVER-before-compact.md) same Git blob SHA `c39a9926a08debda81f0a5a9f610bd30ccfc0383`; [old live state](archive/2026-10-10-CURRENT_STATE-before-compact.md) same SHA `9086dbcd61e1689363b92112dd9deba76fa014ff`. Full historical [CHANGE_LEDGER](CHANGE_LEDGER.md) and [HANDOVER_POLICY](HANDOVER_POLICY.md) remain intact.
- **Behavior:** Code/tests/workflow edits and mixed source+docs still select Full CI; docs-only `PROJECT_HANDOVER`, `CURRENT_STATE`, `CHANGE_LEDGER`, `AUDIT`, `README` and `docs/**` should not automatically rebuild Full. Manual `workflow_dispatch` remains required for final-candidate verification.
- **No production authorization:** all financial P0 blockers remain, source VERSION still 0.5.3, no customer files, powercuts, signing assets, Standalone Rental or live devices changed. Documentation sync commits after this verified source SHA are explicitly not a fresh source build; confirm by inspecting latest GitHub runs.

## NEXT EXACT ACTION

On a fresh isolated branch from the **current live** `blazepwifi-v0.6.0-audit-foundation` HEAD, inspect `openwrt/rootfs/usr/lib/blazepwifi/member.sh` and `rental.sh` for corrupt paid-state fields being silently defaulted to zero or signed arithmetic overflow. Add synthetic source-path regression for malformed/overlarge balances and ensure no `COMMIT`/`credited` response and no state mutation, then fix narrowly, run exact-SHA GitHub PR Full and guarded integrate if green. **Do not claim this fixes #31/#32 receipt atomicity or #43 freshness.** Hardware witness custody and #34 physical acceptance still require owner-controlled noncustomer equipment.

**New-chat continuation:** @GitHub Read this short CURRENT_STATE first, then PR #30 latest head, Full build result, P0 #31/#32/#34/#43 and the last ledger entry. HND-0700 PR #46 merged to development at source `9c02522d`, exact Full #38050783968 SUCCESS; archives retained. Current live development HEAD must be queried. Start next isolated P0 numeric validation branch. Do not restart audit, do not publish stable v0.6.0.
