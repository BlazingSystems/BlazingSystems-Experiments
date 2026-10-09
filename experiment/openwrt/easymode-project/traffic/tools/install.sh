#!/bin/sh
set -eu
cd "$(dirname "$0")"
[ "$(id -u)" = 0 ] || { echo 'Run as the router administrator.'; exit 1; }
if command -v apk >/dev/null 2>&1 && ! command -v opkg >/dev/null 2>&1; then
 echo 'This release contains opkg IPKs, not signed OpenWrt APKs. Installation stopped without changes.'; exit 1
fi
command -v opkg >/dev/null || { echo 'A supported OpenWrt opkg runtime is required.'; exit 1; }
. /etc/openwrt_release
case "$DISTRIB_RELEASE" in 24.10.*) ;; *) echo 'Validated runtime family: OpenWrt 24.10. Installation stopped.'; exit 1 ;; esac
for pkg in ucode ucode-mod-fs ucode-mod-uci ucode-mod-ubus rpcd rpcd-mod-ucode uhttpd-mod-ubus nftables-json; do
 opkg status "$pkg" | grep -q '^Status:.* installed' || { echo "Missing runtime dependency: $pkg. Install from your matching OpenWrt feed, then retry."; exit 1; }
done
umask 077
mkdir -p /etc/easymode-traffic
sysupgrade -b /etc/easymode-traffic/pre-v7-settings.tar.gz
opkg install ./EasyMode-v7.0.0-Core-all.ipk
for pkg in ./EasyMode-v7.0.0-*-all.ipk; do
 case "$pkg" in *-Core-*) continue ;; esac
 opkg install "$pkg"
done
echo 'EasyMode Traffic Intelligence installed. Open /traffic/ on your router. Existing management and network settings are preserved.'
