# BlazePwifi Standalone Rental Server v0.5.2-rental

**Final release**

Default fresh-install Rental credentials:

```text
Username: admin
Password: admin
```

The default password can be changed later from the Rental admin console.

## Windows OneClick

For an existing OpenWrt router, extract the Windows package and double-click:

```text
Install-BlazePwifi-Rental.bat
```

The package also includes:

```text
Reset-BlazePwifi-Admin-Password.bat
```

The reset BAT works with **Standalone Rental and full BlazePwifi**. It connects over SSH and resets only to:

```text
Username: admin
Password: admin
```

No manual upload to the router is required.

## R281 compatibility

The final release keeps all fixes proven during physical R281 testing:

- dedicated `notion,r281` / EasyMode installer path;
- BusyBox-safe archive extraction;
- no GNU-only tar options;
- BusyBox-compatible `flock -n` retry locking;
- reliable CGI POST parsing through `CONTENT_LENGTH`;
- verified portable `sha256i` default administrator record;
- first-time SSH host-key confirmation in the Windows OneClick tools.

Standalone installation does not take ownership of OpenWrt `network`, `wireless`, or `firewall`.

## URLs

- Rental admin: `https://LocalIP/rental/`
- BlazeRental server: `http://LocalIP`
- Rental API: `http://LocalIP/cgi-bin/rental`
- Remote ESP coin API: `http://LocalIP:4455/cgi-bin/vendo`

## ESP modes

1. Rental Server
2. Rental Server + one Local Coin Slot
3. Remote Coin Slot Interface

Rental-server modes can bind additional remote ESP coin interfaces.
