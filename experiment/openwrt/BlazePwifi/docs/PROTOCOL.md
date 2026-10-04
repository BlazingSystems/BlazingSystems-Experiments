# Blaze Vendo protocol v2

Transport: HTTP POST, application/x-www-form-urlencoded, default LAN TCP port 4455.

Endpoint: /cgi-bin/vendo

## Fields

- action: register, ping, poll, or coin
- id: configured Vendo identifier
- nonce: 8–32 hexadecimal request/event identifier
- pulses: decimal pulse count; 0 for non-coin requests
- target: active coin-window target nonce for coin events; blank for register/ping/poll
- sig: keyed SHA-256 digest

## Signature input

    VENDO_KEY|action|id|nonce|pulses|target|VENDO_KEY

The shared Vendo key is never placed in the request body.

This is a compact keyed-digest construction for the isolated Vendo LAN. It is not a replacement for TLS on an untrusted network.

## Poll

A selected Vendo receives a response containing:

    {"ok":true,"insert":1,"target_nonce":"...","expires":1234567890}

The ESP remembers target_nonce before accepting pulses.

## Coin event

After a pulse burst, the ESP creates one event nonce and sends it with the target nonce. If the response is lost, the ESP retries the same event nonce, target and pulse count.

The server persists an event marker in the same atomic account update as the credit. A retry returns ok with duplicate=true and credited_cents=0 rather than adding money again.

The target nonce also prevents a delayed/replayed event from being attached to a different customer's later coin window.

## Provisioning and upgrade

The ESP starts a WPA2 setup AP named BlazePwifi-Vendo-<chipid>. A generated per-device setup password is printed on serial during provisioning. Once the Vendo has joined the configured Wi-Fi, its setup AP shuts down automatically after ten minutes.

Firmware v0.2 migrates the prior v0.1 stored SSID, password, server, Vendo key, ID and GPIO mapping instead of resetting them.

## Network security

Keep Vendos on a trusted LAN or dedicated management/VLAN segment. Port 4455 is authenticated but intentionally remains HTTP to keep the ESP8266 client small; it must not be published to WAN.
