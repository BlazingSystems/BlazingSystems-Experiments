#!/bin/sh
set -eu
ROOT="$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

export BP_STATE="$TMP/state"
export BP_RUN="$TMP/run"
export BP_REMOTE_NETWORK_CONFIG="$TMP/network"
export BP_REMOTE_FIREWALL_CONFIG="$TMP/firewall"
export BP_ZT_INIT="$TMP/zerotier.init"
export UCI_LOG="$TMP/uci.log"
export ZT_LOG="$TMP/zt.log"
export OPS_LOG="$TMP/ops.log"
export ADMIN_STATE="$TMP/remote-admin.running"
mkdir -p "$BP_STATE" "$BP_RUN" "$TMP/bin"
printf 'BASE-NETWORK\n' > "$BP_REMOTE_NETWORK_CONFIG"
printf 'BASE-FIREWALL\n' > "$BP_REMOTE_FIREWALL_CONFIG"
: > "$UCI_LOG"; : > "$ZT_LOG"; : > "$OPS_LOG"

cat > "$TMP/bin/uci" <<'UCI'
#!/bin/sh
printf '%s\n' "$*" >> "$UCI_LOG"
case "$*" in
  "commit network") printf 'uci-network-commit\n' >> "$BP_REMOTE_NETWORK_CONFIG" ;;
  "commit firewall") printf 'uci-firewall-commit\n' >> "$BP_REMOTE_FIREWALL_CONFIG" ;;
esac
exit 0
UCI

cat > "$TMP/bin/zerotier-cli" <<'ZT'
#!/bin/sh
printf '%s\n' "$*" >> "$ZT_LOG"
case "$1" in
  -v)
    printf '%s\n' "${ZT_VERSION:-1.14.2}"
    ;;
  info)
    printf '200 info %s %s ONLINE\n' "${ZT_NODE_ID:-abcdef1234}" "${ZT_VERSION:-1.14.2}"
    ;;
  listnetworks)
    printf '200 listnetworks %s TestNet aa:bb:cc:dd:ee:ff %s PRIVATE ztabcdef12 %s\n'       "${ZT_NETWORK_ID:-0123456789abcdef}" "${ZT_STATUS:-ACCESS_DENIED}" "${ZT_CIDR:-10.147.17.2/24}"
    ;;
  get)
    case "${3:-}" in
      status) printf '200 get %s status %s\n' "$2" "${ZT_STATUS:-ACCESS_DENIED}" ;;
      portDeviceName)
        if [ -n "${ZT_DEVICE:-}" ]; then printf '200 get %s portDeviceName %s\n' "$2" "$ZT_DEVICE"; fi
        ;;
      ip4)
        plain="${ZT_CIDR:-10.147.17.2/24}"; plain="${plain%%/*}"
        printf '200 get %s ip4 %s\n' "$2" "$plain"
        ;;
    esac
    ;;
  set)
    exit 0
    ;;
esac
exit 0
ZT

cat > "$TMP/bin/ip" <<'IP'
#!/bin/sh
printf 'ip %s\n' "$*" >> "$OPS_LOG"
case "$*" in
  "-4 addr show dev "*)
    dev="${6:-ztabcdef12}"
    if [ -n "${ZT_KERNEL_IP:-}" ]; then
      printf '7: %s: <POINTOPOINT,UP> mtu 2800\n    inet %s/32 scope global %s\n' "$dev" "$ZT_KERNEL_IP" "$dev"
    fi
    ;;
esac
exit 0
IP
chmod +x "$TMP/bin/"*

cat > "$BP_ZT_INIT" <<'INIT'
#!/bin/sh
printf 'zerotier-init %s\n' "$*" >> "$OPS_LOG"
exit 0
INIT
chmod +x "$BP_ZT_INIT"

export PATH="$TMP/bin:$PATH"

. "$ROOT/openwrt/rootfs/usr/lib/blazepwifi/common.sh"

bp_cfg() {
  case "$1" in
    admin_port) printf '8443' ;;
    durable_sync) printf '0' ;;
    *) printf '' ;;
  esac
}

. "$ROOT/openwrt/rootfs/usr/lib/blazepwifi/console_ops.sh"
. "$ROOT/openwrt/rootfs/usr/lib/blazepwifi/remote_apply.sh"
. "$ROOT/openwrt/rootfs/usr/lib/blazepwifi/zerotier_apply.sh"

export CONNECTED_ROUTES='192.168.1.0/24
172.16.0.0/16'
export ROUTE_SIG='via=192.168.1.1 dev=br-lan'
export DEFAULT_SIG='via=192.168.1.1 dev=eth0'
export BP_REMOTE_CONNECTED_ROUTES_HOOK='printf "%s\n" "$CONNECTED_ROUTES"'
export BP_REMOTE_ROUTE_GET_HOOK='printf "%s" "$ROUTE_SIG"'
export BP_REMOTE_DEFAULT_ROUTE_HOOK='printf "%s" "$DEFAULT_SIG"'
export BP_REMOTE_NETWORK_RELOAD_HOOK='printf "network-reload\n" >> "$OPS_LOG"'
export BP_REMOTE_FIREWALL_RELOAD_HOOK='printf "firewall-reload\n" >> "$OPS_LOG"'
export BP_REMOTE_ADMIN_START_HOOK='touch "$ADMIN_STATE"; printf "admin-start\n" >> "$OPS_LOG"'
export BP_REMOTE_ADMIN_STOP_HOOK='rm -f "$ADMIN_STATE"; printf "admin-stop\n" >> "$OPS_LOG"'
export BP_REMOTE_ADMIN_STATUS_HOOK='test -f "$ADMIN_STATE"'
export BP_ZT_RESTART_HOOK='printf "zt-restart\n" >> "$OPS_LOG"'
export BP_ZT_SETTLE_SECONDS=0

export ZT_NETWORK_ID=0123456789abcdef
export ZT_VERSION=1.14.2
export ZT_STATUS=ACCESS_DENIED
export ZT_DEVICE=
export ZT_CIDR=10.147.17.2/24
export ZT_KERNEL_IP=

save_zt() {
  network_id="$1"; sources="$2"; terminal="${3:-0}"
  bp_remote_save zerotier 1 1 "$terminal" BlazePwifi-ZT Lab "$sources" 30 120     '' 51820 '' '' '' 25 '' 1420 "$network_id"
}

save_zt "$ZT_NETWORK_ID" 10.147.17.0/24

# Version/layout compatibility.
[ "$(bp_zt_layout)" = modern ]
ZT_VERSION=1.14.0
[ "$(bp_zt_layout)" = legacy ]
set +e
bp_zt_prepare
LEGACY_RC=$?
set -e
[ "$LEGACY_RC" -eq 14 ]
[ "$(bp_zt_get state)" = legacy_unsupported ]
! grep -q 'zerotier-init restart' "$OPS_LOG"

# Modern prepare is route-safe: all managed/default/global/DNS injection is disabled.
ZT_VERSION=1.14.2
: > "$UCI_LOG"; : > "$ZT_LOG"; : > "$OPS_LOG"
bp_zt_prepare
[ "$(bp_zt_get state)" = awaiting_authorization ]
[ "$(bp_zt_get node_id)" = abcdef1234 ]
grep -q "zerotier.blazepwifi.allow_managed=0" "$UCI_LOG"
grep -q "zerotier.blazepwifi.allow_global=0" "$UCI_LOG"
grep -q "zerotier.blazepwifi.allow_default=0" "$UCI_LOG"
grep -q "zerotier.blazepwifi.allow_dns=0" "$UCI_LOG"
grep -q "set $ZT_NETWORK_ID allowManaged false" "$ZT_LOG"
grep -q "set $ZT_NETWORK_ID allowGlobal false" "$ZT_LOG"
grep -q "set $ZT_NETWORK_ID allowDefault false" "$ZT_LOG"
grep -q "set $ZT_NETWORK_ID allowDNS false" "$ZT_LOG"
! grep -Eiq '(^|[[:space:]])reboot([[:space:]]|$)' "$OPS_LOG" "$ZT_LOG"

# Authorized but no virtual device => explicit manual reboot state, never auto reboot.
ZT_STATUS=OK
ZT_DEVICE=
bp_zt_refresh
[ "$(bp_zt_get state)" = reboot_required ]
[ "$(bp_zt_get reboot_required)" = 1 ]

# Device appears and controller assigns IPv4 => ready, before any managed route/IP is applied.
ZT_DEVICE=ztabcdef12
bp_zt_refresh
[ "$(bp_zt_get state)" = ready ]
[ "$(bp_zt_get ipv4)" = 10.147.17.2/24 ]
[ "$(bp_zt_get device)" = ztabcdef12 ]

# Route policy rejects dangerous management CIDRs.
save_zt "$ZT_NETWORK_ID" 0.0.0.0/0
set +e
bp_zt_validate_management_routes 10.147.17.2/24 192.168.1.10
BAD_DEFAULT=$?
set -e
[ "$BAD_DEFAULT" -eq 2 ]

save_zt "$ZT_NETWORK_ID" 192.168.1.0/24
set +e
bp_zt_validate_management_routes 10.147.17.2/24 192.168.1.10
BAD_LOCAL=$?
set -e
[ "$BAD_LOCAL" -eq 3 ]

CONNECTED_ROUTES=''
save_zt "$ZT_NETWORK_ID" 192.168.1.0/24
set +e
bp_zt_validate_management_routes 10.147.17.2/24 192.168.1.10
BAD_SOURCE=$?
set -e
[ "$BAD_SOURCE" -eq 4 ]
CONNECTED_ROUTES='192.168.1.0/24
172.16.0.0/16'

# Successful activation installs only Blaze-owned /32 + explicit management route/firewall.
save_zt "$ZT_NETWORK_ID" 10.147.17.0/24 1
bp_zt_refresh
export ZT_KERNEL_IP=10.147.17.2
: > "$UCI_LOG"; : > "$OPS_LOG"
bp_zt_activate 192.168.1.10
[ "$(bp_zt_get state)" = active ]
[ "$(bp_zt_get listener)" = 10.147.17.2:8443 ]
[ -s "$BP_ZT_APPLIED_PROFILE" ]
[ -e "$ADMIN_STATE" ]
grep -q 'network.blazezt=interface' "$UCI_LOG"
grep -q 'network.blazezt.proto=static' "$UCI_LOG"
grep -q 'network.blazezt.ipaddr=10.147.17.2' "$UCI_LOG"
grep -q 'network.blazezt.netmask=255.255.255.255' "$UCI_LOG"
grep -q 'network.blazezt_route_1=route' "$UCI_LOG"
grep -q 'network.blazezt_route_1.target=10.147.17.0/24' "$UCI_LOG"
grep -q 'firewall.blazezt.forward=REJECT' "$UCI_LOG"
grep -q 'firewall.blazezt_admin.dest_port=8443' "$UCI_LOG"
! grep -Eq 'network.(lan|wan)(=|\.)' "$UCI_LOG"
! grep -Eq 'firewall.(lan|wan)(=|\.)' "$UCI_LOG"
! grep -q '0.0.0.0/0' "$UCI_LOG"

# Profile edits keep the live link but mark staged changes; network switching requires disable.
save_zt "$ZT_NETWORK_ID" 10.147.18.0/24 1
bp_zt_refresh
[ "$(bp_zt_get state)" = active_staged_changes ]

save_zt fedcba9876543210 10.147.18.0/24 1
bp_zt_refresh
[ "$(bp_zt_get state)" = active_staged_changes ]
set +e
bp_zt_activate 192.168.1.10
SWITCH_RC=$?
set -e
[ "$SWITCH_RC" -eq 22 ]
set +e
bp_zt_prepare
PREP_ACTIVE_RC=$?
set -e
[ "$PREP_ACTIVE_RC" -eq 15 ]

# Disable cannot be initiated over the ZeroTier path being removed.
ROUTE_SIG='via= dev=ztabcdef12'
set +e
bp_zt_disable 10.147.17.5
DISABLE_REMOTE_RC=$?
set -e
[ "$DISABLE_REMOTE_RC" -eq 14 ]
ROUTE_SIG='via=192.168.1.1 dev=br-lan'

# Return saved profile to the prepared network and disable locally.
save_zt "$ZT_NETWORK_ID" 10.147.17.0/24 1
bp_zt_disable 192.168.1.10
[ "$(bp_zt_get state)" = ready ]
[ ! -e "$BP_ZT_APPLIED_PROFILE" ]
[ ! -e "$ADMIN_STATE" ]
grep -q 'delete network.blazezt' "$UCI_LOG"
grep -q 'delete firewall.blazezt' "$UCI_LOG"

# API/status data must not expose ZeroTier identity secrets.
ZT_JSON="$(bp_zt_status_json)"
! printf '%s' "$ZT_JSON" | grep -qi 'secret'
REMOTE_JSON="$(bp_remote_status_json)"
! printf '%s' "$REMOTE_JSON" | grep -qi 'secret'

echo "v0.5.3-dev.4 ZeroTier activation survival tests passed"
