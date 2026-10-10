## CI-0701 — CURRENT IN-FLIGHT WORK (IMPLEMENTED_UNTESTED)

- Isolated `lab/v060-ci-synchronize-guard` from development `9e7c2bc819769ad1be1480f283557da0685c6329`. HND-0700 path filters alone were insufficient for draft PR #30 because GitHub computes a three-dot diff against the PR base and relaunched Full [#38051302219](https://github.com/BlazingSystems/BlazingSystems-Experiments/actions/runs/38051302219) for docs-only edits.
- Exact CI-0701 source workflow `3f472115f1706d06f8e7886bf9dfd7fcfc65cec3`, read-only docs-sync verifier `8bea894c`+fix `b6d841e`, synthetic negative tests `ed2e375`. Only a docs-only PR synchronize with independently verified earlier successful Full source SHA may skip expensive Full jobs; unknown/error/source/mixed/manual requests ALWAYS run Full.
- **No verified CI yet for CI-0701.** Keep PR draft until Full and classifier run pass; P0 #31/#32/#34/#43 remain blocked, VERSION=0.5.3, customer v0.6 installation DENIED. The other four dedicated workflows still require their own safe guards.
- **NEXT:** read short [CURRENT_STATE](docs/handover/CURRENT_STATE.md), create/check CI-0701 isolated PR Full, inspect real gate output and fix actual failures, guarded integrate only on success. Never interpret this as production accounting fix.

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
