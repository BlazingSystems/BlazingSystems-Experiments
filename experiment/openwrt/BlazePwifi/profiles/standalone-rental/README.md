# BlazePwifi Standalone Rental Server v0.5.2-rental.1

**Stable hotfix**

Default fresh-install credentials remain:

```text
Username: admin
Password: admin
```

## CSRF / QR hotfix

This release fixes R281/uHTTPd admin mutations that could return:

```text
csrf validation failed
```

The Rental UI now sends CSRF in both the custom header and the form body. If the token becomes stale after login/reset/reinstall, the UI refreshes the authenticated session and retries the mutation once automatically.

QR enrollment creation uses that corrected path. QR rendering errors are now shown visibly while preserving the generated server URL and one-time token.

## Windows tools

The Windows OneClick package includes:

- `Install-BlazePwifi-Rental.bat`
- `Reset-BlazePwifi-Admin-Password.bat`

The password reset works with Standalone Rental and full BlazePwifi and restores only `admin / admin`.

All v0.5.2 R281 BusyBox and network-preservation fixes remain included.
