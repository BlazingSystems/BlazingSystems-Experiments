# BlazePwifi 0.6.0 — state migration and rollback safety contract

**Status: DRAFT / RELEASE BLOCKER** — 2026-10-08. This document is a safety specification, not proof of a deployed migration. Source branch: `blazepwifi-v0.6.0-audit-foundation`, draft PR #30. Review `docs/handover/CURRENT_STATE.md` and `docs/handover/HANDOVER_POLICY.md` before acting.

## Verified source facts and mismatch

- The repository `VERSION` declares `0.5.3`, while `openwrt/rootfs/usr/share/blazepwifi/VERSION` is **still 0.5.2**. The Android `android/BlazeRentalLauncher/build.gradle` specifies `versionName "0.5.3"`, `versionCode 50300`. Neither is ready to be labeled a signed 0.6.0 release.
- `tools/build-update-bundle.sh` includes files from `openwrt/rootfs`, excluding `/etc/config/blazepwifi` and `/etc/blazepwifi/*`. It does not embed a complete customer state snapshot.
- `openwrt/rootfs/usr/lib/blazepwifi/update.sh` snapshots files enumerated in an update manifest, replaces the program payload, runs `update-migrate.sh` and previously ignored any nonzero migration exit. That old rollback snapshot cannot guarantee reversal of money, credentials, rental identities or configuration changes performed by a migration.
- `update-migrate.sh` currently adds v0.5.1 UCI update defaults, commits configuration and enables `blazepwifi-update-guard`. Any new migration must have an explicit state ownership and recovery contract, not rely on existing manifest-only rollback.
- **Immediate guard:** `bp_update_preflight_release` rejects `0.6`, `0.6.x` and `0.6-*` before creating stable/pending state, snapshots or swapping program files. This guard is intentionally not bypassable with an environment variable. The corresponding test is `tests/v060_migration_guard.sh`. This makes *installing 0.6 with the current updater unsupported until the new transaction is proven*.

## Sensitive persistence inventory to preserve

| Source / path family | Business meaning | Required invariant |
|---|---|---|
| `/etc/config/blazepwifi` and Blaze-owned UCI network/firewall/remote sections | Rates, network routing, management, payment policies | Preserve operator values and administrative connectivity; no new WAN exposure |
| `/etc/blazepwifi/state/accounts.tsv`, `vouchers.tsv`, `targets/*` | Paid accounts, vouchers, active coin-window targets and consumption | No missing/duplicate credits, invalid timer conversions or cross-device transfers |
| `/etc/blazepwifi/state/credits.tsv`, `sessions.tsv` when present | Legacy paid credit/session records | No double conversion or silent dropping of legacy balances |
| `/etc/blazepwifi/state/members.tsv`, `member-events.tsv`, `member-revision` | Centralized SoftTimer member authority and event ledger | Preserve banked seconds, audit trail, replay identity and revision monotonicity |
| `/etc/blazepwifi/state/rental-devices.tsv`, `rental-enroll.tsv`, `rental-policy*.tsv`, `rental-inventory.tsv`, `rental-events.tsv` | Phone enrollments, per-device shared secrets, paid leases, policy and device inventory | Preserve authentication identity, purchased lease expiry and policy revision |
| `/etc/blazepwifi/state/admin-users.tsv`, `audit.tsv` | Privileged credentials and audit records | Never reset administrator credentials or expose stored verifiers in logs |
| `/etc/blazepwifi/update/*` and configuration/keys under `/etc/blazepwifi` | Update history, rollback, TLS/remote management/controller secrets | Preserve recovery chain, file permissions, encrypted keys and VPN settings |
| `/tmp/blazepwifi/*` | Ephemeral admin sessions and controller runtime | Do not treat volatile state as a durable migration input; force reauthentication where appropriate |

This inventory is not a substitute for a **read-only actual-device file listing** and per-version schema hashes. Before release, inspect all files discovered through source variables and deployed configurations, including devices upgraded from older releases. Never upload user data, keys or raw business TSV content to public GitHub artifacts.

## Non-negotiable migration transaction

1. **Preflight without writes:** verify current real runtime VERSION, expected release transition and schema revision, free flash/overlay margin, device architecture, operator-approved maintenance window, signed bundle/checksum, power/recovery readiness, and exact supported source versions. If unknown, fail closed.
2. **Quiesce paid mutation:** disable new coin windows, mark sessions safe, drain/ack pending Vendo and Windows events, close rental payment operations, record an immutable event cursor and protect the previous state. Reject rather than queue ambiguous requests. Keep enough read-only network/admin access for recovery.
3. **Durable encrypted private backup:** snapshot configuration + all persistent state + revision/event cursors + deployment software version, with file mode/ownership metadata and verified SHA-256. Store outside a location overwritten during install. Do **not** publish raw backup to Actions artifacts, Git or support logs.
4. **Migration with journal:** maintain explicit `PREPARED`, `BACKED_UP`, `MIGRATING`, `VERIFIED`, `COMMITTED`, `RECOVERED` outcomes in a fsync-backed recovery record; use temporary files plus atomic rename and idempotent retry after unexpected power loss.
5. **Verify invariants before reopening:** count records, verify unique event IDs and voucher use status, reconcile every paid balance/lease and member revision, preserve owner/control credentials and network access, confirm that all read/write APIs agree on the new schema.
6. **Rollback BEFORE new transactions:** restore the exact preceding program/config/state together, then validate and release the freeze. Never restore an older money snapshot after **new** paid transactions were accepted; this would erase legitimate customer credits. If a migration is committed and sales resume, use **forward-compatible schema replay**, append-only ledger conversion or an explicit operator-reviewed reconciliation — not a blind snapshot overwrite.
7. **Recovery test matrix:** power-off at each journal state, disk-full during backup/write, repeated recovery, unsynchronized system clock, interrupted service restart, partial network upgrade, duplicate/out-of-order controller ACKs, stale member tokens, old Android APK binding, safe mode and management loss.

## Version identity and Android signing

- Only after schema and real-device rollback pass may `VERSION`, embedded `/usr/share/blazepwifi/VERSION`, installer/release metadata and APK `versionName` be changed **together** to 0.6.0 in a reviewed candidate.
- Android `versionCode` must monotonically exceed 50300 and preserved rollback/rescue 50301. Maintain package `com.blazesystems.blazerental` and permanent Lineage-2 signing certificate. Verify a real update from signed 0.5.2 and a separate rescue before generating production Device Owner provisioning QR. Never silently substitute a new signer.
- Ordinary binding QR is separate and lower security; preserve independent 0.5.x client compatibility and authorization.
- Publish only from an exact green 0.6.0 workflow with SHA/manifest checks, signed assets, per-hardware firmware/image/EXE installers and operator-performed acceptance. Do not modify frozen v0.5.2 Full, Standalone Rental RC9 or SoftTimer v0.4.0 assets.

## Release acceptance and exit criteria

A reviewer must attach (without customer secrets) the exact commit SHA, target/version mapping, state-schema compatibility matrix, reproducible migration/rollback tests, 30-client concurrent payment soak, 24-hour coin replay/power-cycle results, real 60-minute Windows COM test, VLAN13 bridge/routed network survival, factory-reset Android Device Owner provisioning, admin recovery path, and signed APK/firmware checksums. Any incomplete P0 criterion blocks `v0.6.0` production publication.

**NEXT:** implement transactional state snapshot/quiescence/journal and recovery tests on isolated fake ledgers. Only after a green migration matrix should the explicit 0.6.0 update preflight block be replaced with a signed, verified release pathway. Keep all work continuously reflected in `PROJECT_HANDOVER.md`, `docs/handover/CURRENT_STATE.md` and `docs/handover/CHANGE_LEDGER.md`.
