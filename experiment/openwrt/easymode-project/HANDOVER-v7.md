# EasyMode 7.0 continuation log

## Checkpoint 1 — discovery (2026-10-10)
- Authoritative public repository: BlazingSystems/BlazingSystems-Experiments.
- Development branch: easymode-v7-production; base fd351ace52f465ce9689961734178af145cd3447.
- Workspace: C:/Users/Blaze/Documents/Codex/EasyMode-v7.
- Current working router application: releases/v4.2.6-r281-consolidated/root. Preserve it and its management functions. The 5.0.0-alpha.1 universal toolkit is incomplete scaffolding, not a replacement for that application.
- Six editions exist: generic, ap, router, cellular, switch, pc.
- No existing EasyMode CI image builder. Windows host has neither WSL nor Docker. GitHub connector provides Git object writes, but no release upload or workflow dispatch; local Git credentials are unavailable. Build/release workflow on a development branch is the intended Linux execution path, subject to actual permission verification.
- No physical flashing is authorized for this assignment. R281 is a community OpenWrt 24.10.8 build; marketing name alone does not establish compatibility with official ImageBuilder profiles. PC x86/64 is the initial official image target; virtual boot tests must precede publication.

## Architecture decisions
- One plain JavaScript dashboard, one ucode collector/accounting library and authenticated rpcd API; no React, Node or Python dependency on routers.
- WAN interface counters are deduplicated by L3 device. WiFi counters measure link activity separately. AP/switch editions cannot infer invisible upstream usage.
- Optional bounded nftables flow counters operate in an isolated observer table without changing verdicts, NAT or acceleration. Detailed accounting is unavailable when forwarding offload prevents measurement. Existing nlbwmon can provide a separate device-accounting adapter; never add its totals to WAN totals.
- DNS observations are disabled by default. Domain matches are observations, never proof of a visit; unique recent flow associations may be estimated, ambiguous/shared addresses remain unknown. No URLs, content or TLS interception.
- Private bounded RAM state, batched persistent checkpoints, explicit retention/deletion, no telemetry. Capability limitations are part of the API.

## Current status
Discovery complete. Implementation, executable tests, packages, firmware and release remain pending. No production readiness claim.

## Next exact action
Implement pure accounting and attribution tests, collector, supervised service and admin RPC; then build the shared dashboard and edition packages. Establish CI execution early. Record actual test and build results below.

## Checkpoint 2 — implementation and package construction
- Shared source is in traffic/root; no React/Node/Python runtime on the router. Root and all six edition manifests now identify v7.
- Implemented WAN/sysfs collection, wireless/client observation, sampled nft flow accounting, bounded private history, opt-in dnsmasq observation, local service inference, rpcd ACL API and eight-view dashboard. Existing installed management is preserved with one navigation link added only during installation.
- Built 13 IPK/archive artifacts locally in dist-v7. These are validation candidates, not production releases.
- Actual executed results are in traffic/TEST-REPORT.md. No v7 software was installed on the physical router; isolated tests only.
- Linux CI bootstrap passed. Next: push implementation, run full ImageBuilder/QEMU pipeline, resolve failures, then publish only after acceptance review.
