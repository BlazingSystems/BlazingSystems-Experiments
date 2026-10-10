# BlazePwifi — authoritative active checkpoint

**Status:** IMPLEMENTED_UNTESTED · HND-0700 compact-handover + documentation-only CI filtering · 2026-10-10 Asia/Manila
**Repository:** `BlazingSystems/BlazingSystems-Experiments`
**Development:** `blazepwifi-v0.6.0-audit-foundation` · draft [PR #30](https://github.com/BlazingSystems/BlazingSystems-Experiments/pull/30)
**Isolated work branch:** `lab/v060-compact-handover-ci` from exact development HEAD `5144f6bbe950d2f484088ff40b618818ce979e1b`. Read the current GitHub branch ref for the latest HEAD; a commit cannot self-embed its own SHA.
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

## Active engineering change — HND-0700

**IMPLEMENTED_UNTESTED; no CI evidence yet.** Root cause: Full `.github/workflows/blazepwifi-build.yml` watches `experiment/openwrt/BlazePwifi/**` without excluding pure documentation and thus documentation-only checkpoints rebuild costly firmware/Android targets. Source files remain unchanged. Two exact historical files were losslessly copied *before replacing* active summaries:
- [Old PROJECT_HANDOVER](archive/2026-10-10-PROJECT_HANDOVER-before-compact.md) (559,909 characters, preserved)
- [Old CURRENT_STATE](archive/2026-10-10-CURRENT_STATE-before-compact.md) (716,248 characters, preserved)
- Complete [append-only CHANGE_LEDGER](CHANGE_LEDGER.md) and [HANDOVER_POLICY](HANDOVER_POLICY.md) retained.

**Implemented:** `.github/workflows/blazepwifi-build.yml` at `368879c05c291aa0ea34e3e98ce58916b7fa7fb9` excludes docs-only Full CI triggers; `tests/v060_ci_doc_only_filter.py` at `b04485ee403f260d25fb73b3b78f33ddc287a8b4` negatively tests excluded documentation and positively tests money paths, workflow changes, and mixed source+docs. Full workflow still has the handover gate, normal tests and `workflow_dispatch`. Root compact handover `a9f48b0ac26a76ee27ec290e82c96988836edb59`. All changes pending exact-source CI confirmation.

**Risk / rollback:** possible accidental exclusion of meaningful source change; test both mixed docs+source and docs-only filters. Revert HND-0700 branch for failure, restore old handovers exactly from archives, do not touch monetary state. New workflow configuration requires validation on branch before guarded dev integration.

## NEXT EXACT ACTION

Run exact HND-0700 PR Full CI and inspect the `HND-0700` regression, mandatory handover freshness, x86 QEMU and Android results. Then guard against concurrent dev updates and integrate to development only on success. Finally append verified evidence to the change ledger and update this short active summary **once**, as a docs-only commit; verify that change does not launch Full CI. Never mislabel untested work green.

**Independent next P0 engineering task:** reopen actual source and failure-injection cases for #31/#32; select one implementation site that can be safely changed without a fake hardware witness. Owner-controlled isolated physical trust/powercut and permanent Android signing are *required* for production, but unavailable through GitHub.

**New-chat continuation:** @GitHub Read this short CURRENT_STATE first, then PR #30 latest head, Full build result, P0 #31/#32/#34/#43 and the last ledger entry. HND-0700 branch `lab/v060-compact-handover-ci` source is IMPLEMENTED_UNTESTED; archives intact; check exact CI before integration. Do not restart audit, do not publish stable v0.6.0.
