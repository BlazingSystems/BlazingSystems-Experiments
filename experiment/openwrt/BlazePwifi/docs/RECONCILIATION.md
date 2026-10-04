# WiFi5/public-resource reconciliation

## Sources reviewed

- https://files.wifi5-soft.com/ — the public landing page is reachable, but its directory listing is JavaScript-driven and was not exposed by the available static crawler. No claim is made that hidden/private file listings were extracted.
- WiFi5 public references indexed on the web.
- darkhoundz/KLCiS-WiFi5-Soft — public MIT-licensed example integrating e-payment/vouchers with WiFi5.
- OpenWrt 25.12 uHTTPd and package documentation.

## Behavior reconciled into BlazePwifi

### Random/private MAC handling

Public WiFi5 material highlights random-MAC handling as a major feature. BlazePwifi v0.2 no longer treats the MAC as the account identity. The portal creates a random persistent browser token; the current MAC is only the active network binding.

### Pause/resume

The account record stores either an absolute active expiry or a frozen remaining duration. Pausing removes the current MAC from the authorization set; resuming creates a new expiry and re-authorizes the current binding.

### Multi-Vendo behavior

Vendos publish in-RAM heartbeats. The portal discovers currently online units. A single online Vendo is selected naturally; multiple online Vendos are shown to the user so coin credit cannot be assigned to an ambiguous physical machine.

### Walled garden / e-payment

The KLCiS WiFi5 integration demonstrates the practical requirement for payment-provider hosts to remain reachable before the user buys time. BlazePwifi implements provider-neutral UCI walled_domain and walled_ip lists. Provider domain lists should come from the provider's current documentation and be reviewed periodically instead of embedding a stale third-party list into firmware.

### Traffic control

Public PisoWiFi/WiFi5 material commonly describes anti-lag/bandwidth shaping. BlazePwifi v0.2 deliberately does not force a heavy SQM/CAKE package set into the 16 MB Ruijie image. Traffic shaping remains an optional OpenWrt layer so the base firmware stays small and predictable. It can be added on larger targets without changing Blaze accounting.

### VLAN / WAN transfer workflows

Those are treated as OpenWrt network topology concerns rather than coupling them to the money/session engine. This keeps BlazePwifi compatible with VLAN/repeater/router layouts while preserving firewall4 as the policy authority.

## What was not copied

No closed WiFi5 server executable, license system, certificate, portal artwork, database, JavaScript bundle, firmware image, or proprietary ESP firmware is included.
