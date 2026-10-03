# Blaze Vendo protocol v1

Transport: HTTP POST, `application/x-www-form-urlencoded`, default TCP port 4455.

Endpoint: `/cgi-bin/vendo`

Required fields:
- `action`: `register`, `ping`, `poll`, or `coin`
- `id`: configured Vendo identifier
- `nonce`: 8–32 hex characters, freshly generated per request
- `pulses`: decimal pulse count; `0` for non-coin requests
- `sig`: SHA-256 signature

Signature input:

```text
VENDO_KEY|action|id|nonce|pulses|VENDO_KEY
```

The key itself is never sent over the network. For `coin`, the server records the last accepted nonce for that Vendo and rejects a replay using the same nonce. The signature also prevents changing the pulse count without knowing the secret.

`poll` response contains:

```json
{"ok":true,"insert":1,"target_nonce":"...","expires":1234567890}
```

`coin` response contains credited centavos and the resulting customer credit.

## Provisioning

The ESP firmware starts an AP named `BlazePwifi-Vendo-<chipid>`. Open its setup page and configure Wi-Fi SSID/password, BlazePwifi server IP, Vendo key, Vendo ID and GPIO mapping.

## Security note

Protocol v1 authenticates requests but does not encrypt payloads. Deploy the Vendo on the same trusted/isolated LAN or management VLAN. A future protocol revision may add TLS without changing the accounting model.
