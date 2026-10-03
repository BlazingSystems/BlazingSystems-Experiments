# Security and deployment notes

- BlazePwifi generates separate random admin and Vendo secrets at install time. Do not commit deployed secrets to Git.
- The Vendo secret is used to sign requests and is not transmitted in the request body.
- Put ESP8266 Vendos on a trusted LAN or management VLAN. Protocol v1 authenticates but does not encrypt.
- Keep the OpenWrt root password strong and disable WAN-side administration.
- Do not expose ports 8080 or 4455 to WAN.
- Use client isolation on the guest SSID where practical.
- Back up `/etc/config/blazepwifi` and `/etc/blazepwifi/state` before upgrades.
- Coin accounting is security-sensitive: validate pulse width/debounce with the actual acceptor before accepting money commercially.
- The first alpha is not represented as PCI/payment-card software and must not be adapted to process card credentials directly.
