# BlazePwifi Standalone Rental Server

Current release line: **v0.5.2-rental-rc.2**

This release fixes the Rental admin login path, R281 BusyBox locking, and makes fresh Standalone Rental installs use:

```text
Username: admin
Password: admin
```

The password can be changed later from Rental settings. Existing installations with an already-created admin account are preserved instead of being silently reset.

## Login fix

The CGI request parser now reads the exact `CONTENT_LENGTH` bytes from uHTTPd POST requests using BusyBox-compatible `dd`. This fixes cases where the login form reached `admin-login` but the request body was seen as empty and returned `missing credentials`.

## OpenWrt

- Rental console: `https://LocalIP/rental/`
- Android server: `http://LocalIP`
- Android API: `http://LocalIP/cgi-bin/rental`
- Remote coin API: `http://LocalIP:4455/cgi-bin/vendo`

R281 keeps its dedicated EasyMode/BusyBox install path. Standalone installation does not take ownership of `network`, `wireless`, or `firewall`.

## ESP modes

1. Rental Server
2. Rental Server + one Local Coin Slot
3. Remote Coin Slot Interface

Rental-server modes can also bind separate remote ESP coin interfaces.


## R281 BusyBox lock compatibility

The R281 BusyBox `flock` does not implement `-w`. rc.2 uses a portable `flock -n` retry helper for authentication, accounting, and update locks.
