# BlazePwifi architecture

## Base system

BlazePwifi's production images use **ImmortalWrt 25.12.2**. The application layer is intentionally portable to OpenWrt 25.12.x.

The change from the original alpha's OpenWrt base is evidence-driven: the supplied WiFi5 Ruijie firmware reports revision `r37854-4b24da3b4c5c`, which is ImmortalWrt 25.12.0, and the supplied x86 build contains ImmortalWrt build paths and package feeds. The current stable ImmortalWrt 25.12.2 therefore provides the closest maintained base.

## Components

1. **ImmortalWrt/OpenWrt** — Ethernet/Wi-Fi, DHCP/DNS, NAT and firewall4.
2. **BlazePwifi core** — procd service owning an independent `inet blazepwifi` nftables table.
3. **Portal listener :8080** — client portal, accounting API and admin UI.
4. **Vendo listener :4455** — isolated CGI root exposing only the ESP/Vendo endpoint.
6. **Persistent state** — credits, sessions and vouchers under `/etc/blazepwifi/state`.
7. **Runtime state** — coin target, locks and Vendo heartbeats under `/tmp/blazepwifi`; high-frequency polling never writes flash.
8. **ESP8266** — interrupt-driven pulse counter and GPIO controller; routing/accounting remain server-side.

## Traffic path

```text
Internet -> WAN -> firewall4 -> BlazePwifi nftables gate -> LAN/Wi-Fi
                                                | paid MAC: forward
                                                | unpaid MAC: drop
                                                ` unpaid HTTP: redirect :8080
```

Custom images default to an IPv4-only hotspot. This matches the reference system and removes an entire class of unpaid IPv6 bypass and captive-detection inconsistencies.

## Accounting path

```text
client -> coin_start -> locked target {MAC, target_nonce, expiry, vendo, seq=0}
ESP -> poll -> receives target_nonce
coin acceptor -> pulse batch
ESP -> signed coin(target_nonce, seq, pulses)
server -> atomic replay check + credit write + seq advance
client -> purchases rate
server -> persistent session expiry + nft authorized MAC
core -> removes authorization after expiry
```

The periodic session watcher never rewrites persistent session files; it only synchronizes the in-kernel nftables set.

## Reference-aligned custom image defaults

- LAN: `10.0.0.1/19`
- DHCP start: 2
- DHCP limit: 8190
- lease: 72 hours
- DHCPv6/RA/NDP: disabled
- router Wi-Fi interfaces: enabled, open hotspot, client isolation enabled
- x86: creates DHCP WAN on `eth1` when a second NIC exists and no WAN is configured
\n## Web-surface isolation\n\nCustom images bind portal, admin and Vendo services to the LAN address only. Their document roots live under `/srv`, not under the default `/www` tree, so the router's normal web server cannot accidentally expose admin/Vendo files. Admin is HTTPS-only on port 8443.\n