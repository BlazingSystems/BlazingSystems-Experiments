# Standalone Rental Releases

## Latest stable

### v0.5.2-rental.1

Stable hotfix for Rental admin CSRF handling and QR enrollment creation.

- CSRF sent in header and POST body;
- session CSRF refresh + one automatic retry;
- explicit same-origin credentials and no-store requests;
- QR renderer failures are visible;
- default/reset credentials remain `admin / admin`.

## Previous

- v0.5.2-rental — initial stable release.
- v0.5.2-rental-rc.2 — R281 auth/login/BusyBox fixes.
- v0.5.2-rental-rc.1 — R281 BusyBox installer fix.
