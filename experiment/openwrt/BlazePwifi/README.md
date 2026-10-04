# BlazePwifi

BlazePwifi is an open-source prepaid Wi-Fi/captive-portal platform built around OpenWrt, ESP controllers, Linux SBCs and x86 systems.

Target base: OpenWrt 25.12.x  
Current development release: 0.3.0-rc.1  
Primary OpenWrt build target: 25.12.5

## Capability tiers

BlazePwifi does not force heavy services onto small hardware.

- **Lite** — constrained OpenWrt routers. Hardened accounting, sessions, vouchers, compact admin, compact portal editor, VLAN/network configuration and ESP controller support.
- **Standard** — Orange Pi and similar Linux/OpenWrt SBCs. Adds richer preview, Linux GPIO agent, rental-device service and fuller auditing.
- **Full** — x86_64 PCs/thin clients/VMs. Adds the full admin/portal experience, longer local history, larger asset storage and fleet-oriented rental management.

Auto detection is conservative and can be overridden explicitly in configuration.

## Hardware goals

- OpenWrt routers including Ruijie RG-EW1200G Pro v1.1.
- x86_64 legacy BIOS and UEFI systems.
- Orange Pi family, prioritizing Zero 3, One and PC, with additional upstream-supported boards added only when their exact image builds succeed.
- ESP8266 and ESP32 external coin/Vendo controllers.
- Android rental devices using BlazeRental, with managed QR provisioning and a lower-security normal APK mode.

## v0.3 direction

- Preserve v0.2 durable accounting, private-MAC rebinding, pause/resume, vouchers and idempotent coin handling.
- Add capability-aware packaging so constrained hardware remains stable.
- Replace single admin-key access with authenticated admin sessions, lockouts, CSRF protection and role-aware operations.
- Add a configurable portal renderer, compact Lite editor and richer Standard/Full builder.
- Add previewable portal/admin/controller/rental templates under `portal-templates/`.
- Add ESP32 and Linux GPIO controller implementations.
- Add Orange Pi and expanded x86 image targets.
- Add BlazeRental Android managed-device provisioning.
- Publish only successful build outputs and checksums as versioned GitHub Release assets.

## Current v0.2 runtime behavior retained during development

- Browser-backed device identity that survives normal Android/iOS private-MAC rotation.
- Persistent credit and timed sessions.
- Pause/resume.
- One-time vouchers.
- Multiple Vendo discovery.
- Target-bound signed coin events with retry/idempotency protection.
- ESP8266 pending-event journaling.
- Dynamic walled garden.
- firewall4/nftables enforcement.
- HTTPS-only local administration.
- Crash-safe persistent accounting and migration tests.

## Quick install

For the current OpenWrt runtime, copy the project to an OpenWrt 25.12.x system and run:

`installer/install.sh`

The v0.3 installer work will keep first-run secrets generated/provisioned locally; no universal production password is stored in the repository.

Typical local endpoints follow the configured LAN/management address:

- Portal: `http://LAN_IP:8080/`
- Admin: `https://LAN_IP:8443/admin.html`
- Controller API: `http://LAN_IP:4455/cgi-bin/vendo`

## Build images

Use `build/build-openwrt-image.sh` for currently supported targets. v0.3 expands this build matrix while retaining the rule that a target is only published when its build and checksum gate succeeds.

Generated development artifacts are temporary CI artifacts. Versioned successful deliverables are indexed under `releases/<version>/` and attached to the matching GitHub Release.

## Validation boundary

Automated build success is not the same as field validation. Each exact router/SBC/device revision still needs physical boot, recovery, GPIO/electrical, brownout and real-client testing before it is described as hardware validated.

## Repository map

- `openwrt/rootfs/` — runtime overlay
- `installer/` — install/uninstall
- `esp8266/` — ESP8266 Vendo firmware
- `esp32/` — ESP32 Vendo firmware (v0.3)
- `linux-agent/` — SBC GPIO controller agent (v0.3)
- `android/` — BlazeRental managed-device client (v0.3)
- `portal-templates/` — static previews and template definitions (v0.3)
- `build/` — image/build automation
- `tests/` — regression, security and persistence tests
- `docs/ARCHITECTURE.md` — system design
- `docs/PROTOCOL.md` — controller protocol
- `docs/SECURITY.md` — deployment/security model
- `docs/REFERENCE_NOTES.md` — neutral public-reference notes
- `AUDIT.md` — readiness audit

## Clean-room notice

BlazePwifi contains original project code and public/open-source integration patterns only. It does not redistribute closed commercial binaries, licensing mechanisms, private keys, databases, branding, proprietary portal assets or private firmware.
