## CI-0701 — IN PROGRESS: stop repeat Full builds on verified docs-only PR synchronization

- **Scope/branch:** isolated `lab/v060-ci-synchronize-guard` from development `9e7c2bc819769ad1be1480f283557da0685c6329`; original HND-0700 source validated at `9c02522d91475b42c1fad17975cc52bc48fc6612`, Full #38050783968 COMPLETED SUCCESS. P0 #31/#32/#34/#43 still open; no production authorization.
- **Newly observed actual defect:** GitHub Full PR run #38051302219 was launched on documentation-only dev head `9e7c2bc...` despite `paths` negations, because PR uses a **three-dot cumulative branch/base diff**, not the change from previous head. Other dedicated workflows also relaunched. Push path filtering helps but cannot prevent this.
- **Intent:** source-controlled, fail-closed lightweight classifier for `pull_request:synchronize` that compares actual before/after commit changes and permits skipping costly Full jobs ONLY IF latest update is documentation-only, source tree since an immutable known successful Full SHA differs only in excluded documentation, and GitHub API confirms that SHA's exact Full run SUCCESS. If any event field, commit, ancestry, API verification or source path check is unknown → run Full. Always run on workflow_dispatch and actual code/source changes; the `HND-0700` regression is not removed.
- **Affected paths:** `tools/v060_ci_docs_classifier.py`, `tests/v060_ci_docs_classifier.py`, `.github/workflows/blazepwifi-build.yml`, three current handover files. No other workflows initially changed; their PR three-dot behavior remains tracked. Risk: mistaken job suppression. Negative tests must prove changed money code, mixed commits, stale baseline, absent API or unknown event fail **toward full CI**, never silence.
- **NEXT EXACT ACTION:** Implement classifier and test using synthetic Git file lists and mocked GitHub responses, run classifier as mandatory small job before expensive Full jobs, verify new PR exact source Full build and negative fixtures. Do not claim all five workflows are fixed by main Full guard. Future dedicated Windows/SDK/native/sealed PR triggers require independent equivalent protection.
- **Rollback:** revert this isolated CI guard; previous mandatory Full tests and customer data remain intact.

---

# BlazePwifi — authoritative active checkpoint

**Status:** IMPLEMENTED_AND_VERIFIED (HND-0700 narrow scope) · 2026-10-10; P0 production blockers still OPEN · 2026-10-10 Asia/Manila
**Repository:** `BlazingSystems/BlazingSystems-Experiments`
**Development:** `blazepwifi-v0.6.0-audit-foundation` · draft [PR #30](https://github.com/BlazingSystems/BlazingSystems-Experiments/pull/30)
**Integrated source revision:** `9c02522d91475b42c1fad17975cc52bc48fc6612` on development; [PR #46](https://github.com/BlazingSystems/BlazingSystems-Experiments/pull/46) merged. The live HEAD may include newer **documentation-only** commits; query the GitHub branch ref, since a commit cannot self-embed its own SHA.
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
