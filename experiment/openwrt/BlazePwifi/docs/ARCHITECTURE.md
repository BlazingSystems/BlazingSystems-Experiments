# BlazePwifi architecture

## Components

1. **OpenWrt 25.12.x** — WAN/LAN, Wi-Fi, DHCP/DNS, NAT and base firewall.
2. **BlazePwifi core** — lightweight procd service that owns the paid-client nftables table and expires sessions.
3. **uhttpd portal** — client UI on port 8080 and vendo API on port 4455.
4. **Persistent state** — TSV files under `/etc/blazepwifi/state`; runtime locks/coin target stay under `/tmp/blazepwifi`.
5. **ESP8266 Vendo** — counts coin pulses, controls insert LED/relay, and reports signed coin events.

## Traffic path

```text
Internet
   |
  WAN
   |
OpenWrt routing/firewall4
   |
BlazePwifi nft table
   |---- paid MAC -> forward
   |---- unpaid MAC -> local/walled traffic only
   `---- unpaid HTTP -> redirect :8080
   |
LAN / Wi-Fi clients
```

BlazePwifi does not replace firewall4. It creates a separate `inet blazepwifi` table with an authorization set so uninstalling or stopping the service is deterministic.

## Accounting path

```text
Client -> Start coin insert -> temporary target (MAC + nonce + expiry)
ESP -> poll -> insert command
Coin acceptor -> ESP pulse(s)
ESP -> signed coin event -> credit balance
Client -> buy configured rate -> session expiry
Core -> adds MAC to nft set
Expiry -> core removes MAC from nft set
```

## Why OpenWrt rather than ImmortalWrt

The primary target, Ruijie RG-EW1200G Pro v1.1, is directly supported by upstream OpenWrt. Using upstream 25.12.x reduces fork-specific assumptions and gives BlazePwifi a larger compatibility surface. ImmortalWrt remains a possible secondary target later if a device or package specifically benefits from its patches.

## Small-router constraints

The RG-EW1200G Pro v1.1 has 16 MB flash and 128 MB RAM. Therefore the router runtime uses BusyBox shell, UCI, uhttpd and nftables instead of Node.js/Python/databases. x86 installations can later add an optional richer management layer without changing the ESP protocol.
