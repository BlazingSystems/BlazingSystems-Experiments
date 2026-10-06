#!/bin/sh
# R281 / EasyMode compatibility entry for BlazePwifi Standalone Rental.
# Keep this script BusyBox/POSIX-only: the validated R281 is OpenWrt 24.10.x
# with BusyBox userland and an existing EasyMode uHTTPd layout.
set -eu

D="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
die(){ echo "ERROR: $*" >&2; exit 1; }

[ "$(id -u)" = 0 ] || die "Run as root."
[ -f /etc/openwrt_release ] || die "OpenWrt not detected."
. /etc/openwrt_release

BOARD="$(cat /tmp/sysinfo/board_name 2>/dev/null || true)"
[ "$BOARD" = "notion,r281" ] || die "R281 installer expected notion,r281; detected '${BOARD:-unknown}'."

case "${DISTRIB_RELEASE:-}" in
  24.10.*) ;;
  *) die "Validated R281 path expects OpenWrt 24.10.x; detected '${DISTRIB_RELEASE:-unknown}'." ;;
esac

command -v uci >/dev/null 2>&1 || die "uci missing."
command -v tar >/dev/null 2>&1 || die "tar missing."
command -v cp >/dev/null 2>&1 || die "cp missing."

HOME_DIR="$(uci -q get uhttpd.main.home || true)"
CGI_PREFIX="$(uci -q get uhttpd.main.cgi_prefix || true)"
[ "$HOME_DIR" = "/www" ] || die "R281 EasyMode uHTTPd home is '$HOME_DIR', expected /www."
[ "$CGI_PREFIX" = "/cgi-bin" ] || die "R281 EasyMode CGI prefix is '$CGI_PREFIX', expected /cgi-bin."
uci show uhttpd.main 2>/dev/null | grep -q "listen_https.*:443" || die "R281 EasyMode uHTTPd does not expose HTTPS :443."

echo "R281 / EasyMode compatibility profile confirmed."
echo "Board: $BOARD"
echo "OpenWrt: ${DISTRIB_RELEASE:-unknown}"
echo "Web root: $HOME_DIR"
echo "CGI prefix: $CGI_PREFIX"

exec "$D/install.sh" --target=r281 "$@"
