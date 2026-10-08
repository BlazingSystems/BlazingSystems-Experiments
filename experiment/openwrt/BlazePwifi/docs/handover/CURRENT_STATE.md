# LIVE STATE — BlazePwifi full ecosystem (AUTHORITATIVE)

**Last reconciled (Asia/Manila):** 2026-10-08 19:43+. **Owner order:** full v0.6.0 audit/research, security and native Android/admin UI enhancement, rigorous release; continuous mandatory handover logging before and after every meaningful change. **Status:** `HANDOVER POLICY VERIFIED / DEVELOPMENT CI GREEN / RELEASE BLOCKED`.

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

## Exact-head development verification and historical failures

- **LATEST FULL DEVELOPMENT CODE GATE — SUCCESS:** [BlazePwifi Actions #37774312541](https://github.com/BlazingSystems/BlazingSystems-Experiments/actions/runs/37774312541) on source/document checkpoint `d1e7fb4187e2d0701f4e2b5c842c8711eb09d756`: **26 successful jobs, 0 failed**. Includes early handover freshness gate, stale/partial-doc regression, static/security/accounting stress, browser real Playwright QR, native Android compilation, Device Owner emulator, ESP8266/ESP32, Ruijie, required Orange Pi, x86 QEMU, update bundle and `v04_candidate_gate` **SUCCESS**. Intentional production sign/publish jobs were skipped. This is **development CI for on-disk VERSION 0.5.3**, not a signed 0.6.0 release. Development candidate gate artifact ID `11548973355`.
- **LATEST WINDOWS GATE — SUCCESS:** [SoftTimer Actions #37774312533](https://github.com/BlazingSystems/BlazingSystems-Experiments/actions/runs/37774312533) on same SHA: both `handover` and `build-windows` SUCCESS, including headless 60-minute prepaid timer test, EXE, NSIS installer, install/uninstall and portable package. Existing immutable `softtimer-v0.4.0` release untouched; separate hardware use required.
- **Handovers verified:** required handover gate and negative regression passed. `BlazePwifi-ci-handover-evidence` attached to full run, artifact ID `11548837388`, includes `CI_HANDOVER.json` and canonical source snapshots. This status JSON represents **validate** only; the full run above separately proves all critical jobs. The default `main` now routes new chats to this active branch via documentation-only main commit `9ee502d6e53da505e680bedb6be935c5f6a7446f`.
- **Note for future work:** documentation-only checkpoint commits after `d1e7fb41...` advance the branch HEAD. The completed green run proves the cited source tree, **not** an untested later runtime change. Review Git diff and newest Actions for the new head.

### Superseded failure (retain as audit evidence)


- **Full system**: [BlazePwifi build #37770673219](https://github.com/BlazingSystems/BlazingSystems-Experiments/actions/runs/37770673219), HEAD `d99f9b7b1ac10f183659c97c156fe4c939863cf8`, **FAILED**. Required validation, Android APK builds, Android Device Owner emulator, ESP8266/ESP32, Ruijie, x86, Orange Pi, updater and hardware simulations completed successfully, but `v04_browser_simulation` failed in `simulation/browser_v04_audit.py` at line 381, `page.click('button:has-text("Bind existing BlazeRental")')`, after 30s timeout. The v0.6.0 UI intentionally renamed this button to **Generate binding QR** and factory provision to **Generate Device Owner QR**. The failure blocks `v04_candidate_gate`, which was skipped. The parallel run #37770667993 failed identically. **SUPERSEDED: a later exact-source run #37774312541 has now passed. Do not reuse the earlier failed run as current status.**
- **Windows PisoNet**: [SoftTimer run #37770673126](https://github.com/BlazingSystems/BlazingSystems-Experiments/actions/runs/37770673126), same exact source HEAD `d99f9b7b1ac10f183659c97c156fe4c939863cf8`, **SUCCESS** including warning-as-error compile, `--verify-timer-math`, self-contained Windows x64 EXE and NSIS setup, install/uninstall smoke, portable archive and candidate artifact upload. Production Windows release upload is skipped on a PR. Separate manual electrical/clock tests still required.
- **Prior compatible baseline**: v0.5.3 security/QR fixes from PR #29 merged to RC1 as `4879c38f3f0e676f17ac40d73cb59c87ffcb5762` after green source CI #37765240497. This is **not** a v0.6.0 release.
- **Current documentation-policy work:** item HND-0600, in progress. Mandatory policy, full live state/ledger and root current-status are committed. `tests/handover_gate.sh` was created in commit `c27593ca4f272432118ac37fe74c5dab755eec08` and `.github/workflows/blazepwifi-build.yml` now runs it before static validation with `fetch-depth: 0` (commit `2cc802a7c44785aa35fde7079d8e4160b0a1759f`). **Verified by #37774312541 and Windows #37774312533, including negative fixture and handover evidence artifact.** No business runtime was changed by the handover enforcement itself.

## Ongoing work register — no ambiguous "done" claims

| ID / priority | State | Implemented and where | Pending evidence / next |
|---|---|---|---|
| HND-0600 / P0 | VERIFIED ON CODE SHA d1e7fb41 | Root/live/ledger policy, full-history gate, stale/partial-history negative fixture, protected Windows prerequisite and always-on CI evidence artifact | Require future runtime changes to re-synchronize three docs before CI; review evidence quality manually |
| BROWSE-0601 / P1 | VERIFIED IN PLAYWRIGHT | `simulation/browser_v04_audit.py` QR selector fix `da87ad69...` | Browser job #37774312541 passed; real physical Android two enrollment paths remain unverified |
| BILL-0602 / P0 | IMPLEMENTED / CI GREEN (Windows) | `experiment/windows/BlazePisonet-SoftTimer/src/BlazePisonet.SoftTimer/TimerEngine.cs`, `Program.cs`, workflow | verify native installer operation on actual PCs, suspended timer and 60min electrical cadence, central-slot and 1:1 modes |
| ID-0603 / P1 | IMPLEMENTED / TEST GREEN in validate | Public `openwrt/rootfs/www/blazepwifi/cgi-bin/api` rejects user-supplied MAC when router ARP lookup unavailable | physical VLAN13 AP bridge/routed/WAN IPv6 identity mapping and denial UX; NEVER restore spoofable MAC fallback |
| QR-0604 / P1 | IMPLEMENTED / STATIC & CI partial | Separate binding/Device Owner UI, TTL/clear QR, URL validation under admin/rental.js, rental_update.sh | test Android factory reset scanner, permanent signer/hash and local TLS pin; APK not yet 0.6.0 |
| UI-0605 / P2 | WEB/ANDROID EMULATOR CI GREEN | Native Android launcher/admin, responsive operator web and live actual-session metrics | Browser Playwright and emulator passed; still need phone screenshots, keyboard and contrast on real devices |
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

1. Confirm that the newest branch head contains only the post-validated handover checkpoint changes relative to code SHA `d1e7fb4187e2d0701f4e2b5c842c8711eb09d756`. Do not substitute a later documentation-only SHA for an exactly validated production release SHA.
2. Begin a dedicated `0.6.0` **version-and-migration plan**: identify persistent file schemas, auth/member/rental controller protocol compatibilities, production installer rollback, Android `versionCode` greater than frozen rescue `50301`, and preserve permanent Lineage-2 signing key. No release tag until migration and rescue are proven.
3. Prioritize P0 hardware/financial verification: real 60-minute Windows SoftTimer; power cuts mid-coin ACK/replay; one-slot/many-PC arbitration; concurrent rental+Wi-Fi payments; VLAN13 bridge/routed identity; device-owner Android factory-reset/standard binding on actual OEM hardware.
4. Before each new code change, register it IN PROGRESS in this live state, then update `CHANGE_LEDGER.md` and root `PROJECT_HANDOVER.md` with actual code SHA and exact CI evidence. Required handover gate must keep passing; keep PR #30 draft.
5. On the full `0.6.0` release train, run an exact SHA candidate gate + same-signer signed APK/rescue + firmware installers + checksums + upgrade/rollback dry runs + real hardware acceptance. Until then **RELEASE BLOCKED**.

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

## NEW IN PROGRESS — WIN-GATE-0609 / P0

- Verified published GitHub Release `softtimer-v0.4.0` currently contains `BlazePisonet-SoftTimer-Setup-v0.4.0.exe`, the portable ZIP and `SHA256SUMS`. The Windows workflow's `Publish GitHub Release` step currently uses `gh release upload ... --clobber` on `main`, which could overwrite frozen v0.4.0 artifacts when newer Windows code is merged without a version bump.
- Windows-only PRs run `.github/workflows/blazepisonet-softtimer-release.yml` but do not necessarily run BlazePwifi's mandatory handover gate. This leaves a cross-platform documentation enforcement gap.
- State: **fix committed, CI verification pending**. Windows workflow commit `326d67e88db690ad9e83e855fc3136d2498cbb61` adds a Linux handover prerequisite (including stale/partial-history checks), blocks main-branch v0.4.0 auto-publish, and rejects replacement of an existing release tag. Existing published assets remain unchanged.
- NEXT: synchronize ledger and root status after the Windows workflow commit; check the **two-job Windows CI** (handover prerequisite then native build/NSIS smoke), along with the Full BlazePwifi matrix on the exact checkpoint SHA. Do not touch existing releases.

## 2026-10-08 verified checkpoint — main discovery and immutable release guard

- Main-branch documentation-only routing pointer `9ee502d6e53da505e680bedb6be935c5f6a7446f` makes this active handover discoverable to all new chats opening the default branch; it does not merge v0.6 code into main.
- Windows workflow immutability patch `326d67e88db690ad9e83e855fc3136d2498cbb61` is confirmed by successful exact-code Windows run #37774312533. Previously released setup EXE/ZIP/checksums under `softtimer-v0.4.0` remain unmodified.
- Full development run #37774312541 and Windows run #37774312533 both SUCCESS on `d1e7fb4187e2d0701f4e2b5c842c8711eb09d756`; no v0.6.0 production signing or publishing happened. The next code change starts a **new** exact-head verification requirement.

## MIG-0610 — P0 upgrade-transaction safety work (IN PROGRESS)

- **Finding from source 2026-10-08:** `openwrt/rootfs/usr/lib/blazepwifi/update.sh` applies payload and subsequently runs `update-migrate.sh "$previous" "$version" || true`, so failed migration is ignored and can be promoted as healthy. Current rollback snapshot saves only manifest-listed system files; it does **not** automatically revert mutations to `/etc/config/blazepwifi`, `/etc/blazepwifi/state`, member banks or rental identities. `update-migrate.sh` already changes UCI configuration. Potential data loss or silent partial migration is not acceptable for v0.6.0.
- **Intended narrow source change:** add a pre-apply gate that refuses 0.6.0 family upgrade bundles until transactional state migration/recovery exists, without altering existing 0.5.x update paths. Must run before payload swap, snapshot, or any persistent-state mutation and report a clear error. Only a later reviewed migration implementation may remove/replace the guard.
- **Required proof:** negative test on a synthetic 0.6.0 bundle confirms no target file, pending state, or account balance is changed; positive 0.5.x compatibility test continues passing. Add to early `validate`, record exact source/test SHAs, and synchronize root/current/ledger before CI can pass.
- **Risk and rollback:** no changes to published firmware/tag/secret/actual appliance; if gate unexpectedly breaks 0.5.x, revert the isolated branch commit. No 0.6.0 production release until full state snapshot, migration, backout, power-cut and schema test coverage exists.
- **NEXT:** implement fail-closed preflight in `update.sh`, add read-only isolation regression, wire CI and record outcomes. After this, version/schema inventory and backup/restore design, not immediate APK signing.
