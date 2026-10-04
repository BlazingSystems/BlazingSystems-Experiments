# BlazePwifi production-readiness audit

Release candidate: 0.2.0-rc.1

## Audit scope

The audit covers the OpenWrt runtime, captive portal/API, nftables enforcement, persistent accounting, Vendo protocol, ESP8266 firmware, installer/upgrade path, first-boot provisioning, ImageBuilder pipeline, and CI tests.

## Findings fixed in v0.2

| Finding | Risk | Resolution |
|---|---|---|
| MAC-only account identity | Private/random MAC could lose purchased time | Persistent 128-bit browser device token; MAC is now a replaceable network binding |
| Coin ACK loss | Retry could double-credit | Stable ESP event nonce plus server idempotency marker |
| Coin event reusable for another customer | Credit theft/replay | Signature includes active coin-window target nonce |
| Voucher marker shared bounded coin history | Old voucher could eventually become reusable | Voucher markers are retained; only coin markers are bounded |
| Vendo heartbeat persisted every poll | Excessive flash writes | Online Vendo state moved to /tmp |
| Coin target persisted unnecessarily | Flash wear / stale transient state | Active coin target stays in /tmp |
| Blaze gate ran before normal firewall4 forwarding | Policy ordering ambiguity | Blaze forward hook moved to priority 10, after firewall4 |
| No payment walled garden | E-payment portals unusable without session | Dynamic IPv4/IPv6 walled garden added |
| Admin token on HTTP | Local token disclosure risk | HTTPS-only admin listener on LAN address |
| ESP setup AP was open | Nearby reconfiguration risk | Per-device WPA2 password plus AP auto-shutdown |
| v0.1 MAC state had no migration path | Upgrade could orphan balances | One-time MAC-to-device-token claim migration |
| Firmware artifacts lacked local checksum file | Deployment integrity gap | Per-target SHA256SUMS generated |

## Automated gates

1. Static shell/hardening validation.
2. Accounting integration test.
3. Persistence/replay/migration stress test.
4. ESP8266 NodeMCU compilation.
5. OpenWrt 25.12.5 Ruijie RG-EW1200G Pro v1.1 ImageBuilder.
6. OpenWrt 25.12.5 x86_64 ImageBuilder.
7. Release bundle and SHA-256 artifacts.

## Remaining physical validation before calling a specific appliance field-proven

- Flash and recover an actual RG-EW1200G Pro v1.1.
- Measure actual coin-acceptor pulse polarity, width and debounce requirements.
- Verify relay/LED GPIO electrical levels with the chosen ESP8266 board.
- Brownout during coin acknowledgement and during account-file replacement.
- Sustained multi-client traffic and portal load.
- Real captive-portal behavior on Android, iOS, Windows and ChromeOS.
- Real e-payment provider flows for any configured walled-garden domain list.
- WAN/LAN/VLAN topology used by the intended installation.

The codebase is treated as a release candidate until those hardware/site tests are complete.
