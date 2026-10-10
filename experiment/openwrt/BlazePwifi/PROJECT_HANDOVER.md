# BlazePwifi integrated ecosystem — active handover

## AUTHORITATIVE LIVE LINKS

1. **Start here:** [Concise current engineering checkpoint](docs/handover/CURRENT_STATE.md). The exact current GitHub branch HEAD must be queried live, not inferred from this document or a previous chat.
2. **Audit trail:** [Append-only change ledger](docs/handover/CHANGE_LEDGER.md) and [active handover policy](docs/handover/HANDOVER_POLICY.md).
3. **Unmodified pre-compact history:** [2,032-line original PROJECT_HANDOVER](docs/handover/archive/2026-10-10-PROJECT_HANDOVER-before-compact.md) and [2,142-line original CURRENT_STATE](docs/handover/archive/2026-10-10-CURRENT_STATE-before-compact.md); both copied losslessly on the isolated branch, no history discarded.
4. **Live software work:** [Draft v0.6.0 PR #30](https://github.com/BlazingSystems/BlazingSystems-Experiments/pull/30), `blazepwifi-v0.6.0-audit-foundation`. Never merge to main solely because GitHub synthetic CI passes.

## CURRENT STATUS — HND-0700

**As of 2026-10-10 Asia/Manila; engineering classification: IMPLEMENTED_UNTESTED until CI actually passes.**

- Repository: `BlazingSystems/BlazingSystems-Experiments`. Development parent SHA before HND-0700: `5144f6bbe950d2f484088ff40b618818ce979e1b`. Isolated branch `lab/v060-compact-handover-ci`. Latest source/test commit `368879c05c291aa0ea34e3e98ce58916b7fa7fb9` (test authored at `b04485ee403f260d25fb73b3b78f33ddc287a8b4`); document-only checkpoint commits follow.
- Source `VERSION=0.5.3`; stable frozen [v0.5.2](https://github.com/BlazingSystems/BlazingSystems-Experiments/releases/tag/v0.5.2). [v0.6.0-alpha.4](https://github.com/BlazingSystems/BlazingSystems-Experiments/releases/tag/v0.6.0-alpha.4) is LAB ONLY, **not production v0.6.0**.
- Exact verified **parent** workflows at `5144f6b`: [Full #38047647153](https://github.com/BlazingSystems/BlazingSystems-Experiments/actions/runs/38047647153), [Windows #38047647167](https://github.com/BlazingSystems/BlazingSystems-Experiments/actions/runs/38047647167), [SDK #38047647186](https://github.com/BlazingSystems/BlazingSystems-Experiments/actions/runs/38047647186), [native #38047647160](https://github.com/BlazingSystems/BlazingSystems-Experiments/actions/runs/38047647160), [sealed #38047647179](https://github.com/BlazingSystems/BlazingSystems-Experiments/actions/runs/38047647179): all SUCCESS. **HND-0700 has no observed CI yet.**
- HND-0700: replaced oversized live documentation with concise links while retaining exact historical text in dated archives; Full `.github/workflows/blazepwifi-build.yml` push/PR paths exclude documentation-only, not money/source/tests/workflow changes; added fixture-negative `tests/v060_ci_doc_only_filter.py` to Full `validate`. Manual workflow_dispatch and full source gates remain intact.
- P0 blockers: [#31](https://github.com/BlazingSystems/BlazingSystems-Experiments/issues/31) (member durability), [#32](https://github.com/BlazingSystems/BlazingSystems-Experiments/issues/32) (rental lease/receipt), [#43](https://github.com/BlazingSystems/BlazingSystems-Experiments/issues/43) (unverified independent antirollback witness and older-ledger replay), [#34](https://github.com/BlazingSystems/BlazingSystems-Experiments/issues/34) (physical acceptance + migration + Android signing). All OPEN. No physical evidence, paid ledger migration or permanent signer attached.
- `CUSTOMER_INSTALL_AUTHORIZED=0`, `PHYSICAL_POWER_CUT_VERIFIED=0`, `PRODUCTION_v0.6.0_RELEASED=0`; 0.6 updater preflight **DENIED**. No live money writes, firmware flash, production signing, Standalone Rental or unrelated experiments touched.

## NEXT EXACT ACTION

Check HND-0700 isolated PR and GitHub Full CI at the *exact latest source SHA*; read the `HND-0700` validate step, handover freshness and x86/Android results, correct failures, then guarded non-force integration **development branch only**. Verify a follow-up docs-only change is excluded from the Full workflow without hiding mixed/source changes. Record evidence in the ledger and concise live checkpoint. Then advance the smallest real #31/#32 P0 runtime correction with failure tests; do not substitute additional TPM-presence demos for independent witness custody.

## SAFE RESUME PROMPT

@GitHub CONTINUE Full BlazePwifi in `BlazingSystems/BlazingSystems-Experiments`. Read `experiment/openwrt/BlazePwifi/docs/handover/CURRENT_STATE.md` first, check draft PR #30 and isolated HND-0700 work, verify latest HEAD + exact-SHA CI, review open P0 #31/#32/#34/#43. Never restart the audit; do not ship alpha as production or touch frozen Standalone Rental.
