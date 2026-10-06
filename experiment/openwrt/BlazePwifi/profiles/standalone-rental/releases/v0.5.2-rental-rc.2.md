# BlazePwifi Standalone Rental Server v0.5.2-rental-rc.2

This RC fixes the Rental administrator login/bootstrap behavior found during physical R281 testing.

## Default fresh-install credentials

```text
Username: admin
Password: admin
```

Existing admin accounts are preserved on upgrade. Only a fresh Standalone Rental install with no existing admin user creates the default account.

The normal password-change action still requires a stronger password.

## Missing credentials fix

uHTTPd POST bodies are now read using the CGI `CONTENT_LENGTH` value rather than relying on a single shell `read`. This makes form-urlencoded login reliable on the R281 BusyBox/uHTTPd environment and prevents valid form submissions from appearing empty.

## Retained fixes

- R281 detection and dedicated EasyMode installer path.
- BusyBox-safe archive extraction.
- first-time SSH host-key GUI confirmation.
- no Standalone writes to network/wireless/firewall UCI configuration.


## BusyBox flock compatibility

Physical R281 testing also exposed that BusyBox `flock` on this image supports `-n` but not util-linux `-w`.

rc.2 therefore replaces timed `flock -w` calls with a portable non-blocking retry helper. Authentication, accounting, and software-update locks now work on the R281 BusyBox implementation while retaining bounded wait behavior.
