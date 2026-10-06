# Standalone Rental Releases

## Latest

### v0.5.2-rental-rc.2

Login/bootstrap correction over rc.1:

- fresh OpenWrt installs use `admin / admin`;
- password can be changed later;
- robust uHTTPd POST-body parsing using `CONTENT_LENGTH`;
- BusyBox-compatible `flock -n` retry locking for R281;
- R281 BusyBox-specific deployment from rc.1 retained;
- first-SSH GUI host-key handling retained.

## Older

- v0.5.2-rental-rc.1 — R281 BusyBox installer fix.
- v0.5.0-rental-rc.3 — first-SSH host-key fix.
- v0.5.0-rental-rc.2 — superseded.
- v0.5.0-rental-rc.1 — superseded.
