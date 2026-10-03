# Security and operational notes

- Separate random admin and Vendo secrets are generated at install/first boot.
- Admin authentication is accepted only from the `X-Blaze-Admin` header; secrets are not accepted in query strings.
- The client API derives the device MAC from the kernel neighbor table or DHCP lease by source IP. A user-supplied `mac=` parameter cannot select another customer's account.
- Coin payments are bound to a fresh server target nonce and monotonic target sequence, and credit/sequence commits are atomic.
- Vendo heartbeat/poll state stays in `/tmp`; it does not generate continuous flash writes.
- Persistent session state is written only when a session changes, not every watcher cycle.
- Custom hotspot images disable IPv6 by default to prevent bypass and simplify captive behavior.
- Port 4455 uses a separate uhttpd document root exposing only the Vendo CGI endpoint.
- WAN-side input should remain rejected by firewall4. Never expose 8080 or 4455 to WAN.
- Use client isolation on hotspot SSIDs.
- Coin input is interrupt-driven so network requests cannot block pulse sampling. Validate the actual coin acceptor's voltage levels, pulse widths, denomination pulse mapping and opto-isolation before handling real money.
- Back up `/etc/config/blazepwifi` and `/etc/blazepwifi/state` before upgrades.
