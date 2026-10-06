#!/bin/sh
set -eu
PURGE=0
[ "${1:-}" = "--purge" ] && PURGE=1
[ "$(id -u)" = 0 ] || { echo "ERROR: run as root" >&2; exit 1; }
for s in blazepwifi_rental_http blazepwifi_rental_admin blazepwifi_rental_vendo; do uci -q delete "uhttpd.$s" || true; done
uci commit uhttpd >/dev/null 2>&1 || true
/etc/init.d/uhttpd restart >/dev/null 2>&1 || true
rm -rf /www/blazepwifi-rental
rm -f /usr/sbin/blazepwifi-rental-upgrade /etc/blazepwifi/RENTAL_STANDALONE
if [ "$PURGE" -eq 1 ]; then
  /etc/init.d/blazepwifi stop >/dev/null 2>&1 || true
  /etc/init.d/blazepwifi disable >/dev/null 2>&1 || true
  rm -rf /usr/lib/blazepwifi /usr/sbin/blazepwifi-core /www/blazepwifi /etc/blazepwifi
  rm -f /etc/init.d/blazepwifi /etc/config/blazepwifi
  echo "Rental Standalone software and state purged."
else
  echo "Rental listeners removed. Full BlazePwifi software/state left installed for recovery or conversion."
fi
