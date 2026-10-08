# LIVE STATE — BlazePwifi full ecosystem (AUTHORITATIVE)

**Last reconciled (Asia/Manila):** 2026-10-08 19:43+. **Owner order:** full v0.6.0 audit/research, security and native Android/admin UI enhancement, rigorous release; continuous mandatory handover logging before and after every meaningful change. **Status:** `HANDOVER POLICY IMPLEMENTED / EXACT-SHA RETEST PENDING / RELEASE BLOCKED`.

## Identity / current pointers (not historical snapshots)

| Field | Verified value / interpretation |
|---|---|
| Repository | `BlazingSystems/BlazingSystems-Experiments` |
| Active development branch | `blazepwifi-v0.6.0-audit-foundation` |
| Original v0.6.0 PR source baseline | `d99f9b7b1ac10f183659c97c156fe4c939863cf8` (historical, not latest HEAD) |
| Draft PR | [#30](https://github.com/BlazingSystems/BlazingSystems-Experiments/pull/30), base `blazepwifi-v0.5.3-rc1` |
| Exact base branch SHA checked | `4879c38f3f0e676f17ac40d73cb59c87ffcb5762` (v0.5.3 RC1 security baseline) |
| Full project's on-disk VERSION | **`0.5.3`**, not `0.6.0`. Android still has v0.5.3 version metadata. No legitimate production v0.6.0 APK or manifest exists. |
| Existing frozen full production | [`v0.5.2`](https://github.com/BlazingSystems/BlazingSystems-Experiments/releases/tag/v0.5.2) |
| Existing separate standalone release | [`v0.5.2-rental.2-rc.9`](https://github.com/BlazingSystems/BlazingSystems-Experiments/releases/tag/v0.5.2-rental.2-rc.9) — reference only, DO NOT TOUCH |
| Android signer | `BlazeRental-production-lineage2`, pinned SHA-256 cert `1A:18:D5:8E:1F:95:55:96:89:10:20:71:F5:6C:93:E9:B9:D2:EA:6B:E4:0E:6F:20:70:06:C9:89:62:A1:6A:25`. Never rotate, regenerate or expose private material. |
| Release state | **No v0.6.0 production tag, release, signed APK, device-owner production QR assets or new firmware assets.** Development code and CI artifacts must not be described as installable production releases. |

*Important:* subsequent handover-only commits will advance the branch HEAD. Before resuming, query GitHub and confirm it; the source baseline SHA above is evidence for the v0.6.0 source **before** those documentation commits. Don't mistake it for the latest branch HEAD.

## Latest exact-source validation results and current blocking failure

- **Full system**: [BlazePwifi build #37770673219](https://github.com/BlazingSystems/BlazingSystems-Experiments/actions/runs/37770673219), HEAD `d99f9b7b1ac10f183659c97c156fe4c939863cf8`, **FAILED**. Required validation, Android APK builds, Android Device Owner emulator, ESP8266/ESP32, Ruijie, x86, Orange Pi, updater and hardware simulations completed successfully, but `v04_browser_simulation` failed in `simulation/browser_v04_audit.py` at line 381, `page.click('button:has-text("Bind existing BlazeRental")')`, after 30s timeout. The v0.6.0 UI intentionally renamed this button to **Generate binding QR** and factory provision to **Generate Device Owner QR**. The failure blocks `v04_candidate_gate`, which was skipped. The parallel run #37770667993 failed identically. **Do NOT claim full matrix green.**
- **Windows PisoNet**: [SoftTimer run #37770673126](https://github.com/BlazingSystems/BlazingSystems-Experiments/actions/runs/37770673126), same exact source HEAD `d99f9b7b1ac10f183659c97c156fe4c939863cf8`, **SUCCESS** including warning-as-error compile, `--verify-timer-math`, self-contained Windows x64 EXE and NSIS setup, install/uninstall smoke, portable archive and candidate artifact upload. Production Windows release upload is skipped on a PR. Separate manual electrical/clock tests still required.
- **Prior compatible baseline**: v0.5.3 security/QR fixes from PR #29 merged to RC1 as `4879c38f3f0e676f17ac40d73cb59c87ffcb5762` after green source CI #37765240497. This is **not** a v0.6.0 release.
- **Current documentation-policy work:** item HND-0600, in progress. Mandatory policy, full live state/ledger and root current-status are committed. `tests/handover_gate.sh` was created in commit `c27593ca4f272432118ac37fe74c5dab755eec08` and `.github/workflows/blazepwifi-build.yml` now runs it before static validation with `fetch-depth: 0` (commit `2cc802a7c44785aa35fde7079d8e4160b0a1759f`). **Implemented, not yet CI-validated.** No business runtime changed by handover-enforcement code.

## Ongoing work register — no ambiguous "done" claims

| ID / priority | State | Implemented and where | Pending evidence / next |
|---|---|---|---|
| HND-0600 / P0 | IMPLEMENTED / CI PENDING | Policy, three canonical files, fail-closed gate (`c27593ca...`), full-history CI (`2cc802a7...`), exact SHA evidence artifact even on failure (`1e92fd13...`), README continuity repair (`500c6d28...`) | sync checkpoint then verify all jobs on exact HEAD; audit failure-evidence artifact schema and stale-source negative test |
| BROWSE-0601 / P1 | SOURCE FIX COMMITTED / RETEST PENDING | `simulation/browser_v04_audit.py` selectors fixed to `Generate binding QR` and `Generate Device Owner QR` in `da87ad69f2706cec2b71fb7cb6254d5d241c1b7e` | run Playwright and exact-SHA full CI; verify distinct type and token assertions still pass |
| BILL-0602 / P0 | IMPLEMENTED / CI GREEN (Windows) | `experiment/windows/BlazePisonet-SoftTimer/src/BlazePisonet.SoftTimer/TimerEngine.cs`, `Program.cs`, workflow | verify native installer operation on actual PCs, suspended timer and 60min electrical cadence, central-slot and 1:1 modes |
| ID-0603 / P1 | IMPLEMENTED / TEST GREEN in validate | Public `openwrt/rootfs/www/blazepwifi/cgi-bin/api` rejects user-supplied MAC when router ARP lookup unavailable | physical VLAN13 AP bridge/routed/WAN IPv6 identity mapping and denial UX; NEVER restore spoofable MAC fallback |
| QR-0604 / P1 | IMPLEMENTED / STATIC & CI partial | Separate binding/Device Owner UI, TTL/clear QR, URL validation under admin/rental.js, rental_update.sh | test Android factory reset scanner, permanent signer/hash and local TLS pin; APK not yet 0.6.0 |
| UI-0605 / P2 | IMPLEMENTED / BROWSER RECHECK BLOCKED | native `BlazeAdminActivity.java`, `RentalSystemPages.java`; operator `admin.html`, `admin/core.js`, `vendor/tailadmin/blaze-tailadmin.css` | browser Playwright, mobile contrast/keyboard, real Android launcher UI and Device Owner policy |
| RESEARCH-0606 / P1 | DOCUMENTED / NOT COMPETITIVELY BENCHMARKED | `AUDIT.md` includes JuanFi, AdoPiSoft, MikroTik User Manager, OpenNDS, Antamedia, HandyCafe, TrueCafe | compare functionality and lab performance on equal hardware; no superiority claim without measurement |
| RELEASE-0607 / P0 | BLOCKED | 0.5.3 VERSION and v0.5.3 signer/release workflow are still live in branch | explicit 0.6.0 semver/versionCode/migration, exact green 0.6.0 gate, signed APK+rescue with existing signer, hardware acceptance, checksum manifest and rollback |

## Non-negotiable invariants

1. No transactions are silently duplicated, erased, converted or unaccounted. Concurrent coinslots must not cross-credit sessions, even through ACK loss and power cuts.
2. Server-authoritative time, pause, membership and rental policy; Windows local/remote mode authority explicitly distinguished. A 250ms callback may never charge an entire second.
3. No generic universal production admin password, secret logging or source-upload of recovery keys. Secure session/CSRF/rate-limiting and role enforcement must persist across all web routes.
4. **Binding QR** is an existing-app enrollment token, lower security. **Device Owner QR** is factory setup provisioning plus pinned TLS, signed APK and verified hash; neither is interchangeable. Avoid falsely promising zero bypass.
5. Dedicated `profiles/standalone-rental` and released tags stay untouched. Both standard and centralized PisoNet modes remain supported by separate Windows source tree.
6. All firmware/installer builds must use the intended physical revision and safe rollback; preserve Windows EXE as an EXE, not a PowerShell-only handoff.
7. Run tests on exact head, review complete artifacts, and never claim green/released when critical job is failed, skipped, canceled or pending.
8. Keep this document, `PROJECT_HANDOVER.md` top status and `CHANGE_LEDGER.md` synchronized **after each meaningful change**. New chat reads this file first after root handover.

## Live transition — BROWSE-0601 source fix

- Committed `simulation/browser_v04_audit.py` UI selectors repair at SHA `da87ad69f2706cec2b71fb7cb6254d5d241c1b7e`. The original Playwright check still asserts distinct **binding** and **device_owner** QR results, valid token metadata and signed APK details; no assertion was disabled.
- Validation **pending on a new exact SHA**; older #37770673219 failure remains historical evidence only.
- **Next now:** after the three handover documents are synchronized, review the newest BlazePwifi Actions run's `validate` handover gate and `v04_browser_simulation`. If green, verify final `v04_candidate_gate`; if failed, log step/error before another source write.

## Live transition — HND-0600 gate implementation checkpoint

- Source/workflow changes: `tests/handover_gate.sh` commit `c27593ca4f272432118ac37fe74c5dab755eec08`; `.github/workflows/blazepwifi-build.yml` commit `2cc802a7c44785aa35fde7079d8e4160b0a1759f`.
- Gate verifies full-history checkout, current/ledger/policy existence and most recent source/workflow diff does not postdate **any** of the three required handover checkpoints.
- **Latest CI evidence is still the old baseline:** Windows run #37770673126 PASS, Full build #37770673219 FAIL. No green evidence yet for the newly added handover gate.
- **NEXT NOW:** update `simulation/browser_v04_audit.py` stale two QR button selectors and add tests for the new two-choice dialog; then synchronize canonical docs again, inspect exact-head CI and carry forward any blockers.

## Live transition — CI evidence, README and handover regression changes

- CI workflow implementation `1e92fd13cbbd997fd33594444705c7d23c371159`: `validate` now emits a non-secret `BlazePwifi-ci-handover-evidence` artifact even if tests fail. It contains canonical handover copies and `CI_HANDOVER.json` (workflow/run attempt/Git SHA/job result/branch/version); **never** treat the `validate` status in that JSON as the overall 26-job gate conclusion.
- Public `README.md` commit `500c6d281dfe8517fed91891f13b79e122c99221`: corrected stale advertised production 0.3.0 to verified full v0.5.2, distinct standalone RC9, correct active v0.6.0 PR, native Android and TailAdmin-inspired admin paths and Windows EXE integration.
- **Source changes are committed, full latest CI not yet approved.** The last published production release remains v0.5.2. Handover checkpoint commits advance HEAD without changing implementation.
- **NEXT NOW:** verify newly synchronized exact HEAD `validate` handover gate, `v04_browser_simulation` repaired QR labels, Android Device Owner emulator and candidate gate; record passed/failed/skipped job IDs, and do not confuse isolated validation with full production release.

## NEXT EXACT ACTION — safe resume sequence

1. **DONE IN SOURCE, NOT YET VERIFIED:** HND-0600 gate created and first BlazePwifi CI step configured with full Git history. After the next documentation checkpoint, confirm an exact-SHA `validate` job passes. Test a negative scenario by changing a source file after a previous checkpoint and confirm the gate fails without weakening it.
2. **DONE IN SOURCE, NOT YET VERIFIED:** BROWSE-0601 selector repair in `simulation/browser_v04_audit.py` commit `da87ad69f2706cec2b71fb7cb6254d5d241c1b7e`; verify both existing binding and factory-reset Device Owner flows actually run in the new exact-SHA browser CI. Keep QR type/token/hash checks intact.
3. Create a new checkpoint in `CHANGE_LEDGER.md` and update `PROJECT_HANDOVER.md` + this live state with exact new source commits, test outcomes and NEXT ACTION. The last handover commit must succeed the last implementation commit before CI can be green.
4. Check the new **exact commit SHA** and its [GitHub Actions branch history](https://github.com/BlazingSystems/BlazingSystems-Experiments/actions?query=branch%3Ablazepwifi-v0.6.0-audit-foundation), diagnose any remaining failures by job logs, and reconcile doc statuses immediately. Keep PR #30 draft and block release while any critical gate is not green.
5. After these gates, proceed with financial ledger, binding identity, Android Device Owner hardware testing and a separate v0.6.0 version/migration/signing/release train. Do not prematurely tag.

## Audit & Reconcile prompt for the next chat

```text
@GitHub Reconcile the active full BlazePwifi v0.6.0 branch of
BlazingSystems/BlazingSystems-Experiments. Begin with
experiment/openwrt/BlazePwifi/PROJECT_HANDOVER.md (CURRENT STATUS at TOP),
docs/handover/CURRENT_STATE.md, docs/handover/HANDOVER_POLICY.md,
docs/handover/CHANGE_LEDGER.md, AUDIT.md and the draft PR #30.
Verify actual branch SHA, base SHA, exact head CI and recent commits.
Check the latest NEXT EXACT ACTION and unresolved blocker IDs.
Keep all changes on the isolated branch, log the work BEFORE code edits,
and synchronize the three handover documents AFTER every meaningful change.
Do not touch standalone rental, frozen release tags, signer or company data.
Run exact-SHA CI, never confuse build artifacts with signed production assets,
never call v0.6.0 released while blocked.
```

## 2026-10-08 update: documentation checkpoint testing

- Source commit `e02474f150b5ac4be18fb2c05edf4cffa69e4957` adds a temporary Git-history test for complete versus incomplete handover synchronization.
- Workflow commit `8140a4e1c80d45e61d2612e9a664afea5777cb1c` adds that test to validation.
- State: committed, awaiting a successful exact-commit CI run. No release decision has changed.
- Next action: synchronize the change ledger and root handover, then inspect the validation, browser, and candidate-gate jobs.
