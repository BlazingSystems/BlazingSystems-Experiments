# BlazePwifi Project Handover

**Last updated:** 2026-10-05  
**Repository:** BlazingSystems/BlazingSystems-Experiments  
**Development state:** Specification/design clarification in progress. Do not resume implementation until the owner explicitly says to continue development.

## Current target

BlazePwifi is being developed as a complete PisoWiFi + Android rental-device platform with a full management console, customizable captive portal system, coin/Vendo controllers, vouchers, sales, networking/WAN/LAN/VLAN management, backups, and BlazeRental Launcher3 integration.

## Current BlazeRental direction

Approved redesign direction:

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

## Last validated application candidate

Application candidate: `d2ee5e0c0493500ce6a0578b9cad5da0775be65e`

Build run: `37287301792` — PASS  
Model gate: `37287301976` — PASS

The corrected candidate is uploaded to GitHub Release `v0.4.0` as:

- `BlazeRental-v0.4.0-d2ee-TEST.apk`
- `BlazeRental-v0.4.0-d2ee-TEST.apk.sha256`

Do not replace the production `BlazeRental.apk` with a differently signed APK. The production v0.4 certificate is locked and must be preserved.

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
