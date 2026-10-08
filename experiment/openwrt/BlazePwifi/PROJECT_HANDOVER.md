## CURRENT STATUS — 2026-10-09 MIG-0624 shell syntax repaired, targeted SUCCESS / production blocked

**Branch:** `BlazingSystems/BlazingSystems-Experiments` / `blazepwifi-v0.6.0-audit-foundation`, draft PR #30; P0 issues #31 and #32. A new sandbox POSIX/awk journal with checksum/concurrency fixture is **not installed** and has no authenticated controller v2, target fsync or migration. Earlier Full #37815137752 at head `10cb4e913fbb8d7bca58591e0adceffcb5d43cbe` failed static parser, not business behavior, because `tools/v060_journal_fixture.sh` had duplicated trailing shell. Pre-change IN PROGRESS `a8726d14321475f359ebe0ee0ba802da52acd10d`. Trim correction `73c9ba6d4cc4cd3ea6f4006bbfa42371585db427`; targeted workflow now requires `sh -n` before tests (`52b92e23d80db7acadc622458c1ad54f02b17971`). [Staged #37815421948](https://github.com/BlazingSystems/BlazingSystems-Experiments/actions/runs/37815421948) exact-source **COMPLETED SUCCESS**: syntactically valid shell, native checksum/race/ACK model, SQLite oracle and single-replace transfer PASS; old-source member replay, member receipt EIO and rental receipt EIO still intentionally RED. Previous failures retained in CHANGE_LEDGER. Full 26-job + Windows 2-job at final canonical-HEAD still pending. **Never publish v0.6.0** until actual router journal, authenticated v1→v2 migration, physical coin/power cut, signed Android and release provenance gates pass. No live accounting, signer or frozen assets changed.

**NEXT EXACT ACTION:** inspect final-HEAD Full and Windows Actions (do not assume success because staged pass); repair any failures without bypassing gates and update handovers. Then validate portability and durable file+directory fsync semantics on actual target OpenWrt/ImmortalWrt hardware, design controller authenticated monotonic sequence and migration before real financial integration. Audit & Reconcile prompt for next chat: `@GitHub Resume BlazingSystems/BlazingSystems-Experiments draft PR #30 and P0 #31/#32. Read PROJECT_HANDOVER.md top, docs/handover/CURRENT_STATE.md, CHANGE_LEDGER.md, HANDOVER_POLICY.md, docs/LEDGER_TRANSACTION_V060.md. Confirm MIG-0624 staged #37815421948 success and check exact final-HEAD Full+Windows. The native tool is sandbox-only; member and rental financial bugs remain RED. Never ship v0.6 until fsync/auth/migration/hardware/signer gates pass.`

## CURRENT STATUS — 2026-10-09 MIG-0624 SYNTHETIC NATIVE JOURNAL HARDENED (RELEASE BLOCKED)

**Active:** `BlazingSystems/BlazingSystems-Experiments` branch `blazepwifi-v0.6.0-audit-foundation`, draft PR #30, P0 #31 (members) and #32 (rental). Sandbox-only POSIX sh/awk journal fixture `tools/v060_journal_fixture.sh` includes same-snapshot member+rental balance/receipt/sequence and SHA-256 integrity footer, not a real authenticated/flash-durable OpenWrt money engine. Hardened concurrent retry and tampering fixture `tests/v060_journal_native_fixture.sh` tested on [staged #37814970028](https://github.com/BlazingSystems/BlazingSystems-Experiments/actions/runs/37814970028), exact SHA `a818a2af887849fd08f393ba4b6dda27864f1fcb`, **COMPLETED SUCCESS**; log confirmed native checksum+concurrent retry PASS, SQLite model PASS, single-file transfer PASS and current-source member replay/member receipt/rental receipt remain expected RED. Correction commits `66fa0fa1f699d8bbdc6f350398af84acbef15bd9`, `5b7d1d097695a256f4df7ba3c5fae716c7e69818`, `a818a2af887849fd08f393ba4b6dda27864f1fcb`. Initial failing staging runs recorded in ledger, not deleted. Full required CI already includes native + SQLite fixture; final 26-job Full and Windows 2-job on latest canonical HEAD **PENDING**. No customer state, runtime billing APIs, published releases, Android signer or router configs changed. Unkeyed checksum is not an authenticated receipt and one `sync` does not prove flash persistence. **v0.6.0 PRODUCTION BLOCKED.**

**NEXT EXACT ACTION:** inspect latest canonical HEAD Full+Windows CI; fix genuine failures, checkpoint three handovers. Then investigate concrete target BusyBox implementation, fsync of file+directory, protocol authenticated controllers and v1 migration for members/rental/ordinary coins; do not integrate or publish before crash/power-cut, signing and hardware acceptance. Next-chat Audit & Reconcile prompt: `@GitHub Resume BlazingSystems/BlazingSystems-Experiments draft PR #30, P0 #31/#32. Read PROJECT_HANDOVER top, CURRENT_STATE, CHANGE_LEDGER, HANDOVER_POLICY, docs/LEDGER_TRANSACTION_V060.md; validate exact-head Full/Windows after MIG-0624. Targeted synthetic #37814970028 passed, but old-source financial defects still RED. Audit fsync/auth/migration on hardware before runtime integration; do not release v0.6.`

## CURRENT STATUS — 2026-10-09 MIG-0624 checksum test correction (PENDING)

**Repo:** `BlazingSystems/BlazingSystems-Experiments` branch `blazepwifi-v0.6.0-audit-foundation`, draft PR #30; P0 issues #31/#32. Off-device synthetic POSIX journal `tools/v060_journal_fixture.sh` now includes unkeyed SHA256 footer and one-file candidate commit; tests have a concurrent exact-replay and numeric-tamper negative case. Initial script edit `f08cf7c8098b980c436fd74a6c2d47376345cb73` and test `15cd9bf4cb46f80d1a5291cb01d7c002d4429174` **FAILED** [staged #37814530378](https://github.com/BlazingSystems/BlazingSystems-Experiments/actions/runs/37814530378) due broken quote syntax at line 55, not a paid balance failure. Script repair commit `66fa0fa1f699d8bbdc6f350398af84acbef15bd9` attempted to fix checksum validation + candidate footer; [staged #37814633465](https://github.com/BlazingSystems/BlazingSystems-Experiments/actions/runs/37814633465) QUEUED, **not yet validated**. Previous synthetic baseline staged #37814084225 SUCCESS only before checksum hardening. Frozen production and signed releases remain untouched. Current Full+Windows HEAD not yet verified. POSIX prototype is test-only and is not a durable authenticated router journal. **v0.6 PRODUCTION BLOCKED.**

**NEXT EXACT ACTION:** inspect staged #37814633465 log/exit, fix any actual regression, then run/check exact canonical HEAD Full+Windows gates. After synthetic hardening, target true fsync+parent-dir durability, authenticated monotonic controller protocol, v1 member/rental migration, and real hardware power cuts before integrating. Audit prompt: `@GitHub Continue BlazingSystems/BlazingSystems-Experiments draft PR #30, P0 #31/#32; read top PROJECT_HANDOVER/CURRENT_STATE/CHANGE_LEDGER/HANDOVER_POLICY and docs/LEDGER_TRANSACTION_V060.md; check MIG-0624 staged CI #37814633465 and latest exact HEAD Full+Windows; do not conceal failure or publish v0.6; pursue off-device journal fsync/auth/compatibility.`

## CURRENT STATUS — 2026-10-09 MIG-0623 native POSIX synthetic journal checkpoint

**Repository:** `BlazingSystems/BlazingSystems-Experiments`, branch `blazepwifi-v0.6.0-audit-foundation`, draft PR #30, P0 issues #31 (member) and #32 (rental). New guarded OFF-DEVICE (not rootfs) POSIX sh/awk `tools/v060_journal_fixture.sh` commit `09ea464243df727985f694c12f3f11d5884f7882` and test `tests/v060_journal_native_fixture.sh` `b4526034f93b518482c02a4c4b5118b62f867ec9`. Staged [Actions #37814084225](https://github.com/BlazingSystems/BlazingSystems-Experiments/actions/runs/37814084225) at `c8518560c29bf0ae59085ffe8e68fb4e57ed6522` **SUCCESS**: one-snapshot synthetic member+rental+receipt/replay/failure contract green, older SQLite oracle and narrow transfer test green, **member replay, member receipt and rental receipt remain expected RED on actual old source**. Full workflow commit `c08e8658ab2cecb2d0837ca0e47b1041af9c70d0` now requires POSIX fixture and awaits exact-head CI. Prior Windows `#37812939528` was SUCCESS at previous head `6a1bd3...`, not the latest code. No runtime accounting code, live balances, signer, firmware profile, installer or published release changed here. Simulator has no physical fsync durability, crypto authentication, v1 migration or real flash power-cut acceptance. **0.6.0 production BLOCKED.**

**NEXT EXACT ACTION:** inspect canonical-HEAD Full 26-job and Windows 2-job results, repair any actual failure and append evidence to all records. Then fortify synthetic single-snapshot prototype with integrity framing/concurrency and target BusyBox fsync verification, before guarded protocol-v2 integration. Copyable next-chat prompt: `@GitHub Continue BlazingSystems/BlazingSystems-Experiments draft PR #30, P0 #31/#32, from top PROJECT_HANDOVER, docs/handover/CURRENT_STATE, CHANGE_LEDGER, HANDOVER_POLICY, docs/LEDGER_TRANSACTION_V060.md. Check MIG-0623 exact canonical HEAD Full+Windows. Audit synthetic v060_journal_fixture.sh and test; harden file/hash/concurrency and real target durability; do not publish v0.6 or touch live balances/old releases.`

## CURRENT STATUS — 2026-10-09 MIG-0622 RENTAL P0 proof / last isolated checkpoint

**Active:** `BlazingSystems/BlazingSystems-Experiments` draft PR #30 branch `blazepwifi-v0.6.0-audit-foundation`; P0 member issue #31 and new P0 rental issue [#32](https://github.com/BlazingSystems/BlazingSystems-Experiments/issues/32). Synthetic rental receipt EIO fixture `tests/v060_rental_receipt_failure_repro.sh` commit `91e9b42d6c2997fef7379d3fd65125b1ea752c34`, expected-RED CI commit `c6b46560d05a3e018c0451ace095296d4ce0b86a`. [Staged #37812792553](https://github.com/BlazingSystems/BlazingSystems-Experiments/actions/runs/37812792553) exact-code **COMPLETED SUCCESS as test harness**: proves rental lease changed + credited ACK despite unwritable receipt, member banked replay RED and member receipt EIO RED. Transfer interrupted-write GREEN from narrow `member.sh` fix `5782937deeb1651d45204d446a9851179be9d6c3`; synthetic v2 SQLite journal model PASS, but no native router transaction journal. This is NOT production-ready or proven hardware safe. No released asset, Android signer, live state, real invoice or Standalone Rental source changed.

**Release block:** v0.6.0 remains unpublished, original v0.5.x freezes preserved; full Exact-HEAD 26-job/Windows 2-job after this documentation checkpoint pending. Native prepaid journaling, encrypted migration, authenticated SoftTimer v2, rental receipt durability and real power-cut acceptance are open. NEXT EXACT ACTION: verify final HEAD CI and failures; then implement isolated native v2 journal with test injection and v1 compatibility before touching runtime paid state. For new chat: `@GitHub Audit PR #30 and issues #31/#32 on BlazingSystems/BlazingSystems-Experiments. Read PROJECT_HANDOVER top, docs/handover/CURRENT_STATE, CHANGE_LEDGER, HANDOVER_POLICY, docs/LEDGER_TRANSACTION_V060.md; verify latest Full/Windows CI HEAD; build off-device OpenWrt-native journal and failure tests; do not publish 0.6 release or modify old signer.`

## CURRENT STATUS — 2026-10-09 MIG-0621 concurrency-oracle staged green / Full pending

**Branch/PR:** `BlazingSystems/BlazingSystems-Experiments` / `blazepwifi-v0.6.0-audit-foundation`, draft #30, P0 #31. Synthetic transactional ledger model `tests/v060_ledger_model.py` now tests concurrent identical requests, commit/replay, ACK loss, EIO rollback and bounded stale-sequence rejection, modification commit `82d3af24b9b04cc1f524c2ce1709fd839787606a`. Targeted staged [Actions #37812069795](https://github.com/BlazingSystems/BlazingSystems-Experiments/actions/runs/37812069795) **SUCCESS** at same SHA; model PASS, one-file transfer PASS, old source replay and receipt EIO expected RED. Full `validate` now requires oracle (workflow commit `f5dd3a53a3cb6304b46f041ebb5be7928d352fa7`). **Full 26/Windows 2 exact HEAD verification still PENDING.** No native OpenWrt journal, release migration, power-cut hardware evidence, Android signer or published release changed; v0.6.0 PRODUCTION BLOCKED. Development includes one-rename member transfer only, not complete atomic receipt semantics.

**NEXT EXACT ACTION:** inspect branch HEAD Full and Windows Actions after this handover checkpoint. If successful, develop POSIX/OpenWrt-compatible durable transaction journal with migration and real hardware fault injection per `docs/LEDGER_TRANSACTION_V060.md`; keep prepaid receipt and random legacy controller event risks blocked. For next chat: `@GitHub Inspect draft PR #30 branch and issue #31; read top PROJECT_HANDOVER, docs/handover/CURRENT_STATE, CHANGE_LEDGER, HANDOVER_POLICY and docs/LEDGER_TRANSACTION_V060.md; verify MIG-0621 full+Windows on exact HEAD, then continue P0 journal/SoftTimer protocol v2, update handovers before/after changes, never publish v0.6 without physical+signer+migration acceptance.`

## CURRENT STATUS — 2026-10-09 MIG-0620 P0 synthetic oracle checkpoint

Draft PR #30 in `BlazingSystems/BlazingSystems-Experiments`, branch `blazepwifi-v0.6.0-audit-foundation`, issue #31. Prior staged P0 CI #37811179871 proved on old `member.sh` that replay and receipt-I/O are RED while atomic two-account transfer is GREEN. New isolated fixture-only SQLite transaction oracle `tests/v060_ledger_model.py` commit `28ff5bb8532c20a9d90ee7023cae494dd634ca2a`, workflow integration `40fb33338aa5378900d86a95ff4d0b000cb48bc4` and staged Actions #37811759148 QUEUED (not validated yet). Oracle models balance+receipt commit, acknowledged retry, stale sequence refusal and simulated failures; **not** real OpenWrt code or power-loss guarantee. No live balances, signer, frozen releases or router config modified. Full/Windows CI remains unverified on newest source. v0.6 production BLOCKED.

**NEXT EXACT ACTION:** inspect model #37811759148 output and correct any failure; require exact final-HEAD Full 26-job and Windows 2-job CI before claiming development pass. Then design POSIX/OpenWrt durable journal and v1→v2 controller migration per `docs/LEDGER_TRANSACTION_V060.md`. Audit & Reconcile prompt: `@GitHub Read BlazingSystems/BlazingSystems-Experiments draft PR #30 and issue #31 plus PROJECT_HANDOVER.md top, docs/handover/CURRENT_STATE.md, CHANGE_LEDGER.md and HANDOVER_POLICY.md; verify MIG-0620 targeted run #37811759148; keep old-source replay/receipt blockers visible and release blocked; use fixture-first journal design and synchronize all logs.`

## CURRENT STATUS — 2026-10-09 MIG-0619 ledger defect proof / journal design checkpoint

**Draft PR #30** `blazepwifi-v0.6.0-audit-foundation`, P0 issue #31. Original accounting replay and half-transfer source failures were independently reproduced in fictional fixture CI #37810302638. Narrow member transfer two-record atomic rename source commit `5782937deeb1651d45204d446a9851179be9d6c3` passes its injected interruption (staged CI [#37811179871](https://github.com/BlazingSystems/BlazingSystems-Experiments/actions/runs/37811179871), code `1abdc6eae64c9b06359f177258f7512b31eb75e2`). Two P0 defects remain confirmed expected RED: evicted ID double-credit and receipt write EIO yielding successful mutation. Receipt fixture commit `fff1e248247e9fee1202b8b4acd27c17bf947396`, workflow contract commit `1abdc6eae64c9b06359f177258f7512b31eb75e2`. New `docs/LEDGER_TRANSACTION_V060.md` commit `ac145e93be21c57a24d8f666ba9abf384aa74a04` defines future bounded durable journal + authenticated sequence/ACK + crash and migration contract; DESIGN ONLY. No full fix or production build claimed, no live account/signer/releases modified. Pending exact-source 26-job Full and 2-job Windows gates must be rechecked after handover sync.

**NEXT EXACT ACTION:** implement off-device synthetic v2 journal prototype with failure injections and test before touching live `member.sh` replay protocol; ensure controller v1 compatibility and storage failure semantics. Check new HEAD CI, update records. Production v0.6 remains BLOCKED. Audit & Reconcile: `@GitHub Resume BlazingSystems/BlazingSystems-Experiments draft PR #30, issue #31; read top PROJECT_HANDOVER, docs/handover/CURRENT_STATE.md, CHANGE_LEDGER.md, HANDOVER_POLICY.md and docs/LEDGER_TRANSACTION_V060.md; verify exact HEAD Actions and staged P0 RED evidence, develop isolated journal fixture; no production release, signer change or live balance work.`

## CURRENT STATUS — 2026-10-09 MIG-0618 source checkpoint (TRANSFER CI PENDING)

**Active repo:** `BlazingSystems/BlazingSystems-Experiments`, branch `blazepwifi-v0.6.0-audit-foundation`, draft PR #30, P0 issue #31. Verified old accounting defects in fictional fixture on expected-RED Actions #37810302638 at `b8184e8a3f231e0d36756fe7057dad5e6a746df4`: evicted ID re-credit and 40-second discrepancy from SIGKILL between two row rewrites. Before-change policy log `a48003b6975932ea2c1e0878a4c54ce1c4cca8c9`. Narrow transfer fix `member.sh` commit `5782937deeb1651d45204d446a9851179be9d6c3` updates both members in one temp+rename instead of two. Staged P0 workflow `7bb507f40fc732baa7fae0cd38af09de49eb6f72` requires transfer GREEN and replay expected RED; Full validate gate `f40a799fab5685664d555ac086ffb1282de7d861` requires atomic transfer test. **Exact-source CI still pending**. This is NOT a complete transaction journal: event receipt remains separate and 0.6 state migrations/physical signing acceptance remain blocked. Frozen production v0.5 releases, account state and signer untouched.

**NEXT EXACT ACTION:** inspect newly triggered HEAD CI staged P0, 26-job Full, 2-job Windows; fix any source/test failure, checkpoint all canonical docs; then design durable bounded replay/idempotency plus crash-atomic receipt with fail-closed storage and rerun RED-to-GREEN tests. Do not ship 0.6. Audit & Reconcile prompt: `@GitHub Continue draft PR #30 in BlazingSystems/BlazingSystems-Experiments. Read top PROJECT_HANDOVER, CURRENT_STATE, CHANGE_LEDGER, HANDOVER_POLICY, P0 issue #31. Verify post-f40a799f Actions before counting MIG-0618 transfer fix; do not interpret expected replay RED as success. Resolve remaining journal/idempotency and migration + hardware gates with exact evidence; do not publish production.`

## CURRENT STATUS — 2026-10-09 MIG-0617 P0 synthetic red reproduction (CI unverified)

**Repo/branch:** `BlazingSystems/BlazingSystems-Experiments` / `blazepwifi-v0.6.0-audit-foundation`, draft PR #30; tracked in issue #31. Synthetic-only reproduction tests: replay commit `8bce9402a0f367cfc4ac574217b6bb63131c10fa`, interrupted transfer commit `2844a264c34766fca94dbf82c2283e6efe7bae36`, standalone expected-RED GitHub workflow commit `b8184e8a3f231e0d36756fe7057dad5e6a746df4`. RED workflow #37810302638 queued; **NOT VALIDATED** at this checkpoint. No production accounting source changed. Prior branch-head Full #37809147022 and Windows #37809146918 were completed SUCCESS before new tests; new code needs a fresh exact-SHA gate. Intermediate Windows #37810267032 FAILED; inspect logs. Published release/signers untouched; v0.6.0 still BLOCKED.

**NEXT EXACT ACTION:** inspect RED workflow #37810302638 output and Windows failure job/step; confirm replay/double-credit and first-write transfer crash with exact synthetic fixture signatures, repair harness errors if any. Only then design bounded persistent idempotency and journaled crash-atomic transfer, convert RED proof to GREEN required regression, synchronize handover/ledger/live, and demand exact-head full+Windows+hardware acceptance. New chat prompt: `@GitHub Continue BlazingSystems/BlazingSystems-Experiments draft PR #30 P0 issue #31; read root PROJECT_HANDOVER and docs/handover/{CURRENT_STATE,CHANGE_LEDGER,HANDOVER_POLICY}.md; inspect expected-RED #37810302638, resolve only genuine test harness faults, then address member ledger atomicity; do not release 0.6.0 or touch production accounting.`

## CURRENT STATUS — 2026-10-09 MIG-0617 source-only checkpoint

**Active:** PR #30 `blazepwifi-v0.6.0-audit-foundation`, P0 issue #31. Pre-test source head `42675aae156e8d30f5c149f6d12c2ac0eda49ac2`, Full Actions #37807641991 SUCCESS, previous Windows #37807200137 SUCCESS. Those runs PRECEDE new reproduction script and do not certify it. `CURRENT_STATE.md` recorded IN PROGRESS at `af576d282b236c90ddab32fde9574e5468d9bb72`; a synthetic-only intended-RED replay test was added in `tests/v060_member_replay_repro.sh` commit `8bce9402a0f367cfc4ac574217b6bb63131c10fa`. Execution is PENDING, not proven RED/GREEN. No runtime balances, member.sh, release assets, signer or production state changed. **DO NOT RELEASE v0.6.0.**

**NEXT EXACT ACTION:** run `sh experiment/openwrt/BlazePwifi/tests/v060_member_replay_repro.sh` on the development checkout, confirm its fail is from evicted ID double-credit (not setup error), implement synthetic failure-injected transfer regression, then design and validate durable idempotency/atomic journal, synchronize handover with new exact SHA/CI evidence. Hardware outage acceptance and migration remain release blockers. Audit & Reconcile prompt: `@GitHub Inspect PR #30 branch, issue #31, top PROJECT_HANDOVER.md, docs/handover/{CURRENT_STATE,CHANGE_LEDGER,HANDOVER_POLICY}.md. Run MIG-0617 RED synthetic test and confirm failure mechanism before changing member.sh. Update all three records after each meaningful commit. Keep production release blocked.`

# BlazePwifi — CURRENT STATUS (READ FIRST)

## LATEST VERIFIED DEVELOPMENT CODE — 2026-10-08 (MIG-0616)

**Source/document SHA `b66100d42085c77bdda4e83ef39cd79beaf8eb56`: Full [Actions #37805684343](https://github.com/BlazingSystems/BlazingSystems-Experiments/actions/runs/37805684343) COMPLETED SUCCESS — 26 jobs passed, 0 failures, `v04_candidate_gate` SUCCESS; the new synthetic money/state backup/restore test and earlier migration guard, sysupgrade preservation, Android Device Owner, real browser, ESP, Ruijie, Orange Pi and x86 simulation all passed. Four production signing/import/publish jobs were intentionally skipped. Verified artifacts: candidate gate `11562848151`, browser simulation `11562124474`, non-secret handover evidence `11561969907`. Same SHA [Windows SoftTimer #37805690414](https://github.com/BlazingSystems/BlazingSystems-Experiments/actions/runs/37805690414) COMPLETED SUCCESS: both `handover` and `build-windows` (native EXE/installer smoke).

**What was actually added:** `tools/state-fixture.py` and `tests/v060_state_fixture.sh` with required CI and migration contract. **Synthetic-only**, marker-required off-device snapshot/manifest SHA checks/new-directory restore, tamper/unsafe path/mode tests. It is **not encrypted**, cannot migrate real customers, and is **NOT approval to remove the 0.6.0 upgrade block**. Full, Standalone and EasyMode BlazeFusion work is covered by the same green matrix. Published v0.5.2 Full, Standalone Rental RC9, Windows SoftTimer v0.4.0 and Android permanent Lineage-2 identity remain untouched.

**New critical business risk, not yet fixed:** [P0 issue #31](https://github.com/BlazingSystems/BlazingSystems-Experiments/issues/31): bounded `member-events.tsv` retention may permit very old paid-event replay after eviction, and member transfers update two balances in separate writes before logging the event. Power loss or I/O failure could leave partial credit movement. Rental and PisoWiFi coin deduplication across restarts also need review. This is source audit, not a confirmed field incident.

**NEXT EXACT ACTION:** On the `blazepwifi-v0.6.0-audit-foundation` draft [PR #30](https://github.com/BlazingSystems/BlazingSystems-Experiments/pull/30), implement a **synthetic-only negative reproduction** for issue #31: an event evicted from `member-events.tsv` then replayed; a transfer interrupted between sender/recipient writes. Add required CI and document precise failing original behavior before changing accounting code. Design a durable replay/tombstone index and a single crash-recoverable transaction journal with flash-safe recovery and per-event idempotency, then retest at every injected power-loss boundary. Do not tag/sign/publish v0.6.0 until real encrypted backup + power-cut/money hardware + sysupgrade restoration, current/higher-code same-signer Android rescue and product version identity gates pass.

**Checkpoint precision:** the documentation-only commit after `b66100d4...` is NOT the SHA directly run by CI; compare the diff and verify no source/workflow changes before reusing the green result. Keep continuous root/live/ledger synchronization.

---


## LATEST VERIFIED CODE + LIVE P0 WORK — 2026-10-08

**Last completed exact-HEAD development validation:** commit `7fde42bbd8692158c8c52066a1f01b73a513a0f2`, Full BlazePwifi Actions [#37802942602](https://github.com/BlazingSystems/BlazingSystems-Experiments/actions/runs/37802942602) **26/26 SUCCESS** plus Windows [#37802942611](https://github.com/BlazingSystems/BlazingSystems-Experiments/actions/runs/37802942611) **2/2 SUCCESS**. CoreUI×Metis-inspired BlazeFusion Full, Standalone, and off-device EasyMode R281 preview passed. All published releases remain unchanged. This green code does **not** verify subsequent changes.

**ACTIVE P0 — MIG-0616 / COMMITTED, CI PENDING:** a synthetic-only paid-state snapshot/verify/restore integrity prototype is under `tools/state-fixture.py` (commit `137e0d83dcf77eb96708e6126a35a2be3d6e3876`), with fake ledgers, tampering/permissions/link/overwrite tests `tests/v060_state_fixture.sh` (`a0517378cd023170cbf0e123546f90c4f946c88b`), required CI `.github/workflows/blazepwifi-build.yml` (`c1028a03bb22d2b7d3836db90cf9ab2e63313f86`), and strict [0.6.0 migration limitations](docs/RELEASE_0.6.0_MIGRATION.md) (`76310541675273a324c3847c0bcce894a0f22564`). The program **cannot** read real appliances (requires explicit synthetic marker) or restore over existing data; its fixture backup is **NOT ENCRYPTED and is NOT a production migration**. Existing OpenWrt 0.6.0 update preflight remains blocked. No existing business state, router settings, release or Android signer touched.

**NEXT EXACT ACTION:** verify new exact-branch-head Actions `validate` step **BlazePwifi v0.6 synthetic state backup/restore integrity prototype**, plus legacy 0.5.x update/rollback, Android, browser, firmware and Windows jobs. If failure: inspect exact job logs and record failed step before fixing; re-sync root/current/ledger. After success, implement a *separate* simulated transaction journal with freeze/event cursors, replay safety and fault injection; do **not** unblock 0.6.0 or publish an APK until encrypted private backup, signer/rescue, real hardware power-cut, money invariants and sysupgrade restore tests pass. Draft [PR #30](https://github.com/BlazingSystems/BlazingSystems-Experiments/pull/30) remains unmerged.

### Copyable safe handoff

> Resume BlazePwifi development on `BlazingSystems/BlazingSystems-Experiments`, branch `blazepwifi-v0.6.0-audit-foundation`, draft PR #30. Read the TOP of `PROJECT_HANDOVER.md`, `docs/handover/CURRENT_STATE.md`, `CHANGE_LEDGER.md`, `HANDOVER_POLICY.md`, and `docs/RELEASE_0.6.0_MIGRATION.md`. Previous EasyMode UI source 7fde42bb passed Full #37802942602 (26/26) and Windows #37802942611 (2/2). NEW synthetic-only snapshot prototype source commits 137e0d83, a0517378, c1028a03; check latest exact-SHA CI and fix documented P0 failures without bypassing 0.6 update guard. Existing published releases and permanent APK signer untouched; do not call fixture tests production recovery approval.

---


## LATEST VERIFIED CONTINUITY CHECKPOINT — 2026-10-08

Development source SHA: 74623164a808f22d0f1adbf4468b32c19c3cfb69. Draft PR #30, branch blazepwifi-v0.6.0-audit-foundation, base blazepwifi-v0.5.3-rc1.
Full BlazePwifi GitHub Actions #37799976600: COMPLETED SUCCESS, 26 required jobs passed, zero failures; four intentionally skipped production import/sign/publish gates. Includes early policy/ledger freshness, standalone/full Fusion static tests, Real Chromium browser (360px and 390px, full admin QR, Standalone appearance), native Android Device Owner emulator, Ruijie, Orange Pi, ESP, x86 QEMU and candidate gate. Browser artifact ID 11561130056, candidate gate artifact 11560821092, handover evidence artifact 11560535720.
Windows SoftTimer GitHub Actions #37799992623: COMPLETED SUCCESS, two jobs (handover prerequisite and native Windows EXE/NSIS installer/billing smoke). EXACT SAME source SHA.
Failed historical Standalone test: #37799066752 job 113386892960, 390px overflow, on prior SHA 75d88c87...; fixed without hiding overflow in CSS commit 52da18e6... and retained diagnostic/assertions in d616c16b...; later browser #37799976600 SUCCESS. Do not confuse the original failure with current status.
New UX: Full BlazePwifi and separate single-file Standalone Rental console both have offline BlazeFusion/Compact/Comfort selectors using a nonsecret browser preference only. CoreUI React and Metis templates are references; the two SPAs were not deployed into firmware. Previously published Full v0.5.2, Standalone Rental RC9, and Windows SoftTimer v0.4.0 release assets and permanent Lineage-2 Android identity remain UNCHANGED.
THIS IS NOT V0.6.0 PRODUCTION: on-disk VERSION/Android code still 0.5.3; full financial migration/rollback, real sysupgrade backup/restore, physical concurrent-coin acceptance and 0.6.0 same-signer rescue/signature gates remain BLOCKED. Do not tag, merge into main or publish 0.6.0 from this source.
NEXT EXACT ACTION after this documentation-only checkpoint: (1) verify that the branch HEAD differs from the green source SHA ONLY in the three handover docs; (2) audit independent EasyMode UI path experiment/openwrt/easymode-project/releases/v4.2.1-r281-experiment/root/www/easy/style.css, but DO NOT edit the published release snapshot; prepare separate new version/branch and low-memory Fusion token adapter with its own source, rollback and tests; (3) prioritize P0 transactional paid-state migration + real hardware restore before production; (4) register IN PROGRESS before edits, append exact commits, failures and CI evidence to all three canonical handovers and rerun exact-head validation.

### New-chat Audit & Reconcile prompt

Open GitHub repository BlazingSystems/BlazingSystems-Experiments, draft PR #30. Read THIS TOP CURRENT CHECKPOINT, docs/handover/CURRENT_STATE.md, CHANGE_LEDGER.md, HANDOVER_POLICY.md, docs/UI_BLAZEFUSION_0.6.0.md and AUDIT.md. Verify code SHA 74623164a808f22d0f1adbf4468b32c19c3cfb69 passed Full #37799976600 (26/26) and Windows #37799992623 (2/2); verify any later commits are DOCS ONLY. Next evaluate EasyMode independent edition versus finished BlazeFusion Full/Standalone UI, never touching frozen release snapshots. Continue P0 money migration/recovery before claiming a signed v0.6.0 release. Update handovers with exact evidence for every step.

---
**As reconciled:** 2026-10-08 19:43+ Asia/Manila; policy gate, browser fix, history regression and immutable Windows release guard now committed; full 26-job and Windows 2-job development CI green; production v0.6.0 release remains BLOCKED. **Owner mandate:** v0.6.0 cross-platform audit, security/data-integrity and native UI overhaul; continuous handover writing for **every meaningful code, test, failure, PR and release-state change**, without gaps. **The sections below the archive divider are historical context and may be stale.**

### EasyMode source routing correction — READ BEFORE NEXT GUI EDIT

Read-only repository audit found experiment/openwrt/easymode-project/VERSION = 5.0.0-alpha.1, shared core under core/, modules/ and editions/. The repository README identifies preserved R281 v4.2.3 installed experiment source in releases/v4.2.3-r281-experiment/root/www/easy/, with independent light/dark CSS and native OpenWrt account/ubus login. Numbered releases/ folders are immutable snapshots, NOT a place for new BlazeFusion implementation. v4.2.1 mentioned in earlier next-actions is obsolete as the integration target.
NEXT EXACT ACTION for EasyMode: read v5 alpha architecture/installer, inspect the latest preserved 4.2.3 UI as reference only, and implement an opt-in dependency-free skin under a NEW versioned v5 alpha modules/ui or staging path, with own static+real browser, auth/ubus, config rollback, 360px/390px and six-edition capability tests. Leave 4.2.1/4.2.2/4.2.3 snapshots unchanged. Prove no default credential change, network/routing rewrite, or mock status data.
v0.6.0 production still BLOCKED by money-ledger migration, real sysupgrade restoration and current/rescue same-signer Android signing/hardware acceptance.
## AUTHORITATIVE LIVE LINKS

- **Live work, blockers, source baseline, exact tests and NEXT EXACT ACTION:** [docs/handover/CURRENT_STATE.md](docs/handover/CURRENT_STATE.md).
- **Mandatory policy:** [docs/handover/HANDOVER_POLICY.md](docs/handover/HANDOVER_POLICY.md).
- **Append-only audit/change ledger with exact commits:** [docs/handover/CHANGE_LEDGER.md](docs/handover/CHANGE_LEDGER.md).
- **Reviewed system and competitor audit:** [AUDIT.md](AUDIT.md).
- **Active PR:** [v0.6.0 foundation draft #30](https://github.com/BlazingSystems/BlazingSystems-Experiments/pull/30).
- **Active branch:** `blazepwifi-v0.6.0-audit-foundation`, started at exact pre-documentation implementation HEAD `d99f9b7b1ac10f183659c97c156fe4c939863cf8`; **HEAD advances with each documentation/code sync**. Re-query before action.

## Verified CURRENT state — this block OVERRIDES the old "v0.5.3-dev.5" header below

| Subsystem | State | Evidence / condition |
|---|---|---|
| Production full BlazePwifi | **Frozen v0.5.2** | [Production tag](https://github.com/BlazingSystems/BlazingSystems-Experiments/releases/tag/v0.5.2); preserve permanent Android Lineage-2 signing identity |
| Separate Standalone Rental | **Frozen latest RC9** | [Standalone tag](https://github.com/BlazingSystems/BlazingSystems-Experiments/releases/tag/v0.5.2-rental.2-rc.9); not part of Full v0.6.0 source edits |
| Full v0.5.3 security baseline | **Merged / source validated** | RC1 branch head `4879c38f3f0e676f17ac40d73cb59c87ffcb5762`; not a v0.5.3 published production tag |
| Full v0.6.0 development | **Draft PR #30; release BLOCKED** | Existing VERSION and Android version metadata still `0.5.3`; no v0.6.0 signer run, release manifest, production APK or upgrade/rescue artifacts |
| Windows BlazePisonet SoftTimer | **Exact-source CI GREEN; hardware still pending** | [Windows run #37774312533](https://github.com/BlazingSystems/BlazingSystems-Experiments/actions/runs/37774312533) on `d1e7fb4187e2d0701f4e2b5c842c8711eb09d756`, both handover and native EXE/NSIS/timer-smoke jobs passed; published v0.4.0 release unchanged |
| Full BlazePwifi CI | **SUCCESS: 26 jobs, 0 failures** | [Full run #37774312541](https://github.com/BlazingSystems/BlazingSystems-Experiments/actions/runs/37774312541) on `d1e7fb4187e2d0701f4e2b5c842c8711eb09d756`; browser QR, Android emulator, x86 QEMU, Ruijie/Orange Pi and candidate gate passed; production signing/publishing skipped |
| Handover synchronization | **VERIFIED at code SHA d1e7fb41** | Freshness and negative-history gates passed; `BlazePwifi-ci-handover-evidence` artifact `11548837388` published; mandatory policy in root/live/ledger; default-main routing pointer commit `9ee502d6e53da505e680bedb6be935c5f6a7446f` |

**Do not use old dates in the archived text to decide which branch/code is active.** `docs/handover/CURRENT_STATE.md` takes precedence when source + current Action logs corroborate it. If evidence contradicts it, fix this block and the live state immediately instead of inventing a release success.

**New business protection:** Windows workflow commit `326d67e88db690ad9e83e855fc3136d2498cbb61` now requires the same handover gate before building and will not overwrite published SoftTimer v0.4.0 assets. Verified existing release contains NSIS setup EXE, portable ZIP and checksums; no released assets changed. Both workflows have now passed on the exact source SHA above; hardware acceptance and production release remain outstanding.

## Current P0 activity — MIG-0610 migration safety (committed, CI not yet verified)

- **Audited blocker:** existing overlay `update.sh` ignored `update-migrate.sh` failure and its manifest-based rollback does not cover mutable financial/account/rental state or UCI configuration. A v0.6 release without transactional migration risks unrecoverable partial balances and identities.
- **Code fix committed:** `openwrt/rootfs/usr/lib/blazepwifi/update.sh` commit `20fc51350fa1b6de11c695f70cde83b73d2e786b` explicitly refuses 0.6-family updates **before any persistent change**. This is a deliberate temporary release blocker; do not disable it merely to publish 0.6.0.
- **Tests committed:** `tests/v060_migration_guard.sh` `e25e95602fbddf39c8d8844778cb2e20adc17eeb`; mandatory CI `ca36f2e17df5e3ef5b339f341a5aefdc5d994022`. Tests simulate rejecting 0.6 updates without modifying code or account state, plus successful legacy 0.5 apply/rollback. **Exact-head CI unverified at the time of this checkpoint**.
- **Migration contract:** [docs/RELEASE_0.6.0_MIGRATION.md](docs/RELEASE_0.6.0_MIGRATION.md) `46e4f73a05516b9d1d100ddebba823b241529e8a`: actual persistent-state inventory, migration journal/snapshot/recovery, post-transaction rollback constraints and v0.6 identity gates.
- **NEXT IMMEDIATE:** check new exact HEAD `validate` and full matrix for the new preflight regression. Keep previous exact-source green run #37774312541 and Windows #37774312533 as historical proof **only for prior SHA `d1e7fb41...`**. If a test fails, log and fix before continuing. After tests, implement transaction snapshot and recovery, **not** production signing yet.

## P0 active SYS-0612 — preserve paid state and TLS pins through full firmware upgrade

**This is distinct from v0.6 overlay migration MIG-0610.** OpenWrt sysupgrade restores only declared config/data. Missing backup declarations could lose customer balances, prepaid device identities and TLS pin continuity during full firmware replacement.

- `openwrt/rootfs/lib/upgrade/keep.d/blazepwifi` commit `9bdd8196d811226ca4feccc963b398b6ade59cee`: narrowly includes operator config, `state` paid ledger/credentials, portal and HTTPS cert/key; deliberately excludes huge update snapshots.
- `openwrt/rootfs/usr/lib/blazepwifi/update.sh` allow-list commit `e7ac3d55a9c71b92b8e6039287ba3c5a0ba6077f` permits only BlazePwifi's keep.d path in transactional overlay bundles, no generic sysupgrade.conf replacement. Existing 0.6 transaction-migration block remains active.
- `tests/v060_sysupgrade_preservation.sh` commit `d16ce84af7cd1958ef7a2feb87d983ad8438728d`; required workflow step `3537df27ea66caa2969951c2a510b5bd8fbc4f5c`. **Committed, not yet verified on new exact source.**
- `docs/RELEASE_0.6.0_MIGRATION.md` commit `d675773097fe51629946ba24fedebd6b86ce6f10` includes physical `sysupgrade -l`, encrypted backup size/restore, router pin certificate continuity, and Android same-signer rescue version code higher than installed current APK.
- **Prior verified checkpoint:** full #37776446840 passed 26 jobs and Windows #37776446835 passed 2 on **earlier** source SHA `541282869753dc2b64058c45a162ab4b96e83be9`. These runs do not validate the new keep.d source.

**NEXT:** run new exact-head CI including preservation test, firmware bundles, Android owner emulator, Ruijie/x86/Orange Pi simulations and Windows EXE; record any failure before another change. Then validate actual OpenWrt `sysupgrade -l` and recovery on supported hardware, and finish v0.6 transaction migration and version/signer release gates. **No signed/published 0.6.0 release.**

## UI-FUSION-0613 — latest source changes; exact-head testing still pending

The user supplied two admin UI ZIP templates and requested that they be reconciled and gradually used on BlazePwifi and subprojects **after** finishing the pending firmware/sysupgrade checkpoint. The previous Full CI [#37777931329](https://github.com/BlazingSystems/BlazingSystems-Experiments/actions/runs/37777931329) **SUCCESS (26/26)** and Windows [#37777940814](https://github.com/BlazingSystems/BlazingSystems-Experiments/actions/runs/37777940814) **SUCCESS (2/2)** on `9969958da0e7b590a376dce23c23b32fbf2020db`. That was a safe **source** checkpoint.

Uploaded sources: `coreui-react-v1.0.0.zip` internally CoreUI React admin template 5.7.0 (MIT), and `metis-v1.0.0.zip` internally Metis admin template 3.6.0 (MIT). They are UI templates, **not** interchangeable Wi-Fi vendo/rental engines. Full React+Redux and Alpine+Bootstrap admin runtimes were deliberately not copied to small OpenWrt firmware. No user ZIPs or mock data uploaded to GitHub.

**Implemented on the Full web management console only:** a single self-hosted BlazeFusion responsive UI (Fusion/Compact/Comfort) layered on the secure existing CGI/CSRF shell:
- CSS `vendor/blazefusion/blaze-fusion.css`, commit `526fa90373352476778f6fb32ed0a5590dae6796`.
- Presentation-only local preference JS `blaze-fusion.js`, commit `ff4f3af28fe24726a4bed81c31d6e41f3000e45f`.
- Actual authenticated `admin.html` integration, commit `ba3b40e0dbed9fd488633527b1cee48b93874521`.
- Browser regression `simulation/browser_v04_audit.py` commit `64b8bfdad4a2688a21f7634f06cd1eabf32ed0a6`, static `tests/v060_ui_fusion.sh` `578a858c0280d13e72c4e4d26f82aedb71551f3d`, workflow gate `0b4dfec666d0ca3b3160c8ad5e8185cb1445d239`.
- Architecture and honest subsystem rollout matrix: [docs/UI_BLAZEFUSION_0.6.0.md](docs/UI_BLAZEFUSION_0.6.0.md), commit `6b14e46391f793ea870e4386a7b820c6da0e74ff`. Standalone Rental, Lite, EasyMode, Android native, Windows native, ESP and advanced PC React have **not** received production code changes.

**NEXT IMMEDIATE:** inspect new exact-SHA CI `validate` BlazeFusion smoke and `v04_browser_simulation` appearance persistence + binding/Device Owner QR. If failing, log precise cause in `CURRENT_STATE.md` and ledger BEFORE changing code; then retest. Check full candidate gate plus Windows. Update all three canonical handover records at every meaningful transition and hold at a safe source commit.

**P0 remains:** transactional paid-state upgrade/rollback, actual OpenWrt `sysupgrade -l` and private restore on hardware, 0.6.0 version identity, higher-version same-signer APK rescue and manual operator signoff. No production v0.6.0 tag or release.

**BlazeFusion mobile QA source additions:** CSS commit 375b26f97a94779acb005633d48366fe0c8f59f0 prevents 360–390px topbar crowding without hiding Log out. Browser test commit 41c7e58bf0e4177c33fdf809697df0e85e165429 verifies body width on 360px and 390px before QR tests. Current state and ledger were synchronized after both; this root checkpoint closes that source window. Prior build runs are not exact-source approvals for these commits. **NEXT NOW:** verify latest exact-HEAD validate, v04_browser_simulation, other platform candidate gate and Windows build; log actual outcome before any release claim. Independent Lite/Standalone/Android/Windows/ESP appearance implementations are future work.

## UI-FUSION-0614 — Standalone Rental source integration (test approval pending)

New independent Standalone Rental page integration is limited to offline presentation. This edition installs a SINGLE HTML file; do not load Full admin assets by absolute path or alter its separate rental CGI. Inline BlazeFusion theme selector (Fusion/Compact/Comfort) shares only the non-sensitive local appearance key. No coin, rental lease, QR, CSRF or permissions logic was changed.

Evidence and exact commits: Standalone HTML e885b5ba8ddf5392cf56f0b55aba6a1ce8bf71d3; static installer/auth test 9970b2c6b1a55658ec9b1391ffb5a5c8aea2a5d5; mocked HTTPS real Chromium test 39c3317396110eb6ca3b494fe1647f7ca941ee9f; CI wiring 5bcaefd93e750cb3e083cdbda800e363d166b6e5; UI architecture af4e80d3fdeac2eeeb295feae5070e769272ced6. Current state/ledger were synchronized after the above commits.

PR #30 stays DRAFT. Previous Full CI #37796743126 and #37796759105 were canceled when the branch advanced; earlier Windows #37796759250 was green on the previous source b24fe37. Do not treat those as full success on the newest Standalone code. Frozen published Standalone v0.5.2-rental.2-rc.9 unchanged.

NEXT: check exact-head Full CI validate and Playwright standalone browser test (mobile 360/390px, login read-only mock, appearance persistence, no external calls) and Windows CI; log failure details, fix narrowly, resync all three canonical handovers, rerun. New v0.6.0 production tag remains blocked by financial migration/recovery and real hardware/device validation.

**Latest standalone mobile CI regression (P1; source fix not yet green):** Full run #37799066752, source SHA 75d88c87b844d1d3f73469ff757317847234d303, detected a real failure in v04_browser_simulation job 113386892960: Standalone Rental HTML overflow at **390px** in new standalone_fusion_browser.py:91. Existing Full admin browser test passed. This is a UI layout bug, not permission, money or QR route change.

Scoped patch: Standalone HTML CSS commit 52da18e6ea1d314158edd7ffc0daaf909a9d39ef constrains grid/flex min-width and wraps long values without hiding horizontal overflow; browser diagnostics commit d616c16b4c41bc3870352e647978d0b8471d7a23 records viewport, actual document width and oversize elements if the new 360/390px assertion fails. Current state and change ledger have recorded exact source/test commits; this root update is the final checkpoint.

**NEXT NOW:** inspect exact-new-HEAD `validate` (both Full/Standalone theme smoke), `v04_browser_simulation` (360/390px + QR), full firmware/Android candidate gate and Windows EXE/handover. If a layout failure persists, use geometry evidence to fix the responsible element only. Published Full v0.5.2, Standalone Rental RC9 and Windows v0.4.0 assets remain unchanged. No 0.6.0 production release while P0 financial migration/real-device backups remain unresolved.

## UI-FUSION-0615 — opt-in EasyMode R281 offline preview (SOURCE COMMITTED, CI UNVERIFIED)

The independent EasyMode project currently has an existing deployed R281 v4.2.3 source snapshot and a separate 5.0.0-alpha installer. **Neither is modified**. The owner's cross-subsystem request is implemented as a **developer-only staged preview**, not a production firmware install or merger of distinct session/network/billing engines.

- New EasyMode offline BlazeFusion CSS and appearance-only JS: commits `14ea130663fbbd5f2877d4be69616396b770369e` and `ab4e27082fec220a9aec86a5fca02e2614c6e151`. Three modes share only nonsecret browser preference; existing server-side light/dark/accent, UBus session, network/SMS/WAN and administrative controls remain unchanged.
- `experiment/openwrt/easymode-project/integrations/blazefusion/build-preview.py`, commit `fbff495182023880f5979a1ac7f83f469fd6271d`, can produce a NEW offline directory from audited historical R281 static sources. Refuses an existing output or source marker mismatch. **This is not an OpenWrt installer**.
- New mandatory BlazePwifi CI static staging/immutability test `tests/v060_easymode_fusion.sh` (`5082b674eb8fa4ced83f312fe9d8402b4960466a`, workflow `896fc66e...`), browser visual-only test `simulation/easymode_fusion_browser.py` (`d9fd3c33...`, workflow `03689bea...`), developer README `e8665abf...`, design contract update `44911c32...`.
- **NEXT NOW:** check latest exact-head CI `validate` EasyMode staging and real Chromium visual smoke, Full Android/firmware gate, and Windows handover/installer. A Chromium preview that reveals the dashboard without login is NOT an authentication test; production rollback/backup and on-device integration must be separately approved.
- Prior Full+Standalone source SHA `74623164a808f22d0f1adbf4468b32c19c3cfb69` passed 26 Full jobs and Windows 2 jobs; it predates EasyMode preview. v0.6.0 signed production release remains BLOCKED on financial transaction migration/rollback, physical sysupgrade recovery, permanent Lineage-2 signer and OEM acceptance.

## NEXT EXACT ACTION / safe resume

1. Read `docs/handover/CURRENT_STATE.md` for the complete latest issue register. The **verified development source** is `d1e7fb4187e2d0701f4e2b5c842c8711eb09d756`: full GitHub Actions #37774312541 (**26 success, 0 failure**) and Windows #37774312533 (**2 success**) passed. **This document update creates a new documentation SHA; do not misrepresent it as the source SHA certified by those runs.**
2. Start a scoped **v0.6.0 migration and release-identity plan**: update VERSION/Android `versionCode` only after accounting/member/rental data migration, rescue rollback, permanent APK signer and protocol compatibilities are reviewed and tested. Do not tag, sign or publish solely because the 0.5.3-versioned development CI is green.
3. Test P0 money/security/recovery on physical hardware: USB/serial 60-minute Windows timer, centralized one-coinslot/many-PC, coin pulse ACK/replay and power cuts, simultaneous voucher/rental/PisoWiFi purchases, VLAN13 bridge identity, Android factory-reset Device Owner and normal binding paths.
4. Before each meaningful source change, update `CURRENT_STATE.md` to IN PROGRESS; after every code/test/decision, append the exact commit/run to `CHANGE_LEDGER.md` and synchronize this root status. The handover freshness and negative fixture gates are required on Full and Windows CI.
5. Keep v0.5.2 Full, Standalone Rental RC9, permanent Lineage-2 signing identity, and Windows `softtimer-v0.4.0` artifacts frozen. Keep [PR #30](https://github.com/BlazingSystems/BlazingSystems-Experiments/pull/30) draft until 0.6.0 versioned release-specific and field-acceptance gates exist.

## Copyable next-chat instruction

```text
@GitHub Open BlazingSystems/BlazingSystems-Experiments.
Read experiment/openwrt/BlazePwifi/PROJECT_HANDOVER.md TOP CURRENT STATUS,
then docs/handover/CURRENT_STATE.md, HANDOVER_POLICY.md, CHANGE_LEDGER.md,
AUDIT.md and draft PR #30. Verify the current branch head, recent commits,
Actions HEAD SHAs/conclusions, release tags and all active blockers.
Continue ONLY the exact NEXT ACTION in CURRENT_STATE.md; record work IN
PROGRESS before editing and update live state + change ledger + canonical
handover after each meaningful code/test/failure change. Keep existing
production tags/standalone rental/signing lineage untouched and fail closed
on financial/security data until tested. Do not claim a signed 0.6.0 release
without exact-SHA comprehensive gates, migration and hardware evidence.
```

---

# ARCHIVED HANDOVER — historical decisions, *not* current operational status

# BlazePwifi Project Handover

**Last updated:** 2026-10-07  
**Repository:** BlazingSystems/BlazingSystems-Experiments  
**Production baseline:** BlazePwifi **v0.5.2** is the frozen production release. BlazeRental production signing lineage `BlazeRental-production-lineage2` is established and must be preserved for all future production upgrades.  
**Active development:** **v0.5.3-dev.5 ZeroTier live activation**. Exact green application candidate `29a3815e81c9bd7db54c8f60eb6f579c818f34ad`; push workflow `37540065074` — PASS; PR #25 synthetic merge-tree workflow `37540072921` — PASS. This remains development-only; no v0.5.3 production tag/signing action has been taken.  
**Scope guard:** Full BlazePwifi is the active product. `profiles/standalone-rental` is reference-only and must not be modified by Full BlazePwifi work unless the owner explicitly changes that instruction.

## Current v0.5.3 development status

The post-v0.5.2 hardening work is implemented and artifact-validated. This is a **development line**, not a production v0.5.3 release.

- Development identity: `0.5.3-dev.5`.
- Android development versionCode: `50294`.
- Reserved development range: `50290–50298`.
- Frozen v0.5.2 rollback rescue versionCode: `50299`.
- Reserved final v0.5.3 production versionCode: `50300`.
- Full-console CSRF mutations now send both form-body and header tokens, use same-origin/no-store requests, refresh stale sessions and retry a CSRF mismatch once.
- Rental setup now has two explicit QR paths:
  - **Binding QR** for an already-installed BlazeRental APK;
  - **Device Owner Provisioning QR** for factory-reset Android Setup Wizard.
- Device Owner provisioning binds to the published signed APK checksum and pins the local BlazePwifi TLS certificate for secure enrollment against the default self-signed admin certificate.
- One-time enrollment is retry-safe across a lost response: the same persisted request nonce returns the same permanent identity, a different nonce is rejected, and the enrollment response is HMAC-authenticated before BlazeRental commits identity.
- BlazeRental and the PisoWiFi captive portal now have separate server-authoritative:
  - purchased/session countdown;
  - Insert Coin reservation countdown.
- Rental coin progress is server-accounted and signed: accepted pulse count and centavo value are displayed, duplicate Vendo events do not add credit twice, repeated open requests reuse the same active reservation, and Done/expiry releases the target.
- BlazeRental runtime UI now visibly renders `BLAZERENTAL`, `00:00:00`, `TIME FINISHED` and `INSERT COIN` in the unpaid Device Owner state.
- Exact green validation run `37486090360` passed:
  - static/security/config/integration/stress validation;
  - Android current + frozen-v0.5.2 rescue APK builds;
  - Android Device Owner emulator;
  - browser QR/CSRF/session-timer/coin-window runtime audit;
  - ESP8266 and ESP32 build/simulation;
  - Ruijie build/simulation;
  - x86_64 build + QEMU simulation;
  - required Orange Pi build/simulation targets;
  - transactional update bundle;
  - final candidate gate.
- Runtime Android audit artifact: `BlazePwifi-v0.5-android-simulation`.
- Current Android build artifact: `BlazePwifi-android-current`.
- Current update artifact: `BlazePwifi-current-update`.
- Current candidate-gate artifact: `BlazePwifi-current-candidate-gate`.
- **dev.2 Management Console operations are green:**
  - Advanced Terminal is disabled by default and requires admin re-authentication, CSRF, session/IP binding, short TTL/idle expiry, bounded runtime/output and single-command concurrency.
  - Advanced Terminal session tokens remain browser-memory-only; no localStorage/sessionStorage persistence.
  - High-risk appliance lifecycle/storage commands are blocked from the raw terminal path.
  - Safe Tools now include WAN/NTP/jitter/TCP-port/neighbors/controllers/services/logs diagnostics in addition to existing commands.
  - Worldwide Remote Access profiles support Disabled/WireGuard/ZeroTier staging with separate Monitoring/Management/Remote-Terminal permissions and no private-key field.
  - Remote live network/firewall activation remains intentionally safety-locked until a separate apply/rollback network-survival matrix is green.
  - Dynamic shell security test and Playwright user-flow audit both passed.
- Exact dev.2 branch workflow `37500821733` passed all required Android, browser, ESP8266/ESP32, Ruijie, Orange Pi, x86 QEMU, update-bundle and final candidate gates.
- PR #18 reconciles dev.2 with the four newer unrelated BlazePisonet SoftTimer commits on `main`. Synthetic merge tree `dee385974b7142afa4e8a56fc47d611f62a10ccf` passed workflow `37500829258`, including browser runtime, x86 QEMU, Android Device Owner emulator and final candidate gate.
- During PR validation a real UI race was found and fixed: an unconditional delayed startup `loadRemote()` could reset the selected remote mode while the operator was editing. The fixed console no longer preloads editable remote config in the background, suppresses stale async responses, and renders the authoritative save response immediately.
- Android Device Owner emulator explicitly passed `0.5.3-dev.2` using `candidate/android/BlazeRental-0.5.3-dev.2-ci.apk`.
- **dev.3 transactional WireGuard live activation is green on the Full BlazePwifi branch:**
  - WireGuard private key is generated/stored on-device with restrictive permissions; browser/API exposes only the public key.
  - Blaze-owned UCI network/firewall sections are used; existing LAN/WAN/EasyMode sections stay outside dev.3 ownership.
  - Unsafe routes are rejected before apply: default/full tunnel, overly broad routes, directly connected overlaps and current-admin-path capture.
  - Apply uses network/firewall/runtime snapshots, a detached watchdog and boot-time recovery.
  - Success requires interface start, firewall reload, a verified WireGuard handshake, and unchanged default/current management route signatures.
  - Failure restores the previous network/firewall/runtime state, including an older active Blaze WireGuard tunnel when updating it.
  - Remote admin uses a dedicated WireGuard-only HTTPS service with a restricted admin-only web root; the normal LAN admin/captive portal/Rental/Vendo surface is not exposed on the remote listener.
  - Remote Terminal permission is enforced server-side on the WireGuard admin path.
  - Console now exposes device public-key generation, staged profile save, Test & Apply, activation/handshake status and safe disable.
  - ZeroTier live activation remains staged-only in dev.3.
  - Exact branch workflow `37516557416` passed validation, browser runtime, Android build, Device Owner emulator, x86 QEMU, ESP8266/ESP32, Ruijie, required Orange Pi targets, update bundle and final candidate gate.
- **dev.4 Pisonet member metadata migration is green:**
  - export is verifier-free: no plaintext password, password hash/verifier, salt, KDF scheme or rounds are present;
  - strict portable `BLAZE_MEMBER_METADATA_V1` carries username, label/source metadata, enabled request, banked seconds and timestamps only;
  - import is preview-first and Apply requires Admin + CSRF + fresh password re-authentication;
  - preview tokens are TTL-limited, single-use, bound to admin session/IP and pinned to the central member revision;
  - collisions are explicit: abort, skip, or metadata-only update; no silent overwrite;
  - metadata-only collision updates preserve the existing central password verifier;
  - new members are created disabled with `reset_required` state and need a normal admin password reset before enable/authentication;
  - imports are transactional across member records, event history and global revision, with full rollback on injected mid-import failure;
  - duplicate usernames, malformed fields and oversized files/member sets are rejected;
  - the optional-empty-label member-store parsing bug was fixed across CRUD/auth/balance/transfer/public-list/snapshot/export paths;
  - exact application candidate `723c9c2191542e6f6867ee5fbbc31083590b49f2`, workflow `37527877646`, passed validation, migration regression, Playwright, Android build, Device Owner emulator, x86 QEMU, ESP8266/ESP32, Ruijie, required Orange Pi targets, update bundle and final candidate gate;
  - retained browser audit reports `member_metadata_export=true`, `member_import_preview=true`, `member_import_apply=true`, `dual_csrf_transport=true`, and `console_errors=false`.
- **dev.5 transactional ZeroTier live activation is green:**
  - stable ZeroTier identity is generated/stored on-device; browser/API exposes only node ID, never `global.secret`;
  - only Blaze-owned modern UCI section `zerotier.blazepwifi` is managed; legacy `.join` or foreign/custom network sections are refused safely;
  - the untouched stock `earth` sample is pruned only when still exactly default and unused;
  - Blaze network policy remains `allow_managed=1`, `allow_global=0`, `allow_default=0`, `allow_dns=0`;
  - apply requires ONLINE/TUNNELED node state, network OK, real interface, assigned IPv4, safe mesh routes, firewall/admin-listener success, and management/default-route survival;
  - ACCESS_DENIED, unsafe/overlapping/default routes, missing interface/address, listener/firewall failure, watchdog/reboot interruption and lost transaction ownership restore the previous state;
  - WireGuard and ZeroTier active transports are mutually exclusive;
  - disable is rejected from the ZeroTier path itself and preserves stable identity;
  - snapshots containing ZeroTier secret material are restrictive and deleted after success/rollback;
  - an existing valid `global.secret` is now a true no-op before snapshot creation, fixing a pre-transaction UCI mutation/line-reordering defect;
  - the transaction engine was rebuilt from the last clean sealed source after detecting a malformed duplicate tail; static validation again enforces one valid engine ending at the authoritative EOF marker;
  - retained browser audit reports `zerotier_identity_prepared=true`, `zerotier_live_apply=true`, `zerotier_safe_disable=true`, `wireguard_live_apply=true`, `member_import_apply=true`, and `console_errors=false`;
  - exact application candidate `29a3815e81c9bd7db54c8f60eb6f579c818f34ad`, push workflow `37540065074` and PR #25 merge-tree workflow `37540072921` both passed the full matrix.
- Full BlazePwifi dev.5 has zero changes under `profiles/standalone-rental`.
- No v0.5.3 production tag/release has been created.
- No production signing key was rotated or exposed.
- Frozen v0.5.2 release/tag and dedicated signing/recovery workflows remain unchanged.

## v0.5.3-dev.3 — BlazePisonet SoftTimer member authority

This is a **required architecture rule** for all future BlazePwifi + BlazePisonet SoftTimer work.

### Ownership rule

- **BlazePwifi Management Console is the central authority for SoftTimer member accounts whenever BlazePwifi integration is enabled.**
- Member creation, editing, enable/disable, password reset, banked-time adjustment, deletion/revocation and audit belong in **BlazePwifi Admin → Pisonet Members**.
- BlazePisonet SoftTimer must not maintain an independent authoritative member balance database while connected to BlazePwifi.
- SoftTimer may keep a signed/revisioned last-known-good **metadata** cache for display/discovery and resilience, but dev.3 does not distribute reusable password-verifier hashes to PCs. Central BlazePwifi member revision and banked-time ledger always win.
- Standalone SoftTimer deployments with no BlazePwifi server may continue using local-only member storage.

### Member data model

Central member records must at minimum carry:

- normalized member username / stable member ID;
- display name or optional label;
- enabled/revoked state;
- password verifier material only (never plaintext);
- banked seconds;
- monotonically increasing record revision;
- updated timestamp;
- last modifying actor/source;
- bounded idempotent member-event history for bank/restore/transfer operations.

Passwords must never be returned to the browser, SoftTimer, logs, exports or audit records. The console can reset a password, but cannot reveal the old one.

### SoftTimer synchronization contract

The BlazePwifi ↔ SoftTimer member integration must use the existing trusted controller relationship rather than anonymous captive-portal APIs.

Required behavior:

1. SoftTimer identifies itself with its configured BlazePwifi controller ID and signed controller request.
2. SoftTimer periodically requests a member snapshot/revision from BlazePwifi.
3. BlazePwifi returns only cache-safe member metadata: username/label/enabled state, password KDF salt/round count, banked balance, revision and timestamps. It does **not** return the stored password verifier/hash. SoftTimer derives a verifier transiently from the password entered by the member and sends only a nonce/controller-bound proof.
4. SoftTimer atomically replaces/updates its local member cache only after validating the signed response/revision.
5. When online/integrated, banked-time mutations are sent to BlazePwifi as idempotent events and BlazePwifi is the authority for the resulting balance.
6. Lost/retried requests must not duplicate banked time, restored time or transfers.
7. In dev.3, if BlazePwifi is unreachable, **central member authentication and all balance mutations fail closed**. Cached metadata may still be displayed, but it cannot authorize/spend banked time. A future explicit encrypted/offline-spend lease design may relax this only with collision-safe reservations.
8. When connectivity returns, the newest authoritative BlazePwifi revision replaces stale cached balance state.
9. BANK/RESTORE operations use a durable pending-event journal on SoftTimer. While an event is unresolved the local countdown is frozen, the station remains locked and new coin input is rejected.
10. BlazePwifi binds committed replay to the original controller ID + member + operation kind + event ID. SoftTimer can therefore recover an already-committed event after a crash without persisting the member password.
11. If BlazePwifi never received the original event, the pending event remains unresolved until the member re-enters the password; the retry must reuse the same event ID.

### Management Console requirements

Add a dedicated **Pisonet Members** page, separate from administrator accounts and hotspot device accounts.

Minimum console actions:

- list/search members;
- add member;
- edit label/name;
- enable/disable/revoke;
- reset password;
- view/set/add/subtract banked time;
- inspect revision / last update / source;
- view recent member events;
- transfer banked time between members;
- export/import member metadata without plaintext passwords — **implemented in dev.4 with reviewed preview, collision policy, fresh re-authentication and transactional rollback**.

Viewer role may read non-secret member status. Operator may create/edit ordinary member state and banked time within policy. Password reset, destructive delete/revoke and bulk import require Admin plus CSRF; high-risk bulk operations should require fresh re-authentication.

### Compatibility / migration

- Existing v0.3.0 SoftTimer local members must not be silently destroyed.
- Existing local SoftTimer members are still not silently auto-migrated.
- dev.4 provides an explicit metadata-only local→central migration/import workflow with reviewed username-collision classification and no silent overwrite.
- Password verifier/hash material is never imported through this workflow; new imported central members are disabled and require password reset before enable/authentication.
- SoftTimer remains able to operate in **Local Members** mode when BlazePwifi member authority is disabled.

### Scope guard

- Do **not** implement this by modifying `profiles/standalone-rental`. This belongs to Full BlazePwifi Management Console + BlazePisonet SoftTimer integration. Existing BlazeRental phone enrollment/member-independent rental accounting must continue to work unchanged.

### Validation gates for dev.3

- static shell validation for the member library/API;
- member CRUD/revision/idempotency tests;
- password-verifier non-disclosure test;
- browser Management Console member-flow test for current CRUD/balance/audit actions;
- SoftTimer build with warnings-as-errors;
- SoftTimer online sync / nonce-proof authentication / offline fail-closed authentication-and-balance test;
- duplicate bank/restore/transfer event test, including controller-bound crash replay without a stored plaintext password;
- full existing BlazePwifi regression matrix, including Android, ESP, Ruijie, Orange Pi and x86/QEMU gates;
- no production v0.5.3 tag/signing action from this development branch.

## Historical v0.5.1 maintenance target

The owner requested a maintenance release that eliminates full-system reflashing for ordinary feature/revision upgrades and adds safe rollback for BlazePwifi and BlazeRental.

Implemented on `blazepwifi-v0.5.1-implementation`:

- Transactional BlazePwifi overlay updater with exact SHA-256 verification.
- Configurable HTTPS update source, size bound, stability grace and rollback retention.
- Last-known-good snapshots before file replacement.
- Immediate health-check rollback and boot-health rollback guard.
- Manual rollback from Management Console → Updates & Recovery.
- Idempotent configuration migration; normal feature bundles do not overwrite persistent operator/session state.
- One-time v0.5.0 → v0.5.1 no-reflash bootstrap updater.
- Build-time `BlazePwifi-v0.5.1-update.tar.gz` generation.
- BlazeRental v0.5.1 version code `50100`.
- BlazeRental managed updater verifies SHA-256, package name and installed signing identity.
- Previous APK/version metadata retained; new build becomes stable only after a 30-second launcher health window.
- Known-good v0.5.0 rollback rescue is rebuilt from exact RC9 source `66e159b65b6d8fb5f74dd981dc73d46db7229adc` using recovery-only version code `50101`.
- Repeated failed boots while a Rental update remains pending can stage the configured rescue APK.
- Native Rental Admin update/check/rollback controls.
- Central Rental Update Manager in the BlazePwifi console.
- Locked v0.5.1 production signer workflow signs both current and rescue APKs with the exact existing certificate and refuses rotation.
- v0.5.1 release workflow supports validated prerelease publication if the locked signer remains unavailable.

Full firmware/sysupgrade remains reserved for base-system changes such as kernel, bootloader, partition/ABI or filesystem changes that cannot safely be delivered as an overlay.

## Current v0.5.1 release status

- GitHub Release: `v0.5.1` — **published prerelease**
- Release ID: `404404262`
- Release page: `https://github.com/BlazingSystems/BlazingSystems-Experiments/releases/tag/v0.5.1`
- Exact validated candidate: `65f87d775793a1fdc09a9522cf752349f68c3b41`
- Validated build run: `37425063793` — **PASS**
- Validate/static/security/integration/stress: PASS.
- Transactional update/rollback regression: PASS.
- BlazeRental v0.5.1 update contract: PASS.
- Android APK build: PASS.
- Android Device Owner emulator: PASS.
- Browser, ESP8266, ESP32, Ruijie, x86 and required Orange Pi simulations: PASS.
- Final candidate gate: PASS.
- Release workflow run: `37426030884` — **PASS**
- Release target remains exact candidate SHA `65f87d775793a1fdc09a9522cf752349f68c3b41`.
- Update assets include:
  - `BlazePwifi-v0.5.1-update.tar.gz`
  - `BlazePwifi-v0.5.1-update-bootstrap.sh`
  - `BlazePwifi-v0.5.1-update-bootstrap.sh.sha256`
- Android validation/recovery assets include:
  - `BlazeRental-v0.5.1-TEST.apk`
  - `BlazeRental-v0.5.1-release-unsigned.apk`
  - `BlazeRental-v0.5.0-rescue-for-v0.5.1-TEST.apk`
  - `BlazeRental-v0.5.0-rescue-for-v0.5.1-release-unsigned.apk`
- Locked signing run `37425929657` failed safely at `Restore exact locked v0.4 production identity` because the exact keystore / `BLAZERENTAL_TRANSFER_PRIVATE_KEY_PEM` remains unavailable.
- The signing workflow refused certificate rotation. Therefore production `BlazeRental.apk` and signed rescue APK are intentionally absent.
- Locked production fingerprint remains:
  `C7:7E:4D:A2:2E:92:D2:BE:7D:93:B9:D3:DC:7C:3F:77:56:C0:6A:5A:13:0E:C6:90:5A:DC:C2:AD:4E:A3:56:24`
- Canonical release log:
  `docs/handover/2026-10-06-v051-release-published.md`

## v0.5.1 main integration status

- BlazePwifi v0.5.1 is integrated into `main`.
- Published release candidate remains `65f87d775793a1fdc09a9522cf752349f68c3b41`.
- Published release build run: `37425063793` — PASS.
- Published release workflow: `37426030884` — PASS.
- Reconciled main integration SHA: `e081c6bdfc41d22ac07f918c4cbc62a745bca883`.
- Reconciled integration build run: `37426701445` — PASS, including Android Device Owner emulator, x86 QEMU and final candidate gate.
- Pull request `#14` — merged.
- Main merge commit: `1aa8926563e6dccb6a512a035e8f6f662b997d57`.
- Main merge tree: `f1c0194f8039577bad88a6e93b02d9b837e228c2`, exactly matching the green integration tree.
- Post-merge main build run: `37427339687` — PASS, including Android Device Owner emulator, x86 QEMU and final candidate gate.
- All 19 newer main-only standalone-rental/release files were preserved byte-for-byte.
- Superseded conflicting PR `#13` was closed without merging.
- GitHub Release `v0.5.1` remains pinned to exact candidate `65f87d775793a1fdc09a9522cf752349f68c3b41`; main integration did not retag or rewrite the release.
- Production Android signing remains blocked only by unavailable exact locked v0.4 signing material.

## Main branch integration status

- Full BlazePwifi v0.5.0 implementation is integrated into `main`.
- Conflict-resolved integration SHA: `09710a6d093f125a444c86bc686985edbfc89553`.
- Integration CI run: `37396023917` — PASS, including Android Device Owner emulator and final candidate gate.
- Pull request: `#12` — merged.
- Main merge commit: `06ddc5909b178d316f0f4d6fb8104f64da9a1be9`.
- The merge tree is exactly `d8fe2e6b6fca5ee3f619bc1d2e8ab35c4abcc850`, the same tree validated on the integration branch.
- All 16 main-only paths were preserved byte-for-byte, including the offline preview artifacts, handover logs, and unrelated Easymode encrypted-release files.
- Superseded conflicted PR `#11` was closed without merging.
- The `v0.5.0` tag/release remains pinned to validated RC9 candidate `66e159b65b6d8fb5f74dd981dc73d46db7229adc`; integrating code into main did not move or rewrite the release tag.
- Production Android signing remains intentionally blocked until the exact locked v0.4 signer is restored.

## Current v0.5.0 release status

- GitHub Release: `v0.5.0` — **published prerelease**
- Release ID: `403831689`
- Release page: `https://github.com/BlazingSystems/BlazingSystems-Experiments/releases/tag/v0.5.0`
- Exact validated candidate: `66e159b65b6d8fb5f74dd981dc73d46db7229adc`
- Candidate branch: `blazepwifi-v0.5.0-rc9`
- Validated build run: `37326542666` — PASS
- Final candidate gate: PASS
- Release workflow run: `37327843195` — PASS
- Release-stage artifact: `11352224246`
- Tag `v0.5.0` points exactly to the validated RC9 commit.
- `RELEASE-MANIFEST.json`: `candidate_gate=passed`, `production_signed=false`, `signing_run_id=0`.
- Android release assets currently include:
  - `BlazeRental-v0.5.0-TEST.apk`
  - `BlazeRental-v0.5.0-release-unsigned.apk`
- A production `BlazeRental.apk` is intentionally absent until the locked v0.4 signer is restored.
- Locked signing run `37327439782` failed safely because `BLAZERENTAL_TRANSFER_PRIVATE_KEY_PEM` / exact keystore was unavailable; it refused certificate rotation. A second attempt on 2026-10-06 (`run_attempt=2`) reached the same protected restore step and failed for the same reason, again without altering the release or rotating the certificate.
- Locked production fingerprint remains:
  `C7:7E:4D:A2:2E:92:D2:BE:7D:93:B9:D3:DC:7C:3F:77:56:C0:6A:5A:13:0E:C6:90:5A:DC:C2:AD:4E:A3:56:24`
- Canonical final release log:
  `docs/handover/2026-10-05-v050-release-published.md`

## Current v0.5.2 candidate status — 2026-10-06

- Exact candidate: `bf2992977fe8504d21b107df02826032c31d3a62`
- Exact build run: `37443570618` — **PASS**
- v0.5.2 LCM branding/alarm contracts: PASS.
- Android normal + v0.5.1 rescue APK build: PASS.
- Android Device Owner emulator: PASS.
- Transactional v0.5.2 update bundle: PASS.
- Browser, ESP, Ruijie, x86 and required Orange Pi simulations: PASS.
- Final v0.5.2 candidate gate: PASS.
- Release must be published from this exact candidate before production signing.
- Initial signing run ID must be `0`; Android assets remain TEST/unsigned until the later new-lineage signing step.

## Current v0.5.2 production release status — 2026-10-06

- GitHub Release: `v0.5.2` — **published production release**
- Release ID: `404545281`
- Exact release candidate: `bf2992977fe8504d21b107df02826032c31d3a62`
- Exact build run: `37443570618` — **PASS**
- Production signing run: `37448352082` — **PASS**
- Signing artifact: `11404278200`
- Production promotion/release run: `37448830953` — **PASS**
- Release title: `BlazePwifi v0.5.2 — LCM Branding & Rental Time Alarms`
- Release target remains exactly the green candidate; signing/recovery/docs commits did not retag the application.
- Release is no longer a prerelease.
- Production BlazeRental certificate lineage: `BlazeRental-production-lineage2`
- Permanent SHA-256 certificate fingerprint:
  `1A:18:D5:8E:1F:95:55:96:89:10:20:71:F5:6C:93:E9:B9:D2:EA:6B:E4:0E:6F:20:70:06:C9:89:62:A1:6A:25`
- Production `BlazeRental.apk` SHA-256:
  `d0ad20bed00ea304db9bff45928542fed574070d416ed65b4fbf3d8ba23d7102`
- Production rollback-rescue SHA-256:
  `a1c8d759405842b85879c77e9525b1a6e9c4f6d62eb8bda9b0abc60fb899d513`
- Recovery A and Recovery B both successfully decrypted the sealed signer backup and restored a P12 matching the permanent fingerprint.
- Recovery A private key is retained in the owner's private ChatGPT Library under `/BlazePwifi Signing Recovery/`.
- Recovery B is the independent owner/offline recovery copy.
- GitHub stores only public recovery keys and AES-256-GCM encrypted signing material.
- `SIGNING_RECOVERY.md` is the permanent recovery entry point.
- The release includes signed main/rescue APKs, certificate/fingerprint, dual recovery assets, production Device Owner QR/provisioning assets, and correct release-level checksums.
- The original signing artifact checksum file referenced two temporary aligned APKs deleted before upload; all retained files verified correctly. The workflow bookkeeping was corrected in commit `1fd5720a101a3d88bbe05e70158736983fbbad6e` and the published release recomputed a clean release-level `SHA256SUMS`.
- The LCM production PNG is the clean 128×128 derivative of the user-supplied source and its Git blob is `19f1c2f843dca1f9f6e320ea0dbd94580f85e608`.
- Near End default: 10 minutes / 5-second ring.
- Urgent Add Credit default: 3 minutes / 10-second ring.
- Time's Up default: 00:00 / 15-second ring.
- Audible alarms use STREAM_ALARM, enforced non-zero minimum volume, optional DND override, and restore prior audio state after playback.
- Migration from the abandoned old v0.4 signer requires reprovision/factory reset. Once on v0.5.2 Lineage 2, all future production BlazeRental APKs must use this exact certificate.
- No older standalone release is to be newly production-signed.

## Current target

BlazePwifi is being developed as a complete PisoWiFi + Android rental-device platform with a full management console, customizable captive portal system, coin/Vendo controllers, vouchers, sales, networking/WAN/LAN/VLAN management, backups, multimedia, BlazeGames management, and BlazeRental Launcher3 integration.

## Current BlazeRental direction

Approved redesign direction:

- Rename the launcher/app from Rootless Pixel Launcher branding to **BlazeRental**.
- Use the approved LCM/BlazeRental icon family for APK/app branding and wider Blaze ecosystem branding where appropriate.
- Restore normal Launcher3 behavior instead of the current three-page rental replacement.
- Far-left page: BlazeRental / Insert Coin portal.
- Next page: Notifications.
- Then normal Launcher3 home pages.
- Swipe-up All Apps is allowed only while rental time is valid or `Use device as is` is enabled.
- Unpaid rental mode fails closed to the BlazeRental Insert Coin page.
- `Use device as is` must be available as a daily-driver mode and must not require BlazePwifi enrollment.
- Notifications page needs Clear All.
- On-device admin must be redesigned as a polished native Android management UI.
- QR scanner must preserve camera aspect ratio and use a stable scan frame.
- Rental Insert Coin appearance/sounds must be customizable from the on-device admin.

## Portal / management-console direction

- Core UI must not depend on Bootstrap, jQuery, CDN, or heavy framework runtimes.
- Factory Blaze portal is permanent/undeletable and acts as fallback.
- Portal Designer must support Add Portal Template and custom HTML/CSS/JS/media/sounds.
- LPB-style behavior should be supported through a compatibility layer without copying LPB visual design.
- Default portal must be child-friendly at first glance and expose richer safe network/device/system details when scrolled.
- Management Console should become a complete operating console, not a small admin page.
- Console richness includes Alerts, Scheduler/Automation, Announcements, Theme/Branding management, Audit Logs, Role-based Accounts, Import/Export, Template Sandbox/Safe Preview, API/Webhooks, Hardware Capability page, File/Asset Manager, Recovery/Fallback tools, Data Usage/Quota, Reports, Search/Quick Actions, Notes/Tags, and Multi-profile/Presets.
- Add a dedicated **Tools** module: ping, traceroute, DNS test, speed test, WAN reachability, port check, NTP test, Wi-Fi scan, interface diagnostics, controller tests, latency/jitter/packet-loss testing, safe local discovery, logs, service tools, storage cleanup, and diagnostics export.


## Management Console terminal / command tools

Approved design direction:

- Add a **Terminal / CMD** area to the Management Console.
- Do **not** expose an unrestricted web shell by default.
- Provide two levels:
  - **Safe Commands**: curated/allowlisted commands and guided tools for common admin tasks.
  - **Advanced Terminal**: optional owner-only shell with explicit enablement, re-authentication, timeout, audit logging, and strong rate/concurrency limits.
- Safe Commands should cover common operations such as:
  - ping, traceroute, nslookup/dig, route/ip status;
  - interface/WAN/LAN/VLAN status;
  - Wi-Fi scan/status;
  - storage/mount/USB status;
  - process/service status;
  - log viewing/tailing;
  - package/version checks;
  - network diagnostics;
  - controller diagnostics;
  - read-only hardware/runtime inspection.
- Dangerous/destructive actions should use dedicated Management Console controls or guarded command wrappers rather than raw arbitrary shell wherever practical.
- Advanced Terminal must be owner/admin-role restricted, disabled by default on Lite/public-facing deployments, and protected with:
  - fresh password re-authentication;
  - short-lived terminal session;
  - CSRF/session binding;
  - command audit history;
  - output/time limits;
  - idle timeout;
  - concurrent terminal/session limits;
  - brute-force/rate-limit protections;
  - no anonymous or portal-side access;
  - optional LAN-only/local-management restriction.
- Terminal access must never be exposed to captive-portal users.
- On constrained OpenWrt devices, prefer a small streamed command runner rather than a heavy full browser terminal emulator.


## Remote monitoring / remote management

Approved design direction:

- Add a dedicated **Remote Access / Fleet Management** section to the Management Console.
- The primary user goal is **true worldwide access**: the owner must be able to open and manage their BlazePwifi/PisoWiFi system from anywhere on the Internet (for example from mobile data, another city, or another country) without needing to be on the local LAN.
- The preferred UX is a normal browser-accessible remote console reached through the configured private overlay/VPN path, not direct public-WAN exposure of the admin page.
- Remote monitoring/management should work even when the BlazePwifi site is behind NAT/CGNAT, provided one of the supported outbound tunnel methods is configured.
- Do not hard-code a vendor, account, endpoint, address, key, subnet, route, or management scope. All remote-access parameters must be owner-configurable.
- Remote access is **disabled by default** until the owner explicitly configures it.
- When Remote Access is enabled, offer exactly two first-class modes:
  1. **WireGuard VPN — Recommended/default selection**
     - preferred for BlazePwifi because it is lightweight, OpenWrt-native/well-supported, owner-controlled, and suitable for site-to-site or outbound-to-hub management;
     - support a BlazePwifi node behind NAT/CGNAT by allowing it to initiate an outbound WireGuard tunnel to an owner-controlled hub/VPS/router;
     - configurable endpoint/FQDN, port, peer/public keys, optional preshared key, tunnel address, allowed IPs/routes, persistent keepalive, DNS, MTU, reconnect/health-check and management subnets;
     - private keys remain local and are never displayed after creation/export unless the owner explicitly rotates/reprovisions them.
  2. **ZeroTier — Easy-mesh alternative**
     - intended for simpler NAT/CGNAT traversal and multi-site mesh enrollment;
     - configurable Network ID, authorization state, managed IP/routes, local interface/firewall scope, low-bandwidth option where supported, and reconnect/health state;
     - no hard-coded ZeroTier account/network dependency.

- Monitoring and management permissions must be independently configurable:
  - Remote Monitoring only (read-only metrics/status);
  - Remote Management (configuration changes);
  - Remote Terminal (separate advanced permission, off by default).
- Remote-access scope should be configurable per service/module:
  - Dashboard/status;
  - alerts/events;
  - clients/sessions;
  - sales/reports;
  - backups;
  - portal/templates;
  - rental devices;
  - controllers;
  - network/WAN/LAN/VLAN;
  - system/firmware;
  - tools;
  - terminal.
- Add optional fleet-style status:
  - node name/site/location label;
  - online/offline;
  - last seen;
  - WAN health;
  - tunnel health/last handshake;
  - public/overlay/tunnel IPs where appropriate;
  - CPU/RAM/storage/temp;
  - active clients/sessions;
  - controller/rental-device health;
  - firmware/version;
  - alerts and backup status.
- Configurable heartbeat/refresh interval, offline-alert threshold, reconnect behavior, telemetry retention and alert severity.
- Remote management must bind to LAN/VPN/overlay interfaces only by default and must **not expose the Management Console directly to the public WAN**.
- Support configurable allowlists for remote management source addresses/subnets.
- Re-authentication should be required for high-risk actions such as firmware updates, factory reset, backup restore, credential/key changes and Advanced Terminal.
- Maintain complete audit logging of remote sessions and state-changing actions.
- Rate limits, session limits, timeouts and abuse controls apply equally to remote access.
- If the VPN/overlay fails, local LAN management and the captive portal must continue working normally.

## Networking / operations requirements captured

- Multiple WAN modes including Ethernet, WISP when Wi-Fi hardware is available, USB Ethernet, dual-WAN load balancing and failover.
- LAN/PisoWiFi AP modes including VLAN, second Ethernet, USB Ethernet, bridge/router modes.
- Voucher generator/designer/export.
- Rental settings and QR provisioning.
- Rental customization.
- Sales reporting.
- Device management.
- Manual/automatic backups with retention limits, download/import/restore.
- Sessions, rates, controllers, diagnostics, system/security and hardware-capability-aware controls.

## Wi-Fi portal multimedia / games direction

Approved portal additions:

- Wi-Fi portal may expose **Movies/Multimedia** and **Games** sections.
- These sections apply to the Wi-Fi portal, not the BlazeRental launcher unless explicitly added later.
- Multimedia page contents are entirely controlled by the administrator.
- Each media item can be configured as:
  - free to view, or
  - requires an active paid session with time actively running (paused time does not qualify).
- Add a **Multimedia Manager** to the Management Console:
  - detect removable USB storage when available;
  - allow supported internal/SSD/SD storage on larger builds;
  - choose multimedia storage target;
  - upload/import/delete/rename media;
  - folders/categories/collections;
  - poster/thumbnail/metadata management;
  - free-vs-paid-session access policy per item/category;
  - storage capacity/free-space/health view;
  - rescan/index storage;
  - safe eject/remount where supported;
  - media preview;
  - browser-native streaming with HTTP range support where practical;
  - no mandatory server-side transcoding on Lite targets.
- Add a **BlazeGames Manager** using the existing BlazeGames/offline arcade-emulator HTML project:
  - manage ROMs/content made available to users;
  - add/remove/enable/disable games;
  - categories/favorites/order/cover art/metadata;
  - storage target selection;
  - free-vs-active-session access policy;
  - emulator/core compatibility metadata;
  - per-game launch/test;
  - save-state/storage policy where supported;
  - keep Lite targets lightweight.
- Only administrator-supplied/licensed media and ROMs should be distributed; BlazePwifi should not ship copyrighted third-party content by default.

## Security / abuse-resistance requirements

The system must be designed to strongly resist brute-force and denial-of-service abuse, while avoiding claims of being literally “brute-force free” or “DDoS proof.”

Required controls include:

- escalating admin/login lockouts and rate limits;
- persistent lockout state where appropriate;
- strong password verification and secure secret storage;
- role/session controls, CSRF protection, nonces on state-changing APIs;
- request/body/upload size limits;
- connection/concurrency limits suitable for the hardware;
- per-client/IP/session token-bucket throttling for sensitive endpoints;
- login/API backoff and abuse detection;
- upload quotas and storage quotas;
- bounded logs and bounded backup/media retention;
- timeouts against slow/idle connections;
- fail-closed rental and policy behavior;
- static asset caching and lightweight portal rendering for constrained devices;
- audit/security event logging;
- safe recovery path for the owner.

## v0.5.0 implementation state

Implementation resumed by explicit owner instruction on 2026-10-05.

Current branch: `blazepwifi-v0.5.0-implementation`

Completed in the first v0.5 launcher milestone:

- Version bumped to 0.5.0 / Android versionCode 50000.
- User-visible Rootless Pixel/Launcher3 branding replaced with BlazeRental.
- Approved LCM icon added and wired as the APK launcher icon.
- Added one authoritative `canUseDevice()` gate: unrestricted OR valid paid lease.
- Added `BlazeLeftPanel` using Launcher3 custom-left content rather than deleting normal workspace pages.
- Unpaid rental state blocks leaving Blaze content for normal Home.
- Paid/unrestricted state restores normal Launcher3 chrome/interactions.
- Notifications gained Clear All support.
- First setup now offers `USE DEVICE AS IS · NORMAL LAUNCHER` without BlazePwifi enrollment.
- Legacy Google overlay is disabled so Blaze owns the custom-left gesture surface.

Next: complete v0.5 tests/emulator flow, QR scanner/native admin polish, rich Management Console/portal modules, then exact-SHA build and v0.5.0 release staging/publish.

## Last validated application candidate

BlazePwifi v0.5.0 RC9:

- Candidate SHA: `66e159b65b6d8fb5f74dd981dc73d46db7229adc`
- Build run: `37326542666` — PASS
- Candidate gate: PASS
- Android Device Owner emulator: PASS
- Browser/platform simulations: PASS
- Published as GitHub prerelease `v0.5.0`.

Previous v0.4 validated candidate remains `d2ee5e0c0493500ce6a0578b9cad5da0775be65e` with build run `37287301792`.

Do not replace or relabel the v0.5 TEST APK as production-signed. Production Android upgrade compatibility requires the existing locked v0.4 signing certificate.

## Latest preview artifact

An offline single-file Management Console + PisoWiFi Insert Coin + BlazeRental Insert Coin UX mockup was packaged as:

`preview/BlazePwifi_Offline_Management_Console_Preview.zip`

Mock login:

- username: `admin`
- password: `blaze1234`

This is a design mockup only and does not change production behavior.

## Resume rule

Before continuing implementation in a future chat:

1. Read this file.
2. Read the newest file in `docs/handover/`.
3. Inspect the current Git history and active implementation branch.
4. Reconcile repository state with these approved decisions.
5. Do not discard or redesign approved decisions unless the owner explicitly changes them.

## Logging rule

Update this handover at meaningful state changes: requirements, decisions, code/config changes, commits, tests, failures, fixes, workflow/build/release results, artifacts, blockers and exact next steps. Do not log every tool call.

### Mandatory success logging

Every successful milestone must also record:

- What changed and why.
- Exact files/areas touched.
- Commit SHA(s).
- Tests/audits performed.
- Successful workflow/build/release IDs when applicable.
- Any remaining known risks or limitations.
- Exact next recommended action.
- A ready-to-copy **Audit & Reconcile prompt** for a new chat.

Use this default prompt structure and specialize it to the latest milestone:

```text
@GitHub Reconcile and continue the BlazePwifi project from the repository state.

1. Read experiment/openwrt/BlazePwifi/PROJECT_HANDOVER.md.
2. Read the newest file under experiment/openwrt/BlazePwifi/docs/handover/.
3. Inspect the recent Git history, current implementation branch, relevant workflow results, release/assets, and files changed by the latest milestone.
4. Audit the latest successful change instead of assuming it is correct. Check for regressions, incomplete wiring, security/UX conflicts, stale documentation, and mismatches with approved requirements.
5. Reconcile repository state with the approved project target and decisions in the handover logs.
6. Preserve completed/approved decisions unless the owner explicitly changed them.
7. If the latest success has a test/build/release artifact, verify the exact SHA/run/artifact before building on top of it.
8. Continue from the exact NEXT ACTION recorded in the newest handover log.
9. Update PROJECT_HANDOVER.md and add a new dated handover log after every meaningful success, failure, blocker, or design change.
10. For every successful milestone, include a new Audit & Reconcile prompt in the handover log for the next chat.
```

Failures should also be logged when meaningful, including reproduction/evidence, suspected cause, what was tried, and the safest next action.
