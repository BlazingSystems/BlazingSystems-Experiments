#!/bin/sh
# Reboot-aware ZeroTier activation for BlazePwifi v0.5.3-dev.4.
# This module is deliberately separate from remote_apply.sh so WireGuard
# transaction ownership and rollback behavior remain isolated.

BP_REMOTE_ZT_ROOT=${BP_REMOTE_ZT_ROOT:-$BP_STATE/remote-zerotier}
BP_REMOTE_ZT_PENDING=${BP_REMOTE_ZT_PENDING:-$BP_STATE/remote-zerotier.pending}
BP_REMOTE_ZT_RUNTIME=${BP_REMOTE_ZT_RUNTIME:-$BP_STATE/remote-zerotier.tsv}
BP_REMOTE_ZT_CONFIG=${BP_REMOTE_ZT_CONFIG:-/etc/config/zerotier}
BP_REMOTE_ZT_NETWORK_CONFIG=${BP_REMOTE_ZT_NETWORK_CONFIG:-${BP_REMOTE_NETWORK_CONFIG:-/etc/config/network}}
BP_REMOTE_ZT_FIREWALL_CONFIG=${BP_REMOTE_ZT_FIREWALL_CONFIG:-${BP_REMOTE_FIREWALL_CONFIG:-/etc/config/firewall}}
BP_REMOTE_ZT_NET_IF=${BP_REMOTE_ZT_NET_IF:-blazezt}
BP_REMOTE_ZT_UCI_NETWORK=${BP_REMOTE_ZT_UCI_NETWORK:-blazezt}
BP_REMOTE_ZT_FW_ZONE=${BP_REMOTE_ZT_FW_ZONE:-blazezt}
BP_REMOTE_ZT_FW_ADMIN=${BP_REMOTE_ZT_FW_ADMIN:-blazezt_admin}
BP_REMOTE_ZT_PENDING_MAX=${BP_REMOTE_ZT_PENDING_MAX:-86400}

bp_remote_zt_init() {
  bp_init_dirs
  mkdir -p "$BP_REMOTE_ZT_ROOT/snapshots"
  chmod 700 "$BP_REMOTE_ZT_ROOT" "$BP_REMOTE_ZT_ROOT/snapshots"
  if [ ! -f "$BP_REMOTE_ZT_RUNTIME" ]; then
    cat > "$BP_REMOTE_ZT_RUNTIME" <<'EOF'
state	staged
tx_id	
profile_sha	
network_id	
node_id	
device	
ip4	
listener	
prepared_at	0
active_at	0
last_error	
reboot_required	0
EOF
    chmod 600 "$BP_REMOTE_ZT_RUNTIME"
  fi
}

bp_remote_zt_get() {
  bp_zt_key="$1"; bp_zt_fallback="${2:-}"
  bp_remote_zt_init
  bp_zt_value="$(awk -F '\t' -v k="$bp_zt_key" '$1==k {sub(/^[^\t]*\t/,""); print; exit}' "$BP_REMOTE_ZT_RUNTIME")"
  [ -n "$bp_zt_value" ] && printf '%s' "$bp_zt_value" || printf '%s' "$bp_zt_fallback"
}

bp_remote_zt_write() {
  bp_zt_state="$1"; bp_zt_tx="$2"; bp_zt_profile="$3"; bp_zt_network="$4"
  bp_zt_node="$5"; bp_zt_device="$6"; bp_zt_ip="$7"; bp_zt_listener="$8"
  bp_zt_prepared="$9"; bp_zt_active="${10}"; bp_zt_error="${11}"; bp_zt_reboot="${12}"
  bp_zt_tmp="$BP_STATE/.remote-zerotier.$(bp_tmp_suffix)"
  {
    printf 'state\t%s\n' "$bp_zt_state"
    printf 'tx_id\t%s\n' "$bp_zt_tx"
    printf 'profile_sha\t%s\n' "$bp_zt_profile"
    printf 'network_id\t%s\n' "$bp_zt_network"
    printf 'node_id\t%s\n' "$bp_zt_node"
    printf 'device\t%s\n' "$bp_zt_device"
    printf 'ip4\t%s\n' "$bp_zt_ip"
    printf 'listener\t%s\n' "$bp_zt_listener"
    printf 'prepared_at\t%s\n' "$bp_zt_prepared"
    printf 'active_at\t%s\n' "$bp_zt_active"
    printf 'last_error\t%s\n' "$bp_zt_error"
    printf 'reboot_required\t%s\n' "$bp_zt_reboot"
  } > "$bp_zt_tmp"
  chmod 600 "$bp_zt_tmp"
  mv "$bp_zt_tmp" "$BP_REMOTE_ZT_RUNTIME"
  bp_durable_sync
}

bp_remote_zt_rewrite_state() {
  bp_zt_new_state="$1"; bp_zt_error="${2:-}"; bp_zt_reboot="${3:-$(bp_remote_zt_get reboot_required 0)}"
  bp_remote_zt_write "$bp_zt_new_state" "$(bp_remote_zt_get tx_id)" "$(bp_remote_zt_get profile_sha)" \
    "$(bp_remote_zt_get network_id)" "$(bp_remote_zt_get node_id)" "$(bp_remote_zt_get device)" \
    "$(bp_remote_zt_get ip4)" "$(bp_remote_zt_get listener)" "$(bp_remote_zt_get prepared_at 0)" \
    "$(bp_remote_zt_get active_at 0)" "$bp_zt_error" "$bp_zt_reboot"
}

bp_remote_zt_profile_hash() {
  {
    printf 'mode=%s\n' "$(bp_remote_get mode disabled)"
    printf 'monitoring=%s\n' "$(bp_remote_get monitoring 1)"
    printf 'management=%s\n' "$(bp_remote_get management 0)"
    printf 'terminal=%s\n' "$(bp_remote_get terminal 0)"
    printf 'source_allowlist=%s\n' "$(bp_remote_get source_allowlist)"
    printf 'zt_network_id=%s\n' "$(bp_remote_get zt_network_id)"
  } | bp_sha256
}

bp_remote_zt_live_supported() {
  [ "$(bp_remote_get mode disabled)" = zerotier ] || return 1
  command -v uci >/dev/null 2>&1 || return 1
  command -v zerotier-cli >/dev/null 2>&1 || return 1
  command -v ip >/dev/null 2>&1 || return 1
  [ -x /etc/init.d/zerotier ] || return 1
  return 0
}

bp_remote_zt_network_valid() {
  printf '%s' "$1" | grep -Eq '^[0-9a-fA-F]{16}$'
}

bp_remote_zt_source_allowlist_valid() {
  [ "$(bp_remote_get management 0)" = 1 ] || return 0
  bp_zt_allow="$(bp_remote_get source_allowlist)"
  [ -n "$bp_zt_allow" ] || return 1
  for bp_zt_cidr in $(bp_remote_split_cidrs "$bp_zt_allow"); do
    printf '%s' "$bp_zt_cidr" | grep -q ':' && return 1
    bp_remote_ipv4_cidr_valid "$bp_zt_cidr" || return 1
    bp_zt_prefix="$(printf '%s' "$bp_zt_cidr" | cut -d/ -f2)"
    [ "$bp_zt_prefix" -ge 8 ] 2>/dev/null || return 1
    [ "$bp_zt_cidr" != 0.0.0.0/0 ] || return 1
  done
}

bp_remote_zt_live_validate() {
  bp_zt_source_ip="${1:-}"
  [ "$(bp_remote_get mode disabled)" = zerotier ] || return 40
  bp_remote_zt_live_supported || return 41
  bp_zt_nwid="$(bp_remote_get zt_network_id)"
  bp_remote_zt_network_valid "$bp_zt_nwid" || return 42
  bp_remote_zt_source_allowlist_valid || return 43

  # Do not silently replace a working WireGuard remote path.
  case "$(bp_remote_runtime_get state staged 2>/dev/null || printf staged)" in
    active|active_staged_changes|applying|disabling) return 44 ;;
  esac

  bp_zt_existing_dev="$(bp_remote_zt_get device)"
  if [ -n "$bp_zt_existing_dev" ] && bp_remote_ipv4_host "$bp_zt_source_ip"; then
    bp_zt_source_sig="$(bp_remote_route_signature "$bp_zt_source_ip" 2>/dev/null || true)"
    case "$bp_zt_source_sig" in *"dev=$bp_zt_existing_dev"*) return 45;; esac
  fi
  return 0
}

bp_remote_zt_snapshot_create() {
  bp_zt_id="$1"
  bp_zt_snap="$BP_REMOTE_ZT_ROOT/snapshots/$bp_zt_id"
  mkdir -p "$bp_zt_snap"
  chmod 700 "$bp_zt_snap"
  for bp_zt_pair in \
    "zerotier:$BP_REMOTE_ZT_CONFIG" \
    "network:$BP_REMOTE_ZT_NETWORK_CONFIG" \
    "firewall:$BP_REMOTE_ZT_FIREWALL_CONFIG" \
    "runtime:$BP_REMOTE_ZT_RUNTIME"
  do
    bp_zt_name="${bp_zt_pair%%:*}"; bp_zt_file="${bp_zt_pair#*:}"
    if [ -f "$bp_zt_file" ]; then
      cp -p "$bp_zt_file" "$bp_zt_snap/$bp_zt_name" || return 1
      chmod 600 "$bp_zt_snap/$bp_zt_name" 2>/dev/null || true
    else
      : > "$bp_zt_snap/$bp_zt_name.absent"
    fi
  done
}

bp_remote_zt_restore_file() {
  bp_zt_snap="$1"; bp_zt_name="$2"; bp_zt_file="$3"
  if [ -f "$bp_zt_snap/$bp_zt_name.absent" ]; then
    rm -f "$bp_zt_file"
  elif [ -f "$bp_zt_snap/$bp_zt_name" ]; then
    mkdir -p "$(dirname "$bp_zt_file")"
    cp -p "$bp_zt_snap/$bp_zt_name" "$bp_zt_file" || return 1
  fi
}

bp_remote_zt_pending_write() {
  bp_zt_id="$1"; bp_zt_profile="$2"; bp_zt_source="$3"; bp_zt_source_sig="$4"; bp_zt_default_sig="$5"
  bp_zt_tmp="$BP_STATE/.remote-zerotier-pending.$(bp_tmp_suffix)"
  printf '%s\t%s\t%s\t%s\t%s\t%s\n' "$bp_zt_id" "$(bp_now)" "$bp_zt_profile" "$bp_zt_source" "$bp_zt_source_sig" "$bp_zt_default_sig" > "$bp_zt_tmp"
  chmod 600 "$bp_zt_tmp"
  mv "$bp_zt_tmp" "$BP_REMOTE_ZT_PENDING"
  bp_durable_sync
}

bp_remote_zt_pending_read() {
  [ -r "$BP_REMOTE_ZT_PENDING" ] || return 1
  cat "$BP_REMOTE_ZT_PENDING"
}

bp_remote_zt_pending_clear() {
  rm -f "$BP_REMOTE_ZT_PENDING"
  bp_durable_sync
}

bp_remote_zt_pending_owned() {
  bp_zt_id="$1"
  bp_zt_line="$(bp_remote_zt_pending_read 2>/dev/null || true)"
  [ "$(printf '%s' "$bp_zt_line" | cut -f1)" = "$bp_zt_id" ]
}

bp_remote_zt_service_restart() {
  if [ -n "${BP_REMOTE_ZT_SERVICE_RESTART_HOOK:-}" ]; then sh -c "$BP_REMOTE_ZT_SERVICE_RESTART_HOOK"; return; fi
  /etc/init.d/zerotier restart >/dev/null 2>&1
}

bp_remote_zt_service_stop() {
  if [ -n "${BP_REMOTE_ZT_SERVICE_STOP_HOOK:-}" ]; then sh -c "$BP_REMOTE_ZT_SERVICE_STOP_HOOK"; return; fi
  /etc/init.d/zerotier stop >/dev/null 2>&1 || true
}

bp_remote_zt_cli() {
  if [ -n "${BP_REMOTE_ZT_CLI_HOOK:-}" ]; then
    BP_REMOTE_ZT_CLI_ARGS="$*" sh -c "$BP_REMOTE_ZT_CLI_HOOK"
    return
  fi
  zerotier-cli "$@" 2>/dev/null
}

bp_remote_zt_node_id() {
  bp_remote_zt_cli info | awk 'NR==1 && $1==200 {print $3; exit}'
}

bp_remote_zt_network_status() {
  bp_remote_zt_cli get "$1" status | awk 'NF{print $NF; exit}'
}

bp_remote_zt_device() {
  bp_remote_zt_cli get "$1" portDeviceName | awk 'NF{print $NF; exit}'
}

bp_remote_zt_ip4() {
  bp_zt_ip_raw="$(bp_remote_zt_cli get "$1" ip4 | awk 'NF{print $NF; exit}')"
  bp_zt_ip_raw="${bp_zt_ip_raw%%,*}"
  bp_zt_ip_raw="${bp_zt_ip_raw%%/*}"
  bp_remote_ipv4_host "$bp_zt_ip_raw" || return 1
  printf '%s' "$bp_zt_ip_raw"
}

bp_remote_zt_device_exists() {
  bp_zt_dev="$1"
  [ -n "$bp_zt_dev" ] || return 1
  if [ -n "${BP_REMOTE_ZT_LINK_HOOK:-}" ]; then
    BP_REMOTE_ZT_DEVICE="$bp_zt_dev" sh -c "$BP_REMOTE_ZT_LINK_HOOK"
    return
  fi
  ip link show dev "$bp_zt_dev" >/dev/null 2>&1
}

bp_remote_zt_device_routes() {
  bp_zt_dev="$1"
  if [ -n "${BP_REMOTE_ZT_ROUTES_HOOK:-}" ]; then
    BP_REMOTE_ZT_DEVICE="$bp_zt_dev" sh -c "$BP_REMOTE_ZT_ROUTES_HOOK"
    return
  fi
  ip -4 route show dev "$bp_zt_dev" 2>/dev/null | awk '
    $1=="default"{print "default";next}
    $1 ~ /^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+\/[0-9]+$/ {print $1;next}
    $1 ~ /^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$/ {print $1"/32"}
  '
}

bp_remote_zt_connected_routes() {
  bp_zt_dev="$1"
  if [ -n "${BP_REMOTE_ZT_CONNECTED_ROUTES_HOOK:-}" ]; then
    BP_REMOTE_ZT_DEVICE="$bp_zt_dev" sh -c "$BP_REMOTE_ZT_CONNECTED_ROUTES_HOOK"
    return
  fi
  ip -4 route show scope link 2>/dev/null | awk -v zt="$bp_zt_dev" -v wg="${BP_REMOTE_WG_IF:-blazewg}" '
    {
      dev=""
      for(i=1;i<=NF;i++) if($i=="dev" && i<NF) dev=$(i+1)
      if(dev==zt || dev==wg) next
    }
    $1=="default"{next}
    $1 ~ /^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+\/[0-9]+$/ {print $1;next}
    $1 ~ /^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$/ {print $1"/32"}
  '
}

bp_remote_zt_routes_safe() {
  bp_zt_dev="$1"; bp_zt_source="$2"; bp_zt_source_before="$3"; bp_zt_default_before="$4"
  [ -n "$bp_zt_dev" ] || return 1

  bp_zt_default_after="$(bp_remote_default_signature 2>/dev/null || true)"
  [ -n "$bp_zt_default_before" ] && [ "$bp_zt_default_after" = "$bp_zt_default_before" ] || return 1

  if bp_remote_ipv4_host "$bp_zt_source" && [ -n "$bp_zt_source_before" ]; then
    bp_zt_source_after="$(bp_remote_route_signature "$bp_zt_source" 2>/dev/null || true)"
    [ "$bp_zt_source_after" = "$bp_zt_source_before" ] || return 1
  fi

  bp_zt_routes="$(bp_remote_zt_device_routes "$bp_zt_dev" 2>/dev/null || true)"
  [ -n "$bp_zt_routes" ] || return 1
  for bp_zt_route in $bp_zt_routes; do
    [ "$bp_zt_route" != default ] || return 1
    bp_remote_ipv4_cidr_valid "$bp_zt_route" || continue
    for bp_zt_local in $(bp_remote_zt_connected_routes "$bp_zt_dev"); do
      bp_remote_ipv4_cidr_valid "$bp_zt_local" || continue
      bp_remote_ipv4_overlap "$bp_zt_route" "$bp_zt_local" && return 1
    done
  done

  if [ "$(bp_remote_get management 0)" = 1 ]; then
    for bp_zt_source_cidr in $(bp_remote_split_cidrs "$(bp_remote_get source_allowlist)"); do
      bp_zt_contained=0
      for bp_zt_route in $bp_zt_routes; do
        [ "$bp_zt_route" != default ] || continue
        bp_remote_ipv4_cidr_valid "$bp_zt_route" || continue
        if bp_remote_ipv4_contains "$bp_zt_route" "$bp_zt_source_cidr"; then bp_zt_contained=1; break; fi
      done
      [ "$bp_zt_contained" = 1 ] || return 1
    done
  fi
}

bp_remote_zt_write_membership_uci() {
  bp_zt_nwid="$(bp_remote_get zt_network_id)"
  uci -q get zerotier.global >/dev/null 2>&1 || uci set zerotier.global=zerotier
  uci set zerotier.global.enabled=1
  uci -q delete zerotier.blazezt || true
  uci set zerotier.blazezt=network
  uci set zerotier.blazezt.id="$bp_zt_nwid"
  uci set zerotier.blazezt.enabled=1
  uci set zerotier.blazezt.allow_managed=1
  uci set zerotier.blazezt.allow_global=0
  uci set zerotier.blazezt.allow_default=0
  uci set zerotier.blazezt.allow_dns=0
  uci commit zerotier
  chmod 600 "$BP_REMOTE_ZT_CONFIG" 2>/dev/null || true
}

bp_remote_zt_remove_membership_uci() {
  uci -q delete zerotier.blazezt || true
  bp_zt_other="$(uci -q show zerotier 2>/dev/null | sed -n 's/^zerotier\.\([^.=]*\)=network$/\1/p' | awk '$1!="blazezt"{print;exit}')"
  [ -n "$bp_zt_other" ] || uci set zerotier.global.enabled=0
  uci commit zerotier
}

bp_remote_zt_write_network_firewall() {
  bp_zt_dev="$1"
  bp_zt_management="$(bp_remote_get management 0)"
  bp_zt_allowlist="$(bp_remote_get source_allowlist)"
  bp_zt_admin_port="$(bp_cfg admin_port)"; [ -n "$bp_zt_admin_port" ] || bp_zt_admin_port=8443

  uci -q delete "network.$BP_REMOTE_ZT_UCI_NETWORK" || true
  uci set "network.$BP_REMOTE_ZT_UCI_NETWORK=interface"
  uci set "network.$BP_REMOTE_ZT_UCI_NETWORK.proto=none"
  uci set "network.$BP_REMOTE_ZT_UCI_NETWORK.device=$bp_zt_dev"

  uci -q delete "firewall.$BP_REMOTE_ZT_FW_ZONE" || true
  uci -q delete "firewall.$BP_REMOTE_ZT_FW_ADMIN" || true
  uci set "firewall.$BP_REMOTE_ZT_FW_ZONE=zone"
  uci set "firewall.$BP_REMOTE_ZT_FW_ZONE.name=$BP_REMOTE_ZT_FW_ZONE"
  uci set "firewall.$BP_REMOTE_ZT_FW_ZONE.input=REJECT"
  uci set "firewall.$BP_REMOTE_ZT_FW_ZONE.output=ACCEPT"
  uci set "firewall.$BP_REMOTE_ZT_FW_ZONE.forward=REJECT"
  uci add_list "firewall.$BP_REMOTE_ZT_FW_ZONE.network=$BP_REMOTE_ZT_UCI_NETWORK"

  if [ "$bp_zt_management" = 1 ]; then
    uci set "firewall.$BP_REMOTE_ZT_FW_ADMIN=rule"
    uci set "firewall.$BP_REMOTE_ZT_FW_ADMIN.name=Allow-BlazePwifi-ZeroTier-Admin"
    uci set "firewall.$BP_REMOTE_ZT_FW_ADMIN.src=$BP_REMOTE_ZT_FW_ZONE"
    uci set "firewall.$BP_REMOTE_ZT_FW_ADMIN.proto=tcp"
    uci set "firewall.$BP_REMOTE_ZT_FW_ADMIN.dest_port=$bp_zt_admin_port"
    uci set "firewall.$BP_REMOTE_ZT_FW_ADMIN.target=ACCEPT"
    for bp_zt_cidr in $(bp_remote_split_cidrs "$bp_zt_allowlist"); do
      uci add_list "firewall.$BP_REMOTE_ZT_FW_ADMIN.src_ip=$bp_zt_cidr"
    done
  fi
  uci commit network
  uci commit firewall
}

bp_remote_zt_remove_network_firewall() {
  uci -q delete "network.$BP_REMOTE_ZT_UCI_NETWORK" || true
  uci -q delete "firewall.$BP_REMOTE_ZT_FW_ZONE" || true
  uci -q delete "firewall.$BP_REMOTE_ZT_FW_ADMIN" || true
  uci commit network
  uci commit firewall
}

bp_remote_zt_admin_sync() {
  bp_zt_state="$(bp_remote_zt_get state staged)"
  bp_zt_listener="$(bp_remote_zt_get listener)"
  case "$bp_zt_state" in
    active|active_staged_changes|finalizing)
      if [ -n "$bp_zt_listener" ]; then
        bp_remote_admin_start || return 1
        bp_remote_admin_running || return 1
      else
        bp_remote_admin_stop || return 1
      fi
      ;;
    *) bp_remote_admin_stop || return 1 ;;
  esac
}

bp_remote_zt_restore_snapshot() {
  bp_zt_id="$1"
  bp_zt_snap="$BP_REMOTE_ZT_ROOT/snapshots/$bp_zt_id"
  [ -d "$bp_zt_snap" ] || return 1
  bp_remote_admin_stop || true
  bp_remote_zt_restore_file "$bp_zt_snap" zerotier "$BP_REMOTE_ZT_CONFIG" || return 1
  bp_remote_zt_restore_file "$bp_zt_snap" network "$BP_REMOTE_ZT_NETWORK_CONFIG" || return 1
  bp_remote_zt_restore_file "$bp_zt_snap" firewall "$BP_REMOTE_ZT_FIREWALL_CONFIG" || return 1
  bp_remote_zt_restore_file "$bp_zt_snap" runtime "$BP_REMOTE_ZT_RUNTIME" || return 1
  bp_remote_zt_service_restart || return 1
  bp_remote_network_reload || return 1
  bp_remote_firewall_reload || return 1
  bp_remote_zt_admin_sync || return 1
}

bp_remote_zt_rollback() {
  bp_zt_id="$1"; bp_zt_reason="${2:-rollback}"
  bp_remote_lock || return 1
  bp_zt_line="$(bp_remote_zt_pending_read 2>/dev/null || true)"
  [ "$(printf '%s' "$bp_zt_line" | cut -f1)" = "$bp_zt_id" ] || { bp_remote_unlock; return 0; }
  if bp_remote_zt_restore_snapshot "$bp_zt_id"; then
    bp_remote_zt_pending_clear
    bp_zt_restored_state="$(bp_remote_zt_get state staged)"
    bp_remote_zt_write "$bp_zt_restored_state" "$(bp_remote_zt_get tx_id)" "$(bp_remote_zt_get profile_sha)" \
      "$(bp_remote_zt_get network_id)" "$(bp_remote_zt_get node_id)" "$(bp_remote_zt_get device)" \
      "$(bp_remote_zt_get ip4)" "$(bp_remote_zt_get listener)" "$(bp_remote_zt_get prepared_at 0)" \
      "$(bp_remote_zt_get active_at 0)" "$bp_zt_reason" "$(bp_remote_zt_get reboot_required 0)"
    bp_remote_unlock
    return 0
  fi
  bp_remote_zt_rewrite_state rollback_failed "$bp_zt_reason" 0
  bp_remote_unlock
  return 1
}

bp_remote_zt_probe() {
  bp_zt_nwid="$1"
  BP_REMOTE_ZT_PROBE_NODE="$(bp_remote_zt_node_id 2>/dev/null || true)"
  BP_REMOTE_ZT_PROBE_STATUS="$(bp_remote_zt_network_status "$bp_zt_nwid" 2>/dev/null || true)"
  BP_REMOTE_ZT_PROBE_DEVICE="$(bp_remote_zt_device "$bp_zt_nwid" 2>/dev/null || true)"
  BP_REMOTE_ZT_PROBE_IP4="$(bp_remote_zt_ip4 "$bp_zt_nwid" 2>/dev/null || true)"
  export BP_REMOTE_ZT_PROBE_NODE BP_REMOTE_ZT_PROBE_STATUS BP_REMOTE_ZT_PROBE_DEVICE BP_REMOTE_ZT_PROBE_IP4
}

bp_remote_zt_prepare() {
  bp_zt_source="${1:-}"
  bp_remote_zt_init
  [ ! -e "$BP_REMOTE_ZT_PENDING" ] || return 46
  bp_remote_zt_live_validate "$bp_zt_source" || return $?

  bp_zt_profile="$(bp_remote_zt_profile_hash)"
  bp_zt_source_sig="$(bp_remote_route_signature "$bp_zt_source" 2>/dev/null || true)"
  bp_zt_default_sig="$(bp_remote_default_signature 2>/dev/null || true)"
  [ -n "$bp_zt_default_sig" ] || return 47
  bp_zt_id="$(date +%Y%m%d%H%M%S)-zt-$(bp_tmp_suffix)"
  bp_zt_nwid="$(bp_remote_get zt_network_id)"

  bp_remote_lock || return 48
  bp_remote_zt_snapshot_create "$bp_zt_id" || { bp_remote_unlock; return 48; }
  bp_remote_zt_pending_write "$bp_zt_id" "$bp_zt_profile" "$bp_zt_source" "$bp_zt_source_sig" "$bp_zt_default_sig" || { bp_remote_unlock; return 48; }
  bp_remote_zt_write preparing "$bp_zt_id" "$bp_zt_profile" "$bp_zt_nwid" "" "" "" "" "$(bp_now)" 0 "" 0
  bp_remote_unlock

  if ! bp_remote_zt_write_membership_uci; then bp_remote_zt_rollback "$bp_zt_id" zerotier-uci-write-failed; return 49; fi
  if ! bp_remote_zt_service_restart; then bp_remote_zt_rollback "$bp_zt_id" zerotier-service-failed; return 50; fi

  sleep_seconds="${BP_REMOTE_ZT_SETTLE_SECONDS:-8}"
  [ "$sleep_seconds" -le 0 ] 2>/dev/null || sleep "$sleep_seconds"
  bp_remote_zt_probe "$bp_zt_nwid"

  case "$BP_REMOTE_ZT_PROBE_STATUS" in
    OK)
      if bp_remote_zt_device_exists "$BP_REMOTE_ZT_PROBE_DEVICE" && [ -n "$BP_REMOTE_ZT_PROBE_IP4" ]; then
        bp_remote_zt_finalize
        return $?
      fi
      bp_remote_zt_write reboot_required "$bp_zt_id" "$bp_zt_profile" "$bp_zt_nwid" "$BP_REMOTE_ZT_PROBE_NODE" \
        "$BP_REMOTE_ZT_PROBE_DEVICE" "$BP_REMOTE_ZT_PROBE_IP4" "" "$(bp_remote_zt_get prepared_at 0)" 0 "" 1
      return 0
      ;;
    ACCESS_DENIED)
      bp_remote_zt_write awaiting_authorization "$bp_zt_id" "$bp_zt_profile" "$bp_zt_nwid" "$BP_REMOTE_ZT_PROBE_NODE" \
        "$BP_REMOTE_ZT_PROBE_DEVICE" "$BP_REMOTE_ZT_PROBE_IP4" "" "$(bp_remote_zt_get prepared_at 0)" 0 "" 0
      return 0
      ;;
    NOT_FOUND|PORT_ERROR)
      bp_remote_zt_rollback "$bp_zt_id" "zerotier-$BP_REMOTE_ZT_PROBE_STATUS"
      return 51
      ;;
    *)
      bp_remote_zt_write awaiting_network "$bp_zt_id" "$bp_zt_profile" "$bp_zt_nwid" "$BP_REMOTE_ZT_PROBE_NODE" \
        "$BP_REMOTE_ZT_PROBE_DEVICE" "$BP_REMOTE_ZT_PROBE_IP4" "" "$(bp_remote_zt_get prepared_at 0)" 0 "" 0
      return 0
      ;;
  esac
}

bp_remote_zt_finalize() {
  bp_remote_zt_init
  bp_zt_line="$(bp_remote_zt_pending_read 2>/dev/null || true)"
  bp_zt_id="$(printf '%s' "$bp_zt_line" | cut -f1)"
  [ -n "$bp_zt_id" ] || {
    [ "$(bp_remote_zt_get state)" = active ] && return 0
    return 52
  }
  bp_zt_created="$(printf '%s' "$bp_zt_line" | cut -f2)"
  bp_zt_profile="$(printf '%s' "$bp_zt_line" | cut -f3)"
  bp_zt_source="$(printf '%s' "$bp_zt_line" | cut -f4)"
  bp_zt_source_sig="$(printf '%s' "$bp_zt_line" | cut -f5)"
  bp_zt_default_sig="$(printf '%s' "$bp_zt_line" | cut -f6)"
  [ "$bp_zt_profile" = "$(bp_remote_zt_profile_hash)" ] || return 53
  bp_zt_nwid="$(bp_remote_get zt_network_id)"
  bp_remote_zt_probe "$bp_zt_nwid"

  case "$BP_REMOTE_ZT_PROBE_STATUS" in
    ACCESS_DENIED)
      bp_remote_zt_write awaiting_authorization "$bp_zt_id" "$bp_zt_profile" "$bp_zt_nwid" "$BP_REMOTE_ZT_PROBE_NODE" \
        "$BP_REMOTE_ZT_PROBE_DEVICE" "$BP_REMOTE_ZT_PROBE_IP4" "" "$bp_zt_created" 0 "" 0
      return 54
      ;;
    OK) ;;
    NOT_FOUND|PORT_ERROR)
      bp_remote_zt_rollback "$bp_zt_id" "zerotier-$BP_REMOTE_ZT_PROBE_STATUS"
      return 55
      ;;
    *)
      bp_remote_zt_write awaiting_network "$bp_zt_id" "$bp_zt_profile" "$bp_zt_nwid" "$BP_REMOTE_ZT_PROBE_NODE" \
        "$BP_REMOTE_ZT_PROBE_DEVICE" "$BP_REMOTE_ZT_PROBE_IP4" "" "$bp_zt_created" 0 "" 0
      return 56
      ;;
  esac

  if ! bp_remote_zt_device_exists "$BP_REMOTE_ZT_PROBE_DEVICE"; then
    bp_remote_zt_write reboot_required "$bp_zt_id" "$bp_zt_profile" "$bp_zt_nwid" "$BP_REMOTE_ZT_PROBE_NODE" \
      "$BP_REMOTE_ZT_PROBE_DEVICE" "$BP_REMOTE_ZT_PROBE_IP4" "" "$bp_zt_created" 0 "" 1
    return 57
  fi
  [ -n "$BP_REMOTE_ZT_PROBE_IP4" ] || {
    bp_remote_zt_write awaiting_address "$bp_zt_id" "$bp_zt_profile" "$bp_zt_nwid" "$BP_REMOTE_ZT_PROBE_NODE" \
      "$BP_REMOTE_ZT_PROBE_DEVICE" "" "" "$bp_zt_created" 0 "" 0
    return 58
  }

  if ! bp_remote_zt_routes_safe "$BP_REMOTE_ZT_PROBE_DEVICE" "$bp_zt_source" "$bp_zt_source_sig" "$bp_zt_default_sig"; then
    bp_remote_zt_rollback "$bp_zt_id" zerotier-route-safety-failed
    return 59
  fi

  if ! bp_remote_zt_write_network_firewall "$BP_REMOTE_ZT_PROBE_DEVICE"; then
    bp_remote_zt_rollback "$bp_zt_id" zerotier-network-firewall-write-failed
    return 60
  fi
  if ! bp_remote_network_reload; then bp_remote_zt_rollback "$bp_zt_id" zerotier-network-reload-failed; return 61; fi
  if ! bp_remote_firewall_reload; then bp_remote_zt_rollback "$bp_zt_id" zerotier-firewall-reload-failed; return 62; fi

  bp_zt_listener=""
  if [ "$(bp_remote_get management 0)" = 1 ]; then
    bp_zt_admin_port="$(bp_cfg admin_port)"; [ -n "$bp_zt_admin_port" ] || bp_zt_admin_port=8443
    bp_zt_listener="$BP_REMOTE_ZT_PROBE_IP4:$bp_zt_admin_port"
  fi
  bp_remote_zt_write finalizing "$bp_zt_id" "$bp_zt_profile" "$bp_zt_nwid" "$BP_REMOTE_ZT_PROBE_NODE" \
    "$BP_REMOTE_ZT_PROBE_DEVICE" "$BP_REMOTE_ZT_PROBE_IP4" "$bp_zt_listener" "$bp_zt_created" 0 "" 0
  if ! bp_remote_zt_admin_sync; then bp_remote_zt_rollback "$bp_zt_id" zerotier-admin-listener-failed; return 63; fi
  if ! bp_remote_zt_routes_safe "$BP_REMOTE_ZT_PROBE_DEVICE" "$bp_zt_source" "$bp_zt_source_sig" "$bp_zt_default_sig"; then
    bp_remote_zt_rollback "$bp_zt_id" zerotier-route-survival-failed
    return 64
  fi

  bp_remote_lock || { bp_remote_zt_rollback "$bp_zt_id" zerotier-finalize-lock-failed; return 65; }
  bp_remote_zt_pending_owned "$bp_zt_id" || { bp_remote_unlock; return 65; }
  bp_remote_zt_pending_clear
  bp_remote_zt_write active "$bp_zt_id" "$bp_zt_profile" "$bp_zt_nwid" "$BP_REMOTE_ZT_PROBE_NODE" \
    "$BP_REMOTE_ZT_PROBE_DEVICE" "$BP_REMOTE_ZT_PROBE_IP4" "$bp_zt_listener" "$bp_zt_created" "$(bp_now)" "" 0
  bp_remote_unlock
  return 0
}

bp_remote_zt_cancel() {
  bp_remote_zt_init
  bp_zt_line="$(bp_remote_zt_pending_read 2>/dev/null || true)"
  bp_zt_id="$(printf '%s' "$bp_zt_line" | cut -f1)"
  [ -n "$bp_zt_id" ] || return 0
  bp_remote_zt_rollback "$bp_zt_id" operator-cancelled
}

bp_remote_zt_disable() {
  bp_zt_source="${1:-}"
  bp_remote_zt_init
  if [ -e "$BP_REMOTE_ZT_PENDING" ]; then
    bp_remote_zt_cancel
    return $?
  fi
  bp_zt_state="$(bp_remote_zt_get state staged)"
  case "$bp_zt_state" in active|active_staged_changes) ;; *) return 0;; esac
  bp_zt_dev="$(bp_remote_zt_get device)"
  if [ -n "$bp_zt_dev" ] && bp_remote_ipv4_host "$bp_zt_source"; then
    bp_zt_sig="$(bp_remote_route_signature "$bp_zt_source" 2>/dev/null || true)"
    case "$bp_zt_sig" in *"dev=$bp_zt_dev"*) return 66;; esac
  fi
  bp_zt_default_sig="$(bp_remote_default_signature 2>/dev/null || true)"
  [ -n "$bp_zt_default_sig" ] || return 47
  bp_zt_source_sig="$(bp_remote_route_signature "$bp_zt_source" 2>/dev/null || true)"
  bp_zt_id="$(date +%Y%m%d%H%M%S)-zt-disable-$(bp_tmp_suffix)"
  bp_zt_profile="$(bp_remote_zt_profile_hash)"

  bp_remote_lock || return 48
  bp_remote_zt_snapshot_create "$bp_zt_id" || { bp_remote_unlock; return 48; }
  bp_remote_zt_pending_write "$bp_zt_id" "$bp_zt_profile" "$bp_zt_source" "$bp_zt_source_sig" "$bp_zt_default_sig" || { bp_remote_unlock; return 48; }
  bp_remote_unlock

  bp_remote_admin_stop || { bp_remote_zt_rollback "$bp_zt_id" zerotier-disable-admin-stop-failed; return 63; }
  bp_remote_zt_remove_network_firewall || { bp_remote_zt_rollback "$bp_zt_id" zerotier-disable-network-firewall-failed; return 60; }
  bp_remote_zt_remove_membership_uci || { bp_remote_zt_rollback "$bp_zt_id" zerotier-disable-membership-failed; return 49; }
  bp_remote_zt_service_restart || { bp_remote_zt_rollback "$bp_zt_id" zerotier-disable-service-failed; return 50; }
  bp_remote_network_reload || { bp_remote_zt_rollback "$bp_zt_id" zerotier-disable-network-reload-failed; return 61; }
  bp_remote_firewall_reload || { bp_remote_zt_rollback "$bp_zt_id" zerotier-disable-firewall-reload-failed; return 62; }
  bp_remote_route_health "$bp_zt_source" "$bp_zt_source_sig" "$bp_zt_default_sig" || {
    bp_remote_zt_rollback "$bp_zt_id" zerotier-disable-route-survival-failed
    return 64
  }

  bp_remote_lock || { bp_remote_zt_rollback "$bp_zt_id" zerotier-disable-finalize-lock-failed; return 65; }
  bp_remote_zt_pending_clear
  bp_remote_zt_write staged "$bp_zt_id" "$bp_zt_profile" "$(bp_remote_get zt_network_id)" "$(bp_remote_zt_get node_id)" "" "" "" \
    "$(bp_now)" "$(bp_now)" "" 0
  bp_remote_unlock
}

bp_remote_zt_boot_finalize() {
  bp_remote_zt_init
  bp_zt_line="$(bp_remote_zt_pending_read 2>/dev/null || true)"
  [ -n "$bp_zt_line" ] || return 0
  bp_zt_created="$(printf '%s' "$bp_zt_line" | cut -f2)"
  bp_zt_now="$(bp_now)"
  if [ "$bp_zt_created" -gt 0 ] 2>/dev/null && [ $((bp_zt_now-bp_zt_created)) -gt "$BP_REMOTE_ZT_PENDING_MAX" ] 2>/dev/null; then
    bp_remote_zt_rollback "$(printf '%s' "$bp_zt_line" | cut -f1)" zerotier-pending-expired
    return
  fi
  sleep_seconds="${BP_REMOTE_ZT_BOOT_SETTLE_SECONDS:-12}"
  [ "$sleep_seconds" -le 0 ] 2>/dev/null || sleep "$sleep_seconds"
  bp_remote_zt_finalize || true
}

bp_remote_zt_activation_state() {
  bp_remote_zt_init
  bp_zt_state="$(bp_remote_zt_get state staged)"
  if [ "$bp_zt_state" = active ]; then
    [ "$(bp_remote_zt_get profile_sha)" = "$(bp_remote_zt_profile_hash)" ] || { printf active_staged_changes; return; }
  fi
  printf '%s' "$bp_zt_state"
}

bp_remote_zt_status_json() {
  bp_zt_state="$(bp_remote_zt_activation_state)"
  if bp_remote_zt_live_supported; then bp_zt_supported=true; else bp_zt_supported=false; fi
  printf '{"activation_state":"%s","apply_supported":%s,"network_id":"%s","node_id":"%s","device":"%s","ip4":"%s","listener":"%s","prepared_at":%s,"active_at":%s,"last_error":"%s","reboot_required":%s}' \
    "$(bp_json_escape "$bp_zt_state")" "$bp_zt_supported" "$(bp_json_escape "$(bp_remote_zt_get network_id)")" \
    "$(bp_json_escape "$(bp_remote_zt_get node_id)")" "$(bp_json_escape "$(bp_remote_zt_get device)")" \
    "$(bp_json_escape "$(bp_remote_zt_get ip4)")" "$(bp_json_escape "$(bp_remote_zt_get listener)")" \
    "$(bp_remote_zt_get prepared_at 0)" "$(bp_remote_zt_get active_at 0)" \
    "$(bp_json_escape "$(bp_remote_zt_get last_error)")" "$(bp_remote_zt_get reboot_required 0)"
}
