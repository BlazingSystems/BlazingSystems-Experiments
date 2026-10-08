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
- **Implemented / CI pending:** source commit `20fc51350fa1b6de11c695f70cde83b73d2e786b` adds pre-apply `bp_update_preflight_release` in `update.sh` to reject the 0.6 family before snapshot/stable/payload writes. New tests `tests/v060_migration_guard.sh` commit `e25e95602fbddf39c8d8844778cb2e20adc17eeb` verify 0.6 variants reject with target/ledger/stable/pending untouched and 0.5.3 apply/rollback remains supported. Workflow `ca36f2e17df5e3ef5b339f341a5aefdc5d994022` makes the test mandatory. These changes have not yet passed their exact-source CI.
- **Required proof:** negative test on a synthetic 0.6.0 bundle confirms no target file, pending state, or account balance is changed; positive 0.5.x compatibility test continues passing. Add to early `validate`, record exact source/test SHAs, and synchronize root/current/ledger before CI can pass.
- **Risk and rollback:** no changes to published firmware/tag/secret/actual appliance; if gate unexpectedly breaks 0.5.x, revert the isolated branch commit. No 0.6.0 production release until full state snapshot, migration, backout, power-cut and schema test coverage exists.
- **NEXT:** after synchronizing all three handover documents, verify `v0.6 migration preflight and 0.5 rollback safety`, earlier v0.5.1/v0.5.2 update tests and final exact-head CI. If green, next phase is building an actual transaction journal/snapshot/recovery implementation rather than disabling the guard or publishing 0.6.0.

## MIG-0610 source checkpoint — version identity and migration contract

- `docs/RELEASE_0.6.0_MIGRATION.md`, commit `46e4f73a05516b9d1d100ddebba823b241529e8a`: identified source VERSION `0.5.3`, embedded `/usr/share/blazepwifi/VERSION` `0.5.2`, Android `50300/0.5.3`, and defined financial ledger/config/device identity persistence + migration freeze/snapshot/journal/rollback obligations. Do not rename binaries or tag a release while these are unresolved.
- **Code/test committed but CI not yet verified:** updater safety gate `20fc51350fa1b6de11c695f70cde83b73d2e786b`; test `e25e95602fbddf39c8d8844778cb2e20adc17eeb`; CI requirement `ca36f2e17df5e3ef5b339f341a5aefdc5d994022`. No deployed account or production release is touched.
- **NEXT EXACT ACTION:** checkpoint root+ledger after these commits, check exact-head workflow's `validate` test and complete matrix. A failing update compatibility test must be diagnosed and recorded, not bypassed.

## Verified exact-source MIG-0610 result and new SYS-0612 P0 pre-change record

- **MIG-0610 VERIFIED in development CI:** [BlazePwifi run #37776446840](https://github.com/BlazingSystems/BlazingSystems-Experiments/actions/runs/37776446840) **COMPLETED SUCCESS** on `541282869753dc2b64058c45a162ab4b96e83be9`: 26 jobs passed, 0 failed, `validate` included v0.6 migration fail-closed regression and v0.5.x compatibility, Android Device Owner emulator, Ruijie/Orange Pi/x86 simulation and candidate gate. [Windows #37776446835](https://github.com/BlazingSystems/BlazingSystems-Experiments/actions/runs/37776446835) SUCCESS both jobs on identical SHA. This is the last green *source* checkpoint, not a 0.6.0 signed release.
- **SYS-0612 / P0 / RESEARCH CONFIRMED — IN PROGRESS:** OpenWrt documentation explicitly warns that sysupgrade wipes custom files not included in its preserve set. Current BlazePwifi `openwrt/rootfs/` has no `lib/upgrade/keep.d/blazepwifi` or `etc/sysupgrade.conf` declaration. Full firmware sysupgrade could therefore fail to retain `/etc/blazepwifi/state` (paid accounts, vouchers, member banks, rental identity/keys, remote keys), `/etc/blazepwifi/portal`, and the pinned local TLS certificate/key. This is distinct from the overlay updater and a **NO-GO for field firmware release**. Official references: https://openwrt.org/docs/guide-user/installation/generic.sysupgrade and https://openwrt.org/docs/techref/sysupgrade.
- **Intended bounded fix:** add package-owned `openwrt/rootfs/lib/upgrade/keep.d/blazepwifi` entries for `/etc/config/blazepwifi`, `/etc/blazepwifi/state`, `/etc/blazepwifi/portal`, `/etc/uhttpd.crt` and `/etc/uhttpd.key`; allow **only this exact file** in `bp_update_path_allowed` so deployed 0.5.x overlay upgrade installs preservation policy. Never overwrite an operator's `/etc/sysupgrade.conf`, and do not auto-include huge `/etc/blazepwifi/update/snapshots` in tiny-device sysupgrade archives. Add tests for critical paths, whitelist scope and inclusion in generated overlay bundle.
- **Remaining unknowns:** on-device `sysupgrade -l` file list, actual payload size, hardware flash availability, boot/restore after factory flash, local HTTPS fingerprint continuity, and private off-device backup. Those require physical verification and must not be claimed green based on source-only testing.
- **NEXT:** commit only scoped preserve-list and whitelist, add mandatory tests, synchronize root/current/ledger, run exact-head CI. Do not upgrade live devices or publish signed 0.6.0 binaries.

## SYS-0612 implemented checkpoint — source and CI pending final result

- **Preservation policy:** `openwrt/rootfs/lib/upgrade/keep.d/blazepwifi` commit `9bdd8196d811226ca4feccc963b398b6ade59cee`, exact five path entries for router config, paid/device state, portal and local TLS cert/key. Intentionally excludes unbounded `update/snapshots` and does not overwrite `/etc/sysupgrade.conf`.
- **Overlay update compatibility:** `openwrt/rootfs/usr/lib/blazepwifi/update.sh` commit `e7ac3d55a9c71b92b8e6039287ba3c5a0ba6077f` permits precisely `/lib/upgrade/keep.d/blazepwifi`, not arbitrary keep.d paths; earlier v0.6 migration block remains enabled.
- **Regression:** `tests/v060_sysupgrade_preservation.sh` commit `d16ce84af7cd1958ef7a2feb87d983ad8438728d` checks required path coverage, no broad snapshots, exact updater whitelist and presence in a newly built overlay update tarball. Workflow `.github/workflows/blazepwifi-build.yml` commit `3537df27ea66caa2969951c2a510b5bd8fbc4f5c` requires it.
- **Migration contract expanded:** `docs/RELEASE_0.6.0_MIGRATION.md` commit `d675773097fe51629946ba24fedebd6b86ce6f10` documents OpenWrt full-firmware versus overlay distinction, operator-performed `sysupgrade -l`/size/restore proof and Android current/rescue version-code ordering (e.g. 60000/60001).
- **State:** implementation committed, **NOT YET exact-head CI-verified or real-router tested**. The earlier full green #37776446840 + Windows #37776446835 were on the previous code SHA `541282869753dc2b64058c45a162ab4b96e83be9`; the new source change requires another full run. No installed customer state or shipped release asset was modified.
- **NEXT EXACT ACTION:** synchronize change ledger and root handover, then inspect the newest exact SHA `validate` including preservation test, full firmware/Android matrix, and Windows EXE pipeline. Any failed test needs a logged, narrowly reviewed fix before further release work.

## UI-FUSION-0613 — CoreUI React + Metis uploaded source reconciliation (IN PROGRESS)

- **Authorized source:** user-supplied `coreui-react-v1.0.0.zip` (193 entries, ~1.62 MB expanded) and `metis-v1.0.0.zip` (184 entries, ~3.92 MB expanded), locally inspected 2026-10-08. Both top-level licenses declare MIT; source details inside identify **CoreUI template package 5.7.0** with React 19/Redux/Vite and **Metis template package 3.6.0** with Bootstrap 5.3/Alpine/ApexCharts/Vite. Archive filenames do not match internal package versions. Their initial ZIP traversal audit found no unsafe paths. No dependency install, code execution or public artifact redistribution has yet been done.
- **Design decision:** use a shared offline **BlazeFusion** admin UI design layer informed by both styles: compact CoreUI dashboard/information hierarchy and calm Metis forms/tables/typography, with responsive, accessible controls. Do NOT load two independent JS SPA runtimes, bypass BlazePwifi CGI authentication or CSRF, or require Node/React/Vite on low-memory Ruijie/R281 routers. Use local static CSS and optional JS presentation-only mode selection over existing TailAdmin-inspired console. Enterprise React shell can be built later for PC/Orange Pi only, after separate API adapter/security approval.
- **Implementation committed / exact-head CI pending:** Full `openwrt/rootfs/www/blazepwifi/admin.html` (`ba3b40e0...`), `vendor/blazefusion/blaze-fusion.css` (`526fa903...`) and `blaze-fusion.js` (`ff4f3af2...`) introduce one offline CoreUI×Metis-inspired appearance, with Fusion/Compact/Comfort modes and persistent nonsecret preferences. Playwright test `simulation/browser_v04_audit.py` (`64b8bfda...`) tests change/reload/preserved QR workflow; static security smoke `tests/v060_ui_fusion.sh` (`578a858c...`) and required CI step (`0b4dfec6...`) added. Design and subsystem rollout contract `docs/UI_BLAZEFUSION_0.6.0.md` (`6b14e463...`). No change to business API/auth/payment logic and no bundled React or Alpine. Standalone/Lite/EasyMode/Windows/Android/ESP native adaptations remain **not implemented**. Existing owner QR / binding, roles, payments, billing and remote access must remain unchanged.
- **Licensing/privacy:** locally synthesized design rules, no third-party bundle copied wholesale; preserve existing TailAdmin LICENSE and record original CoreUI/Metis MIT source provenance in a new doc. Avoid uploading user archives, vendor source scripts, advertising graphics, credentials, sample accounts or unnecessary dependencies to public GitHub.
- **Prior verified checkpoint:** full #37777931329 COMPLETE SUCCESS (26 green) and Windows #37777940814 (2 green) on `9969958da0e7b590a376dce23c23b32fbf2020db`. After any UI source write, old runs are historical, not current approval.
- **NEXT EXACT ACTION:** after synchronizing root/current/ledger, inspect the new exact-head BlazePwifi `validate` ‘BlazeFusion offline and authenticated UI integration smoke’ and `v04_browser_simulation` Playwright mode-reload/QR result; check the full Android/firmware candidate gate and Windows 2-job CI. If any fail, log the precise step and patch conservatively. Once green, record the completed source SHA and stop safely before subsystem-specific rollout. 0.6 signed release and physical data/money recovery still BLOCKED.

## UI-FUSION-0613 implementation checkpoint (requires new exact-SHA validation)

- Uploaded ZIPs audited locally; no upstream runtime or mock login copied. CoreUI package version 5.7.0 (React) and Metis package 3.6.0 (Bootstrap/Alpine), both MIT. Folder names `*-v1.0.0.zip` are upload names, not internal versions. No credential or third-party source archive has been pushed.
- Source commits: `526fa90373352476778f6fb32ed0a5590dae6796` CSS, `ff4f3af28fe24726a4bed81c31d6e41f3000e45f` JS, `ba3b40e0dbed9fd488633527b1cee48b93874521` HTML, `64b8bfdad4a2688a21f7634f06cd1eabf32ed0a6` Playwright, `578a858c0280d13e72c4e4d26f82aedb71551f3d` shell test, `0b4dfec666d0ca3b3160c8ad5e8185cb1445d239` CI and `6b14e46391f793ea870e4386a7b820c6da0e74ff` architecture/lifecycle doc.
- Prior exact-source sysupgrade/full firmware green #37777931329 and Windows #37777940814 were **26+2 SUCCESS** on `9969958da0e7b590a376dce23c23b32fbf2020db`; those do NOT validate the new UI code. Keep 0.6 release P0 barriers and production tags untouched.
- Next safe stop: synchronously checkpoint three handovers, wait for the actual new CI result, log any failure and resulting fixes in all three handovers; only mark UI-FUSION-0613 green when exact full CI is successful. The uploaded framework integration is **Full web frontend only** at this checkpoint; independent subsystems require careful adaptation rather than wholesale runtime replacement.

## UI-FUSION-0613 responsive continuation (source committed, retest pending)

- Added a ≤540px safe mobile header adaptation in `vendor/blazefusion/blaze-fusion.css`, commit `375b26f97a94779acb005633d48366fe0c8f59f0`: hide redundant local-control/user text, preserve visible Log out, avoid overflow for appearance chooser. This does not hide account recovery or billing buttons.
- Extended real Playwright `simulation/browser_v04_audit.py` commit `41c7e58bf0e4177c33fdf809697df0e85e165429` to assert no document-width overflow at 360px/390px then restore desktop viewport before existing rental/Device Owner tests.
- **No new successful full-source CI claim yet**. Any green on earlier source SHA `35852c874f678660775333d44eef38a779f3c587` predates this responsive source. Align all three handovers after source edits, then verify latest exact-SHA `validate` and `v04_browser_simulation`. If mobile assertion fails, preserve proof and fix precisely. Production 0.6.0 release remains blocked by migration/recovery and physical validation.

## UI-FUSION-0614 — Standalone Rental opt-in interface adaptation (IN PROGRESS)

- **Reason:** owner requests one coherent BlazePwifi/BlazeRental/PisoNet visual family, retaining distinct secure business engines. Full BlazeFusion source checkpoint `b24fe3747913d1aae4802acd7958ca638f537eec` passed Full `validate`/Playwright and Windows two-job CI; as of last check full matrix #37796743126/#37796759105 still waiting for old Orange Pi jobs (no failures observed).
- **Source audit:** `profiles/standalone-rental/openwrt/rental-standalone.html` is a separately installed **single self-contained HTML** with inline CSS and JS, served by an independent `profiles/standalone-rental/openwrt/install.sh` which copies only the page and QR code file to `/rental/`. Adding an external CSS bundle without changing the installer would silently break offline rendering. The standalone page already uses different routes `/cgi-bin/blaze-rental-admin` and `/cgi-bin/blaze-rental-profile` and must not accidentally load Full `/cgi-bin/admin` or replace its login/lease security. The existing separate published standalone release `v0.5.2-rental.2-rc.9` remains immutable.
- **Scope:** isolated source-branch appearance-only inlined BlazeFusion tokens and an accessible Fusion/Compact/Comfort selector in the Standalone operator topbar, matching the Full browser key `blazepwifi.console.appearance.v1`; no frameworks/CDNs or endpoint changes; no coin/balance/QR/auth backend edits. Keep log out visible on mobile. Add a regression static gate and, if practical, real browser layout evidence.
- **Release/rollback:** no actual installer/release tag updated; revert only Standalone source commit if offline UI tests regress. Mandatory static/standalone and full CI gates must pass on exact-head commit. Physical phone use and security review required before publishing.
- **IMPLEMENTED; exact-head CI still pending:** Standalone single-file Fusion/Compact/Comfort commit e885b5ba8ddf5392cf56f0b55aba6a1ce8bf71d3. Static and installer safety smoke 9970b2c6b1a55658ec9b1391ffb5a5c8aea2a5d5; Chromium mock-HTTPS UI security regression 39c3317396110eb6ca3b494fe1647f7ca941ee9f; mandatory CI steps 5bcaefd93e750cb3e083cdbda800e363d166b6e5; cross-system UI contract af4e80d3fdeac2eeeb295feae5070e769272ced6. No installer, CGI, enrollment or money backend edit. NEXT: sync all handovers then verify exact-head validate, v04_browser_simulation and Windows workflows. If fail, record job and stage before changing code.

## UI-FUSION-0614 exact commit log — safe continuation checkpoint

- Developer edits: e885b5ba8ddf5392cf56f0b55aba6a1ce8bf71d3 (inline Standalone UI); 9970b2c6b1a55658ec9b1391ffb5a5c8aea2a5d5 (static smoke); 39c3317396110eb6ca3b494fe1647f7ca941ee9f (browser test); 5bcaefd93e750cb3e083cdbda800e363d166b6e5 (required workflow); af4e80d3fdeac2eeeb295feae5070e769272ced6 (architecture note).
- Previous Full BlazeFusion CI #37796743126 and #37796759105 were CANCELLED after more commits (each passed original static/Playwright but was not fully completed); previous Windows #37796759250 was SUCCESS at earlier SHA b24fe374..., and does NOT verify the Standalone changes. The new exact-head test must be used instead.
- Browser test is mock-HTTPS and read-only, with no production customer data. Assert theme/reload, mobile 360/390px width, sign-out visibility and no unauthorized API/money mutation. Keep PR #30 draft; frozen standalone RC9 tag and binaries remain unchanged.
- NEXT EXACT ACTION: synchronize root + ledger after source writes, inspect latest branch-head CI. On failure investigate exact job log, repair only failing subsystem, and synchronize handovers again. Do not claim real rental-device/coin money test from this mock.

## UI-FUSION-0614 real Chromium failure diagnosis — P1 (IN PROGRESS)

- On exact SHA 75d88c87b844d1d3f73469ff757317847234d303, BlazePwifi Actions #37799066752 job v04_browser_simulation ID 113386892960 FAILED. Full browser audit passed first; separate standalone_fusion_browser.py line 91 asserted document.scrollWidth <= 390+2 and failed with `AssertionError: Standalone rental page overflows mobile viewport 390`. Source/theme static validate PASS. No backend/security/money failure. Artifact #11559034502 contains partial browser evidence.
- Root cause under investigation: small-screen Standalone CSS uses a 12-track `repeat(12,1fr)` grid and auto min-content sizing, which can expand grid items beyond viewport. Planned fix: change small-screen tracks to minmax(0,1fr), bound flex/grid min-width and use explicit content wrapping; *never mask real overflow via overflow-x:hidden*. Improve regression error output to print offending bounding-box element selectors/widths if any persist.
- NEXT: patch only standalone HTML responsive CSS and browser diagnostics, then resync root/current/ledger, run latest exact-head browser test, confirm 360 and 390 mobile and original rentals. All production releases frozen.

## UI-FUSION-0614 responsive fix checkpoint — exact CI outstanding

- P1 UI browser failure on source SHA 75d88c87b844d1d3f73469ff757317847234d303: Full source Playwright passed, standalone Chromium `standalone_fusion_browser.py` FAILED in v04_browser_simulation job 113386892960 on Actions #37799066752, 390px document overflow at line 91. No account/QR security regression or backend mutation reported. Prior Full validate and standalone static test were green.
- Corrective CSS commit 52da18e6ea1d314158edd7ffc0daaf909a9d39ef introduces responsive minmax(0,1fr) tracks, constrained nested grid/flex minimum widths, wrap of long device/server values, and retains visible controls. No overflow-x:hidden masking. Test diagnostic commit d616c16b4c41bc3870352e647978d0b8471d7a23 captures actual viewport/scroll width and offending elements on next failure; the strict 360/390px criterion remains enforced.
- The old Windows #37799066701 was cancelled after further source writes with only handover job passed. All current source fixes and newly synced documentation need another exact-head Full Playwright plus Windows CI before saying verified; live-operator payout and enrollment tests remain separate.
- NEXT EXACT ACTION: synchronize CHANGE_LEDGER and root PROJECT_HANDOVER; inspect new exact-head v04_browser_simulation: if fail, read the new geometry diagnostics, identify overflowing element, fix only that CSS area and repeat. Do not waive or weaken narrow-screen checks. If full run passes, hold at safe development preview and proceed to other subsystems only with independent tests.
