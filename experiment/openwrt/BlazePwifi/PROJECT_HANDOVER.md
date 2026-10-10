## P0-0710 — CORRECTED / CI PENDING (2026-10-11 Asia/Manila)

- Actual [Full #38075975085](https://github.com/BlazingSystems/BlazingSystems-Experiments/actions/runs/38075975085) FAILED legacy signed member replay test before new P0-0710 step: `bank=5 transfer=3`. New transfer existence precheck masked signed transfer ID recipient collision (expected rc=5). Source `member.sh` commit `10d65a5ccc42bd30394ba8f2bd399a45bcaa9525` restores collision precedence without allowing malformed paid bank ACK; **TESTS ON CORRECTED HEAD PENDING**.
- Negative arithmetic fixture and bounded member/rental source guards are committed to isolated PR #48, not integrated into main development. Strict P0 #31/#32/#34/#43 remain OPEN, VERSION 0.5.3, production v0.6.0 NO-GO.
- NEXT: check PR #48 latest Full job `v060_member_quarantine_replay.sh` and named `P0-0710` regression, plus Android/x86 simulations; only guarded development integration on verified success. Read concise [CURRENT_STATE](docs/handover/CURRENT_STATE.md).

---

## P0-0710 — IMPLEMENTED_UNTESTED: strict prepaid numeric guards (2026-10-11 Asia/Manila)

- **Isolated branch:** `lab/p0-0710-paid-numeric-guard` from verified dev `ffd069f9cf228ff6dccd564f2b2f59e547e868e3`. Production P0 #31/#32/#34/#43 remain OPEN. Full CI RED reproduction at parent-source **PR #48** [#38075722430](https://github.com/BlazingSystems/BlazingSystems-Experiments/actions/runs/38075722430): `P0-0710 reject malformed ...` failed with `P0-0710 RED: member add accepted unsafe Fixture A (rc=9)`. The fixture printed the overwritten production `label` (cosmetic); a marker proves the malformed input reached `bp_paid_begin` despite a nonzero rc. This is a source-path synthetic reproduction, not hardware proof.
- **Tests:** `tests/v060_paid_numeric_guard.sh` added at `c936fe59aca89d9d2db91421c5f205ca6b417c13`, test assertion/global variable collision corrected at `661c97cf85284c4d94af15c7c3c29ce1fb5b0da4`. Full `.github/workflows/blazepwifi-build.yml` runs named negative step since `229f9535e00e3b3b2e3d4a7e2177f1a9c51054cb`. Invalid member amount, persisted NaN, padded octal, overflow, transfer destination overflow, invalid rental lease, pulses, and seconds-per-pulse rate must fail with **no marker/ACK/mutation**; valid values must reach boundary. Tests not yet green.
- **Actual source correction, unverified:** `openwrt/rootfs/usr/lib/blazepwifi/member.sh` commit `063f5e73f0c5ea0f29901771ad379576a3dd6bf7` validates canonical decimal balances and 0..2,147,483,647 upper limit before replay ACK, converts no corrupt stored balance to zero, checks addition/transfer capacity before arithmetic/transaction start; input amount cap remains 31,536,000. `openwrt/rootfs/usr/lib/blazepwifi/rental.sh` commit `f749995ce9bd2743c85fe25492dfa43d0bc8dd5f` rejects invalid persisted lease/duplicate receipt/pulses/setting, caps summed lease at signed32 maximum, validates before transaction start.
- **Strict safety:** no real ledger, coin acceptance, firmware, signer, Standalone Rental, migration or customer install accessed. `VERSION=0.5.3`, `CUSTOMER_INSTALL_AUTHORIZED=0`, `PHYSICAL_POWER_CUT_VERIFIED=0`, `PRODUCTION_v0.6.0_RELEASED=0`. This is small **containment**, not a journal/atomic receipt fix or independent antirollback.
- **NEXT EXACT ACTION:** run exact-head GitHub PR Full CI for P0-0710 after this combined handover checkpoint, inspect named P0-0710 step and existing member/rental tests. Fix any genuine regression, then integrate guarded non-force to development only if Full passes. Update issues #31/#32 with results and leave both P0 OPEN. Owner hardware action remains necessary for #34/#43.

---

## P0-0710 — RED regression candidate, code fix NOT YET APPLIED (2026-10-11 Asia/Manila)

- **State:** IMPLEMENTED_UNTESTED regression, isolated branch `lab/p0-0710-paid-numeric-guard`; parent `ffd069f9cf228ff6dccd564f2b2f59e547e868e3`, five workflows SUCCESS at parent. Pre-change checkpoint `f522c3f4be084b57f8c9ec806c328788ab0e11d2`.
- **Negative source-path fixture:** `tests/v060_paid_numeric_guard.sh` commit `c936fe59aca89d9d2db91421c5f205ca6b417c13`; Full validate insertion `.github/workflows/blazepwifi-build.yml` commit `229f9535e00e3b3b2e3d4a7e2177f1a9c51054cb`. Targets malformed/padded/overlimit member banked seconds, transfer overflow, malformed/padded/overlimit rental lease, padded pulses or configuration; asserts no paid transaction boundary, no state change, no ACK and confirms valid values still reach boundary.
- **Expected RED on old source:** member invalid balances currently reset to 0; rental invalid lease is interpreted as expired, leading-zero/padded quantity can be misparsed. **Actual CI result not yet known.** This is synthetic-only, does not access customer state or authorize v0.6.
- **Next exact action:** Open draft PR, inspect named P0-0710 red step and source-path failure, implement bounded canonical decimal validation before replay and financial mutations, sync handover and rerun exact Full. Keep #31/#32/#34/#43 open and no production release.

---
## CI-0701 — IMPLEMENTED_AND_VERIFIED (Full CI loop guard only)

- Development branch `blazepwifi-v0.6.0-audit-foundation`, draft PR #30; [PR #47](https://github.com/BlazingSystems/BlazingSystems-Experiments/pull/47) safely fast-forward integrated at `d8e698624abbac8786185c34a35a6cff48995380`. Last exact verified **code-bearing Full SHA** `fd0a4e3689faf4a1f2ac16a0a50793c1d7772210` and [Actions Full #38051770616](https://github.com/BlazingSystems/BlazingSystems-Experiments/actions/runs/38051770616): COMPLETED SUCCESS, 26 pass/4 intentional production skips. New guard ran in `RUN_FULL` mode for real code changes and its negative cases passed.
- [Doc-only sync #38052136719](https://github.com/BlazingSystems/BlazingSystems-Experiments/actions/runs/38052136719) at `d8e698624abbac8786185c34a35a6cff48995380`: COMPLETED SUCCESS; 1 classifier job passed, 19 other Full jobs skipped. Actual log: `SKIP_REDUNDANT_HEAVY`, after verifying prior Full SUCCESS at SHA `fd0a4e3`, PR before/after and source tree unchanged since proof. Manual release candidate/full source changes always run Full. No false production certification.
- Active documents are compact; exact historical PROJECT_HANDOVER/CURRENT_STATE blobs archived under [dated archive](archive/), full append-only [ledger](CHANGE_LEDGER.md) and [policy](HANDOVER_POLICY.md) preserved. The current repo HEAD may have newer docs-only commits; query GitHub for exact HEAD. **No release v0.6.0; VERSION=0.5.3**; stable v0.5.2 frozen. P0 [#31](https://github.com/BlazingSystems/BlazingSystems-Experiments/issues/31), [#32](https://github.com/BlazingSystems/BlazingSystems-Experiments/issues/32), [#34](https://github.com/BlazingSystems/BlazingSystems-Experiments/issues/34), [#43](https://github.com/BlazingSystems/BlazingSystems-Experiments/issues/43) all OPEN. No hardware evidence, independent antirollback witness, customer money mutation or production signing.
- **Remaining CI limitation:** four dedicated Windows/SDK/native/sealed workflows still see PR's cumulative three-dot source diff and can trigger for docs-only head commits. Main Full guards expensive jobs, but whole matrix is not yet optimized.
- **NEXT EXACT ACTION:** apply source-success-verified docs-only PR guard to four remaining dedicated workflows with fail-closed tests, or advance #31/#32 corrupt paid-balance numeric default-to-zero and overflow fixes on synthetic isolated branch. Real P0 #43/#34 require explicitly owner-authorized noncustomer devices; do not claim simulation is field acceptance.
- **NEW CHAT:** @GitHub read this short live state, current branch PR #30 SHA, Full source #38051770616 and docs-only #38052136719; keep 0.6 deployment blocked and proceed from the unresolved next P0/CI task.


---

# BlazePwifi integrated ecosystem — active handover

## AUTHORITATIVE LIVE LINKS

1. **Start here:** [Concise current engineering checkpoint](docs/handover/CURRENT_STATE.md). The exact current GitHub branch HEAD must be queried live, not inferred from this document or a previous chat.
2. **Audit trail:** [Append-only change ledger](docs/handover/CHANGE_LEDGER.md) and [active handover policy](docs/handover/HANDOVER_POLICY.md).
3. **Unmodified pre-compact history:** [2,032-line original PROJECT_HANDOVER](docs/handover/archive/2026-10-10-PROJECT_HANDOVER-before-compact.md) and [2,142-line original CURRENT_STATE](docs/handover/archive/2026-10-10-CURRENT_STATE-before-compact.md); both copied losslessly on the isolated branch, no history discarded.
4. **Live software work:** [Draft v0.6.0 PR #30](https://github.com/BlazingSystems/BlazingSystems-Experiments/pull/30), `blazepwifi-v0.6.0-audit-foundation`. Never merge to main solely because GitHub synthetic CI passes.

## CURRENT STATUS — HND-0700

**As of 2026-10-10 Asia/Manila; engineering classification: IMPLEMENTED_AND_VERIFIED for HND-0700 only, production P0 still BLOCKED.**

- Repository: `BlazingSystems/BlazingSystems-Experiments`. Development parent SHA before HND-0700: `5144f6bbe950d2f484088ff40b618818ce979e1b`. Merged [PR #46](https://github.com/BlazingSystems/BlazingSystems-Experiments/pull/46) from isolated `lab/v060-compact-handover-ci` to dev at exact tested source SHA `9c02522d91475b42c1fad17975cc52bc48fc6612`; documentation-only checkpoint commits follow. Current branch HEAD is retrieved live.
- Source `VERSION=0.5.3`; stable frozen [v0.5.2](https://github.com/BlazingSystems/BlazingSystems-Experiments/releases/tag/v0.5.2). [v0.6.0-alpha.4](https://github.com/BlazingSystems/BlazingSystems-Experiments/releases/tag/v0.6.0-alpha.4) is LAB ONLY, **not production v0.6.0**.
- Exact verified **parent** workflows at `5144f6b`: [Full #38047647153](https://github.com/BlazingSystems/BlazingSystems-Experiments/actions/runs/38047647153), [Windows #38047647167](https://github.com/BlazingSystems/BlazingSystems-Experiments/actions/runs/38047647167), [SDK #38047647186](https://github.com/BlazingSystems/BlazingSystems-Experiments/actions/runs/38047647186), [native #38047647160](https://github.com/BlazingSystems/BlazingSystems-Experiments/actions/runs/38047647160), [sealed #38047647179](https://github.com/BlazingSystems/BlazingSystems-Experiments/actions/runs/38047647179): all SUCCESS. **HND-0700 initial Full #38050659671 FAILED its new YAML-comment regression; corrected at `d32ab244d70ca7907495e8aeeb911aa0ba16ec9a`. New [exact-source Full #38050783968](https://github.com/BlazingSystems/BlazingSystems-Experiments/actions/runs/38050783968) COMPLETED SUCCESS: 26 passed, 4 intentional skips, 0 failures, including HND-0700, handover gate, Android emulator and x86 QEMU.**
- HND-0700 VERIFIED: replaced oversized live documentation with concise links while retaining exact historical text in dated archives; Full `.github/workflows/blazepwifi-build.yml` push/PR paths exclude documentation-only, not money/source/tests/workflow changes; added fixture-negative `tests/v060_ci_doc_only_filter.py` to Full `validate`. Manual workflow_dispatch and full source gates remain intact.
- P0 blockers: [#31](https://github.com/BlazingSystems/BlazingSystems-Experiments/issues/31) (member durability), [#32](https://github.com/BlazingSystems/BlazingSystems-Experiments/issues/32) (rental lease/receipt), [#43](https://github.com/BlazingSystems/BlazingSystems-Experiments/issues/43) (unverified independent antirollback witness and older-ledger replay), [#34](https://github.com/BlazingSystems/BlazingSystems-Experiments/issues/34) (physical acceptance + migration + Android signing). All OPEN. No physical evidence, paid ledger migration or permanent signer attached.
- `CUSTOMER_INSTALL_AUTHORIZED=0`, `PHYSICAL_POWER_CUT_VERIFIED=0`, `PRODUCTION_v0.6.0_RELEASED=0`; 0.6 updater preflight **DENIED**. No live money writes, firmware flash, production signing, Standalone Rental or unrelated experiments touched.

## NEXT EXACT ACTION

HND-0700 integrated only into development, no stable release. Verify that current documentation-only checkpoint does **not** trigger a new Full build. Next source task: on a fresh isolated branch, add synthetic negative tests and narrowly fix `member.sh` corrupt-balance default-to-zero / overflow and `rental.sh` malformed lease arithmetic without confusing this with full receipt-atomicity or independent antirollback protection. Run exact PR Full and integrate guarded. P0 #31/#32/#34/#43 remain OPEN.

## SAFE RESUME PROMPT

@GitHub CONTINUE Full BlazePwifi in `BlazingSystems/BlazingSystems-Experiments`. Read `experiment/openwrt/BlazePwifi/docs/handover/CURRENT_STATE.md` first, check draft PR #30 and isolated HND-0700 work, verify latest HEAD + exact-SHA CI, review open P0 #31/#32/#34/#43. Never restart the audit; do not ship alpha as production or touch frozen Standalone Rental.
