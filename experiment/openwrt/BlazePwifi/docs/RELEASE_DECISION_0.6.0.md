## 2026-10-09 PRODUCT AUDIT UPDATE — v0.6 UX and Android security improvements, RELEASE BLOCKED

## V060-PRODUCT-RECON / UX+Rental security — 2026-10-09 (full-system risk-based reconciliation)

- **User objective RESTORED:** BlazePwifi v0.6.0 is a *complete* prepaid Wi-Fi + Windows PisoNet + Android Launcher3 rental + ESP/Linux coin-controller + Orange Pi/x86/OpenWrt administration and install system, not only a journal. User's CoreUI React and Metis archive contents were inspected: CoreUI 5.7.0 MIT React/Bootstrap/Chart.js, Metis 3.6.0 MIT Bootstrap/Alpine/Apexcharts. Use original, self-hosted no-runtime dependency designs for low-RAM Lite; rich libraries optional only after profiling Full edition. Preserve license notices for any reused code, never ship untracked proprietary assets.
- **Clean-room public behavior research and source-to-feature gap matrix:** new `docs/V060_COMPETITIVE_SYSTEM_AUDIT.md` commit `c96f5d10f41878d21ce1e453cf2ef6af33f685f9` compares primary AdoPiSoft/LPB/MikroTik RouterOS Hotspot/Antamedia/HandyCafe/Headwind MDM/Android Enterprise documented user flows, prepaid POS/AAA, vouchers, multi-vendo, dedicated-device provisioning, fleet security, and success metrics. This is architectural research, NOT commercial source reverse engineering or proof of outperforming competitors.
- **Operator UI production-source uplift:** commit `01d5f9f19d102cd5d2b9aa5761dcb0063863c2eb` modified `admin.html`, `vendor/blazefusion/{blaze-fusion.css,blaze-fusion.js}`, `admin/core.js` and `tests/v060_ui_fusion.sh`: original attractive offline command-center hero, clear Wi-Fi/PC/rental navigation, CTRL+K searchable sidebar and mobile-responsive states, authenticated API-based appliance link indicator (no simulated metrics), corrected literal newline between stylesheets. Does **not** add an unsafe shadow API/React runtime; auth and CSRF retained.
- **Android Device Owner security:** `android/BlazeRentalLauncher/src/com/blazesystems/blazerental/LeaseClient.java` `faf18f97ea1a862240836c62134454c587d08edd` prevents any unpinned HTTP/HTTPS fallback when `ManagedPolicyController.isDeviceOwner(context)` is true; ordinary manually-installed APK remains explicitly lower-security. `tests/v060_managed_tls_pin.sh` `021180b4e464aecc7234e6170bda7a06d011f72e`, Full CI `5826befaeff59d4e39fdb091e09e2a4e8c3d1f2f` adds Android managed-pin source gate. **Actual Android OEM provisioning / launcher UI and cert lifecycle not physically validated**.
- **Rental QR console and binding:** `admin/rental.js`, `admin.html` and `tests/v060_ui_fusion.sh` commit `7fcade91fdc8e83da6ffa6b6e8a180f70d4d695b` split lower-trust binding and factory-reset Device Owner QR paths in the browser, check server-provided managed pin and APK checksum metadata, refuse stale async response once modal closes, hide one-time token until explicit short reveal, clear on expiry/close. `tests/v060_rental_qr_browser.cjs` `65c15866e4877ac8996d51add37a418af93bc739` models browser async/invalid pin/secret display; Full CI step `fa9596ef6be56fac8c60a5d95ba9bfb772c07e1f`. Fix `bd45332f894b1c96415e0334d941e9808be79f8f` clears stale QR panel on invalid result. These are **UI safeguards**, not proof that published APK actually exists or is signed.
- **Release blockers PRECISELY UNCHANGED:** financial balances and receipts not crash-atomic; latest runtime containment quarantine can still leave partially applied money, unknown old IDs, other ordinary account coin replay. `VERSION` remains `0.5.3`, Android version 0.5.3, 0.6 updater correctly rejects unsupported state migration, missing 0.6 permanent signing lineage/rescue proof, no measured physical 30-device/coin-slot/power-cut/BYH hardware acceptance. Full+Windows prior source `c126781a0097d752590c1fa6793046d554aafb85` SUCCESS; new UI/Android changes must be retested at exact newest HEAD. **No `v0.6.0` production tag/published installable production assets. SUCCESS_REPORT=0.**
- **Next exact steps:** inspect new `validate` UI/QR/native Android security test output and the Windows & Android builds at final canonical HEAD. Repair any test regressions and capture exact-sha evidence. Prioritize real member/rental/account atomic journal, verified v0.5.x migration and update, Device Owner signed current+rescue and hardware/power tests; only then production version bump, sign and publish. No old tags/assets, customer state or keys were changed. Rollback UX via corresponding dev commits; managed-pin rollback would weaken security and requires explicit threat review.

## STATUS UPDATE — 2026-10-09 MIG-0625–0627: partial live-source P0 mitigations (NOT A RELEASE)

**Build code advanced beyond original successful source SHA**, so the earlier full green #37815563919 is HISTORICAL, not proof of latest source. At `member.sh` `8e71dc7...` the paid member event receipt no longer ages out with UI history and quota rejections occur before new credit; targeted #37818384347 and quota #37818772777 PASS. New `common.sh` and member/rental receipt EIO quarantine commits `a5b727d...`, `a31f48b...`, `025dc2e...` passed isolated staged #37819732052 on source `24700c204bb399ceab18d411176c05640ed201f3`. This is **partial safety containment**, not an atomic paid ledger: a changed balance may still await manual reconciliation; auto retry is blocked by persistent quarantine. Full/Windows exact newest SHA pending; physical flash sync/migration, 0.6 Android version/signing and published v0.6 remain blocked. **SUCCESS_REPORT=0**; all original release-blocker declarations below still apply except the old replay and false success-ACK scenarios now have scoped mitigations.

# BlazePwifi v0.6.0 production release decision — 2026-10-09 Asia/Manila

**Decision: BLOCKED — no public GitHub v0.6.0 production release; no installation authorized.**

```text
BUILD_MATRIX_SUCCESS=1
WINDOWS_BUILD_SUCCESS=1
PRODUCTION_SIGNING_VERIFIED=0
V060_VERSION_METADATA_READY=0
V060_UPDATER_MIGRATION_READY=0
PREPAID_ACCOUNTING_CORRECTNESS=0
PHYSICAL_HARDWARE_ACCEPTANCE=0
PRODUCTION_RELEASE_PUBLISHED=0
SUCCESS_REPORT=0
```

## Verified exact-source GitHub evidence

- Repo: `BlazingSystems/BlazingSystems-Experiments`; draft PR #30, branch `blazepwifi-v0.6.0-audit-foundation`; inspected implementation SHA `21670d3cf1fe9af8910c712a8b257f5f1061d63f`.
- Full build [run #37815563919](https://github.com/BlazingSystems/BlazingSystems-Experiments/actions/runs/37815563919): **completed SUCCESS**, HEAD `21670d3cf1fe9af8910c712a8b257f5f1061d63f`, including `validate`, firmware/simulations, Android/ESP, and `v04_candidate_gate`. Production signing and publication jobs were SKIPPED.
- Windows SoftTimer [run #37815571724](https://github.com/BlazingSystems/BlazingSystems-Experiments/actions/runs/37815571724): **completed SUCCESS**, same HEAD; `handover` and `build-windows` passed. Windows artifact is labeled v0.4.0; do not relabel it v0.6.0.
- Separate Full run #37815571766 was still in progress at the point checked, but #37815563919 provides an independent completed success on the exact SHA.
- GitHub release lookup `v0.6.0` returned 404 at inspection; do not invent download links.

## Why CI success cannot be promoted to release success

1. Source `VERSION` still says `0.5.3`; Android `build.gradle` still declares `versionCode 50300`, `versionName "0.5.3"`. Tagging these binaries `0.6.0` would be misleading.
2. The `tests/v060_migration_guard.sh` deliberately verifies that existing update.sh rejects `0.6` and `0.6.x` before any paid data mutation. A v0.6 bundle is therefore **not installable via the supported update route**.
3. Real `member.sh` event history replays old coin events after eviction (expected RED). `bp_member_balance_change` may report success if event receipt fails (expected RED). Real `rental.sh` lease credit and event receipt likewise diverge on failed append (expected RED). P0 issues [#31](https://github.com/BlazingSystems/BlazingSystems-Experiments/issues/31) and [#32](https://github.com/BlazingSystems/BlazingSystems-Experiments/issues/32) remain release blockers.
4. The isolated `tools/v060_journal_fixture.sh` and SQLite reference model PASS synthetic tests, but are **not integrated into runtime**. Their unkeyed SHA-256 and Linux `sync` do not prove authenticated, crash-durable account/rental receipts on target flash; no validated owner-approved v1-to-v2 migration.
5. Production Lineage-2 Android current/rescue pairing was not signed and verified for v0.6.0, and device-owner enrollment, installer rollback and real hardware power-cut/coin acceptance have no current verified signoff.

## Required path to SUCCESS_REPORT=1

- Implement a single server-authoritative, authenticated journal for member, rental and ordinary coin credits; preserve durable idempotency floors/receipts across retention and crash.
- Convert all three current *expected RED* runtime tests into required GREEN tests, with storage-full, lost ACK, concurrent and corruption negative tests.
- Execute quiesced, encrypted, owner-verifiable migration and rollback of real v0.5.x persistent state, plus per-target fsync/parent directory behavior; do not ship `update.sh` 0.6 bypass merely to make installation green.
- Complete real hardware tests (Ruijie R281/EW1200G Pro, x86 BIOS/UEFI, supported Orange Pi models and 30-device settlement/power-cut soak), preserve network connectivity/credential identity.
- Set versionCode/versionName and OpenWrt release manifest to 0.6.0, permanently sign current+rescue APKs under verified Lineage-2 identity, verify SHA-256/provenance, require exact-head Full+Windows+hardware gate success, then publish matching installable release assets without changing any old tag.

**No public installation, production tag or permission to risk customer time is granted by the two green development CI workflows.**

Audit continuation: `@GitHub Resume PR #30 P0 #31/#32. Read PROJECT_HANDOVER.md top, CURRENT_STATE.md, CHANGE_LEDGER.md, HANDOVER_POLICY.md, LEDGER_TRANSACTION_V060.md and this release decision. Exact previous Full CI #37815563919 + Windows #37815571724 passed at 21670d3cf1fe9af8910c712a8b257f5f1061d63f but production SUCCESS_REPORT=0. Fix runtime financial journal and physical/signing/migration acceptance; do not tag until ALL release invariants are verified.`
