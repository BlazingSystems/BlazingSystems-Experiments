# BlazePwifi Standalone Rental Server v0.5.2-rental

This is the finalized Standalone Rental release following the BlazePwifi 0.5.2 implementation line.

## Default credentials

Fresh Standalone Rental installation:

```text
Username: admin
Password: admin
```

The administrator can change the password later in the Rental console.

## One-click password reset

The Windows release includes:

```text
Reset-BlazePwifi-Admin-Password.bat
```

It works with both Standalone Rental and full BlazePwifi. It requires only router SSH access and does not require manually uploading a script to OpenWrt.

The reset operation always restores:

```text
Username: admin
Password: admin
```

The reset tool preserves other administrator records, clears stale sessions/lockouts, writes a portable `sha256i` record, and self-verifies it before reporting success.

## R281

Physical R281 testing drove the final compatibility fixes:

- dedicated `notion,r281` installer;
- BusyBox-safe tar extraction;
- BusyBox-safe flock handling;
- robust uHTTPd CGI POST parsing;
- portable verified admin hashing;
- Windows first-SSH host-key handling.

## Standalone boundary

Rental Standalone keeps the full BlazePwifi software payload installed but dormant. It does not intentionally modify OpenWrt network, wireless, or firewall configuration until explicit conversion to full BlazePwifi.
