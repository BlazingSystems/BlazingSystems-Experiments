# Security and deployment notes

## Secrets and administration

- The installer generates separate random admin and Vendo secrets and preserves existing keys during upgrades.
- The admin API accepts its token only on the configured HTTPS admin port.
- The admin listener is bound to the OpenWrt LAN address, not a WAN-facing wildcard.
- The locally generated certificate is self-signed; verify you are connecting to your own gateway before accepting the browser warning.
- Keep the OpenWrt root password strong and disable WAN administration.

## Client identity

The browser device token prevents normal private-MAC rotation from destroying an account, but the captive portal itself is HTTP because unpaid operating-system captive detection depends on HTTP redirection. Treat the hotspot LAN as untrusted:

- enable wireless client isolation;
- prefer WPA2/WPA3/OWE where the deployment model permits it;
- do not expose the portal or Vendo API on WAN;
- do not rely on the browser token as a high-value identity credential.

## Vendo

- The setup AP is WPA2-protected with a generated per-device password and shuts down after provisioning.
- Vendo messages are signed and coin events are target-bound and idempotent.
- Port 4455 is authenticated but not encrypted; isolate Vendos from ordinary clients when practical.
- Validate coin-acceptor voltage, pulse timing/debounce and GPIO electrical levels before connecting money hardware.

## Accounting durability

- Credits, session state, voucher markers and recent coin replay markers live under /etc/blazepwifi/state.
- Temporary coin windows and Vendo heartbeats live in /tmp to reduce flash wear.
- Account writes use a temporary file followed by rename.
- Voucher redemption markers are retained; only recent coin replay IDs are bounded.

Back up /etc/config/blazepwifi and /etc/blazepwifi/state before upgrades.

## Firewall and walled garden

BlazePwifi's forward hook runs after firewall4, so normal OpenWrt zone policy remains authoritative. Keep walled-garden domains minimal and review them when a payment provider changes infrastructure.

## Payment scope

BlazePwifi manages prepaid network credit/vouchers. It is not PCI/payment-card software and should not directly collect or store card credentials. External e-payment integrations should redirect to the payment provider and use documented, authenticated callbacks or voucher mechanisms.
