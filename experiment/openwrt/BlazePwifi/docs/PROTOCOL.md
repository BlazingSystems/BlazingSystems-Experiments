# Blaze Vendo protocol v2

Transport: HTTP POST, `application/x-www-form-urlencoded`, TCP port 4455 on the trusted hotspot/Vendo LAN.

Endpoint: `/cgi-bin/vendo`

Fields:
- `action`: `register`, `ping`, `poll`, `coin`
- `id`: Vendo identifier
- `nonce`: fresh random request nonce
- `pulses`: pulse count (`0` for non-coin requests)
- `target`: server-issued coin-window nonce; required for `coin`
- `seq`: monotonically increasing coin batch sequence within the current target
- `sig`: SHA-256 keyed request digest

Signature input:

```text
VENDO_KEY|action|id|nonce|pulses|target|seq|VENDO_KEY
```

The Vendo key is never transmitted. For each coin window, the server creates a fresh `target` and initializes sequence 0. The ESP resets its sequence when the target changes. A coin request is accepted only when its target matches the active window and `seq` is greater than the last committed sequence. Sequence validation, credit persistence and sequence advancement occur under the same server lock.

This prevents replay across old coin windows and prevents concurrent duplicates inside the same window.

## Poll response

```json
{"ok":true,"insert":1,"target_nonce":"0123abcd...","expires":1234567890}
```

## Provisioning

When unconfigured or unable to join Wi-Fi at boot, the ESP opens `BlazePwifi-Vendo-<chipid>` with a device-derived setup password. After a successful station connection the setup AP is automatically shut down after the initial recovery window.

Coin pulses are captured by an interrupt rather than by the network polling loop, so short pulses are not lost while an HTTP request is in progress.

## Transport security

v2 authenticates and replay-binds payment messages but does not encrypt HTTP. Keep Vendos on the trusted hotspot LAN or a dedicated management/Vendo VLAN. Do not expose TCP 4455 to WAN.
