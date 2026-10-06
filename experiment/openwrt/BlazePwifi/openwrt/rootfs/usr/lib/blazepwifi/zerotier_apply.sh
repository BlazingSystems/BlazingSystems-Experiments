#!/bin/sh
# BlazePwifi ZeroTier compatibility and activation adapter.
# Prepare/join and live management activation are deliberately separate.
# ZeroTier-managed route/DNS injection is disabled; BlazePwifi owns only
# explicit remote-management address/routes/firewall sections.

BP_ZT_RUNTIME=${BP_ZT_RUNTIME:-$BP_STATE/zerotier-runtime.tsv}
BP_ZT_APPLIED_PROFILE=${BP_ZT_APPLIED_PROFILE:-$BP_STATE/zerotier-profile.sha}
BP_ZT_PENDING=${BP_ZT_PENDING:-$BP_STATE/zerotier-apply.pending}
BP_ZT_CONFIG=${BP_ZT_CONFIG:-/etc/config/zerotier}
BP_ZT_INIT=${BP_ZT_INIT:-/etc/init.d/zerotier}
BP_ZT_NET_IF=${BP_ZT_NET_IF:-blazezt}
BP_ZT_FW_ZONE=${BP_ZT_FW_ZONE:-blazezt}
BP_ZT_FW_ADMIN=${BP_ZT_FW_ADMIN:-blazezt_admin}

bp_zt_init() {
  bp_init_dirs
  if [ ! -f "$BP_ZT_RUNTIME" ]; then
    cat > "$BP_ZT_RUNTIME" <<'EOF'
state	staged
network_id	
node_id	
device	
ipv4	
listener	
applied_at	0
last_error	
layout	unknown
reboot_required	0
EOF
    chmod 600 "$BP_ZT_RUNTIME"
  fi
}

bp_zt_get() {
  key="$1"; fallback="${2:-}"
  bp_zt_init
  value="$(awk -F '\t' -v k="$key" '$1==k {sub(/^[^\t]*\t/,""); print; exit}' "$BP_ZT_RUNTIME")"
  [ -n "$value" ] && printf '%s' "$value" || printf '%s' "$fallback"
}

bp_zt_write() {
  state="$1"; network_id="$2"; node_id="$3"; device="$4"; ipv4="$5"
  listener="$6"; applied_at="$7"; last_error="$8"; layout="$9"; reboot_required="${10}"
  tmp="$BP_STATE/.zerotier-runtime.$(bp_tmp_suffix)"
  {
    printf 'state\t%s\n' "$state"
    printf 'network_id\t%s\n' "$network_id"
    printf 'node_id\t%s\n' "$node_id"
    printf 'device\t%s\n' "$device"
    printf 'ipv4\t%s\n' "$ipv4"
    printf 'listener\t%s\n' "$listener"
    printf 'applied_at\t%s\n' "$applied_at"
    printf 'last_error\t%s\n' "$last_error"
    printf 'layout\t%s\n' "$layout"
    printf 'reboot_required\t%s\n' "$reboot_required"
  } > "$tmp"
  chmod 600 "$tmp"
  mv "$tmp" "$BP_ZT_RUNTIME"
  bp_durable_sync
}

bp_zt_supported() {
  command -v zerotier-cli >/dev/null 2>&1 &&
  command -v uci >/dev/null 2>&1 &&
  [ -x "$BP_ZT_INIT" ]
}

bp_zt_version() {
  raw="$(zerotier-cli -v 2>/dev/null || zerotier-one -v 2>/dev/null || true)"
  printf '%s\n' "$raw" | sed -n 's/.*\([0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*\).*/\1/p' | head -n1
}

bp_zt_version_ge_1141() {
  version="$(bp_zt_version)"
  [ -n "$version" ] || return 1
  printf '%s\n' "$version" | awk -F. '{
    if($1>1) exit 0
    if($1<1) exit 1
    if($2>14) exit 0
    if($2<14) exit 1
    exit !($3>=1)
  }'
}

bp_zt_layout() {
  if bp_zt_version_ge_1141; then printf 'modern'; else printf 'legacy'; fi
}

bp_zt_network_id_valid() {
  printf '%s' "$1" | grep -Eq '^[0-9A-Fa-f]{16}$'
}

bp_zt_profile_hash() {
  {
    printf 'mode=%s\n' "$(bp_remote_get mode disabled)"
    printf 'management=%s\n' "$(bp_remote_get management 0)"
    printf 'terminal=%s\n' "$(bp_remote_get terminal 0)"
    printf 'source_allowlist=%s\n' "$(bp_remote_get source_allowlist)"
    printf 'zt_network_id=%s\n' "$(bp_remote_get zt_network_id)"
  } | bp_sha256
}

bp_zt_applied_profile_get() {
  [ -r "$BP_ZT_APPLIED_PROFILE" ] || return 1
  head -n1 "$BP_ZT_APPLIED_PROFILE" | tr -d '\r\n'
}

bp_zt_applied_profile_set() {
  value="$1"
  tmp="$BP_STATE/.zerotier-profile.$(bp_tmp_suffix)"
  printf '%s\n' "$value" > "$tmp"
  chmod 600 "$tmp"
  mv "$tmp" "$BP_ZT_APPLIED_PROFILE"
  bp_durable_sync
}

bp_zt_applied_profile_clear() {
  rm -f "$BP_ZT_APPLIED_PROFILE"
  bp_durable_sync
}

bp_zt_configure_uci() {
  network_id="$1"
  bp_zt_network_id_valid "$network_id" || return 2
  [ "$(bp_zt_layout)" = modern ] || return 14

  uci -q delete zerotier.blazepwifi || true
  uci set zerotier.global=zerotier
  uci set zerotier.global.enabled='1'
  uci set zerotier.blazepwifi=network
  uci set "zerotier.blazepwifi.id=$network_id"
  uci set zerotier.blazepwifi.allow_managed='0'
  uci set zerotier.blazepwifi.allow_global='0'
  uci set zerotier.blazepwifi.allow_default='0'
  uci set zerotier.blazepwifi.allow_dns='0'
  uci commit zerotier
  printf 'modern'
}

bp_zt_service_restart() {
  if [ -n "${BP_ZT_RESTART_HOOK:-}" ]; then sh -c "$BP_ZT_RESTART_HOOK"; return; fi
  "$BP_ZT_INIT" restart >/dev/null 2>&1
}

bp_zt_node_id() {
  zerotier-cli info 2>/dev/null | awk '$1==200 && $2=="info" {print $3; exit}'
}

bp_zt_network_status() {
  network_id="$1"
  status="$(zerotier-cli get "$network_id" status 2>/dev/null | tail -n1 | tr -d '\r' | awk '{print $NF}')"
  case "$status" in
    OK|ACCESS_DENIED|REQUESTING_CONFIGURATION|NOT_FOUND|PORT_ERROR)
      printf '%s' "$status"; return 0 ;;
  esac
  line="$(zerotier-cli listnetworks 2>/dev/null | grep -i "$network_id" | head -n1 || true)"
  printf '%s\n' "$line" | grep -Eo 'OK|ACCESS_DENIED|REQUESTING_CONFIGURATION|NOT_FOUND|PORT_ERROR' | head -n1
}

bp_zt_device() {
  network_id="$1"
  dev="$(zerotier-cli get "$network_id" portDeviceName 2>/dev/null | tail -n1 | tr -d '\r' | awk '{print $NF}')"
  printf '%s' "$dev" | grep -Eq '^zt[[:alnum:]]{4,15}$' || return 1
  printf '%s' "$dev"
}

bp_zt_assigned_ipv4_cidr() {
  network_id="$1"
  line="$(zerotier-cli listnetworks 2>/dev/null | grep -i "$network_id" | head -n1 || true)"
  cidr="$(printf '%s\n' "$line" | grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}/[0-9]{1,2}' | head -n1 || true)"
  if [ -z "$cidr" ]; then
    plain="$(zerotier-cli get "$network_id" ip4 2>/dev/null | tail -n1 | tr -d '\r' | awk '{print $NF}')"
    if bp_remote_ipv4_host "$plain"; then cidr="$plain/32"; fi
  fi
  [ -n "$cidr" ] || return 1
  bp_remote_ipv4_cidr_valid "$cidr" || return 1
  printf '%s' "$cidr"
}

bp_zt_prepare() {
  [ "$(bp_remote_get mode disabled)" = zerotier ] || return 10
  bp_zt_supported || return 11
  network_id="$(bp_remote_get zt_network_id)"
  bp_zt_network_id_valid "$network_id" || return 12

  prior_state="$(bp_zt_get state staged)"
  case "$prior_state" in
    active|active_staged_changes) return 15 ;;
  esac

  layout="$(bp_zt_layout)"
  if [ "$layout" != modern ]; then
    bp_zt_write legacy_unsupported "$network_id" "" "" "" "" 0       "ZeroTier <=1.14.0 live activation is safety-disabled on OpenWrt" "$layout" 0
    return 14
  fi

  bp_zt_configure_uci "$network_id" >/dev/null || return $?
  bp_zt_service_restart || return 13
  sleep "${BP_ZT_SETTLE_SECONDS:-2}"

  # Defense in depth: the package UCI is already set to false, and the client
  # settings are forced false again before any readiness decision.
  zerotier-cli set "$network_id" allowManaged false >/dev/null 2>&1 || true
  zerotier-cli set "$network_id" allowGlobal false >/dev/null 2>&1 || true
  zerotier-cli set "$network_id" allowDefault false >/dev/null 2>&1 || true
  zerotier-cli set "$network_id" allowDNS false >/dev/null 2>&1 || true

  node_id="$(bp_zt_node_id)"
  status="$(bp_zt_network_status "$network_id")"
  device="$(bp_zt_device "$network_id" 2>/dev/null || true)"
  ipv4="$(bp_zt_assigned_ipv4_cidr "$network_id" 2>/dev/null || true)"

  state=joining; reboot_required=0; error=""
  case "$status" in
    OK)
      if [ -z "$device" ]; then
        state=reboot_required; reboot_required=1
      elif [ -z "$ipv4" ]; then
        state=awaiting_address
      else
        state=ready
      fi
      ;;
    ACCESS_DENIED) state=awaiting_authorization ;;
    REQUESTING_CONFIGURATION|"") state=joining ;;
    *) state=join_error; error="$status" ;;
  esac

  bp_zt_write "$state" "$network_id" "$node_id" "$device" "$ipv4" "" 0 "$error" "$layout" "$reboot_required"
  [ "$state" != join_error ]
}

bp_zt_refresh() {
  bp_zt_init
  network_id="$(bp_zt_get network_id)"
  [ -n "$network_id" ] || network_id="$(bp_remote_get zt_network_id)"
  bp_zt_network_id_valid "$network_id" || return 1

  layout="$(bp_zt_layout)"
  if [ "$layout" != modern ]; then
    bp_zt_write legacy_unsupported "$network_id" "$(bp_zt_node_id)" "" "" "" 0       "ZeroTier <=1.14.0 live activation is safety-disabled" "$layout" 0
    return 0
  fi

  node_id="$(bp_zt_node_id)"
  status="$(bp_zt_network_status "$network_id")"
  device="$(bp_zt_device "$network_id" 2>/dev/null || true)"
  ipv4="$(bp_zt_assigned_ipv4_cidr "$network_id" 2>/dev/null || true)"
  listener="$(bp_zt_get listener)"
  applied_at="$(bp_zt_get applied_at 0)"
  prior="$(bp_zt_get state staged)"

  current_profile="$(bp_zt_profile_hash)"
  applied_profile="$(bp_zt_applied_profile_get 2>/dev/null || true)"
  if [ "$prior" = active ] && [ -n "$applied_profile" ] && [ "$current_profile" != "$applied_profile" ]; then
    prior=active_staged_changes
  fi

  state="$prior"; reboot_required=0; error=""
  case "$status" in
    OK)
      if [ -z "$device" ]; then state=reboot_required; reboot_required=1
      elif [ -z "$ipv4" ]; then state=awaiting_address
      else
        case "$prior" in active|active_staged_changes) state="$prior" ;; *) state=ready ;; esac
      fi
      ;;
    ACCESS_DENIED) state=awaiting_authorization ;;
    REQUESTING_CONFIGURATION|"") state=joining ;;
    *) state=join_error; error="$status" ;;
  esac

  bp_zt_write "$state" "$network_id" "$node_id" "$device" "$ipv4" "$listener" "$applied_at" "$error" "$layout" "$reboot_required"
}

bp_zt_source_on_device() {
  source_ip="$1"; device="$2"
  [ -n "$source_ip" ] && [ -n "$device" ] || return 1
  sig="$(bp_remote_route_signature "$source_ip" 2>/dev/null || true)"
  case "$sig" in *"dev=$device"*) return 0 ;; *) return 1 ;; esac
}

bp_zt_pending_write() {
  id="$1"; operation="$2"
  tmp="$BP_STATE/.zerotier-pending.$(bp_tmp_suffix)"
  printf '%s\t%s\t%s\n' "$id" "$(bp_now)" "$operation" > "$tmp"
  chmod 600 "$tmp"
  mv "$tmp" "$BP_ZT_PENDING"
  bp_durable_sync
}

bp_zt_pending_id() {
  [ -r "$BP_ZT_PENDING" ] || return 1
  cut -f1 "$BP_ZT_PENDING" | head -n1
}

bp_zt_pending_owned() {
  [ "$(bp_zt_pending_id 2>/dev/null || true)" = "$1" ]
}

bp_zt_pending_clear() {
  rm -f "$BP_ZT_PENDING"
  bp_durable_sync
}

bp_zt_guard_spawn() {
  id="$1"
  if [ -n "${BP_ZT_GUARD_HOOK:-}" ]; then
    BP_ZT_GUARD_ID="$id" sh -c "$BP_ZT_GUARD_HOOK"
    return
  fi
  seconds="${BP_ZT_GUARD_SECONDS:-90}"
  (
    sleep "$seconds"
    /usr/sbin/blazepwifi-remote-guard --zerotier "$id"
  ) >"$BP_RUN/zerotier-guard-$id.log" 2>&1 </dev/null &
}

bp_zt_snapshot_create() {
  id="$1"
  snap="$BP_REMOTE_APPLY_ROOT/snapshots/$id"
  mkdir -p "$snap"; chmod 700 "$snap"
  for pair in     "network:$BP_REMOTE_NETWORK_CONFIG"     "firewall:$BP_REMOTE_FIREWALL_CONFIG"     "ztruntime:$BP_ZT_RUNTIME"     "ztprofile:$BP_ZT_APPLIED_PROFILE"
  do
    name="${pair%%:*}"; file="${pair#*:}"
    if [ -f "$file" ]; then
      cp -p "$file" "$snap/$name" || return 1
      chmod 600 "$snap/$name" 2>/dev/null || true
    else
      : > "$snap/$name.absent"
    fi
  done
}

bp_zt_restore_snapshot() {
  id="$1"; snap="$BP_REMOTE_APPLY_ROOT/snapshots/$id"
  [ -d "$snap" ] || return 1
  bp_remote_admin_stop || true
  bp_remote_config_restore_file "$snap" network "$BP_REMOTE_NETWORK_CONFIG" || return 1
  bp_remote_config_restore_file "$snap" firewall "$BP_REMOTE_FIREWALL_CONFIG" || return 1
  bp_remote_config_restore_file "$snap" ztruntime "$BP_ZT_RUNTIME" || return 1
  bp_remote_config_restore_file "$snap" ztprofile "$BP_ZT_APPLIED_PROFILE" || return 1
  bp_remote_network_reload || return 1
  bp_remote_firewall_reload || return 1
  bp_remote_admin_sync || return 1
}

bp_zt_rollback_pending() {
  id="$1"; reason="${2:-zerotier-rollback}"
  bp_remote_lock || return 1
  if ! bp_zt_pending_owned "$id"; then
    bp_remote_unlock
    return 0
  fi

  if bp_zt_restore_snapshot "$id"; then
    bp_zt_pending_clear
    state="$(bp_zt_get state staged)"
    network_id="$(bp_zt_get network_id)"
    node_id="$(bp_zt_get node_id)"
    device="$(bp_zt_get device)"
    ipv4="$(bp_zt_get ipv4)"
    listener="$(bp_zt_get listener)"
    applied_at="$(bp_zt_get applied_at 0)"
    layout="$(bp_zt_get layout unknown)"
    reboot_required="$(bp_zt_get reboot_required 0)"
    bp_zt_write "$state" "$network_id" "$node_id" "$device" "$ipv4" "$listener"       "$applied_at" "$reason" "$layout" "$reboot_required"
    bp_remote_unlock
    return 0
  fi

  bp_remote_unlock
  return 1
}

bp_zt_guard() {
  id="$1"
  bp_zt_pending_owned "$id" || return 0
  bp_zt_rollback_pending "$id" zerotier-watchdog-timeout
}

bp_zt_guard_boot() {
  id="$(bp_zt_pending_id 2>/dev/null || true)"
  [ -n "$id" ] || return 0
  bp_zt_rollback_pending "$id" reboot-during-zerotier-transaction
}

bp_zt_clear_owned_routes() {
  i=1
  while [ "$i" -le 32 ]; do
    uci -q delete "network.blazezt_route_$i" || true
    i=$((i+1))
  done
}

bp_zt_validate_management_routes() {
  ipv4_cidr="$1"; source_ip="$2"
  allowlist="$(bp_remote_get source_allowlist)"
  management="$(bp_remote_get management 0)"
  [ "$management" = 0 ] && return 0
  [ -n "$allowlist" ] || return 2

  ip_plain="$(printf '%s' "$ipv4_cidr" | cut -d/ -f1)"
  bp_remote_ipv4_host "$ip_plain" || return 2

  for local_cidr in $(bp_remote_connected_routes); do
    bp_remote_ipv4_cidr_valid "$local_cidr" || continue
    if bp_remote_ipv4_overlap "$ip_plain/32" "$local_cidr"; then return 3; fi
  done

  for cidr in $(bp_remote_split_cidrs "$allowlist"); do
    bp_remote_ipv4_cidr_valid "$cidr" || return 2
    prefix="$(printf '%s' "$cidr" | cut -d/ -f2)"
    [ "$prefix" -ge 8 ] 2>/dev/null || return 2
    [ "$cidr" != "0.0.0.0/0" ] || return 2

    for local_cidr in $(bp_remote_connected_routes); do
      bp_remote_ipv4_cidr_valid "$local_cidr" || continue
      if bp_remote_ipv4_overlap "$cidr" "$local_cidr"; then return 3; fi
    done

    if bp_remote_ipv4_host "$source_ip" && bp_remote_ipv4_overlap "$cidr" "$source_ip/32"; then
      return 4
    fi
  done
  return 0
}

bp_zt_write_network_firewall() {
  device="$1"; ipv4_cidr="$2"; source_ip="$3"
  management="$(bp_remote_get management 0)"
  allowlist="$(bp_remote_get source_allowlist)"
  admin_port="$(bp_cfg admin_port)"; [ -n "$admin_port" ] || admin_port=8443

  bp_zt_validate_management_routes "$ipv4_cidr" "$source_ip" || return $?
  ip_plain="$(printf '%s' "$ipv4_cidr" | cut -d/ -f1)"

  uci -q delete "network.$BP_ZT_NET_IF" || true
  bp_zt_clear_owned_routes
  uci set "network.$BP_ZT_NET_IF=interface"
  uci set "network.$BP_ZT_NET_IF.proto=static"
  uci set "network.$BP_ZT_NET_IF.device=$device"
  uci set "network.$BP_ZT_NET_IF.ipaddr=$ip_plain"
  uci set "network.$BP_ZT_NET_IF.netmask=255.255.255.255"

  if [ "$management" = 1 ]; then
    i=1
    for cidr in $(bp_remote_split_cidrs "$allowlist"); do
      uci set "network.blazezt_route_$i=route"
      uci set "network.blazezt_route_$i.interface=$BP_ZT_NET_IF"
      uci set "network.blazezt_route_$i.target=$cidr"
      i=$((i+1))
    done
  fi

  uci -q delete "firewall.$BP_ZT_FW_ZONE" || true
  uci -q delete "firewall.$BP_ZT_FW_ADMIN" || true
  uci set "firewall.$BP_ZT_FW_ZONE=zone"
  uci set "firewall.$BP_ZT_FW_ZONE.name=$BP_ZT_FW_ZONE"
  uci set "firewall.$BP_ZT_FW_ZONE.input=REJECT"
  uci set "firewall.$BP_ZT_FW_ZONE.output=ACCEPT"
  uci set "firewall.$BP_ZT_FW_ZONE.forward=REJECT"
  uci add_list "firewall.$BP_ZT_FW_ZONE.network=$BP_ZT_NET_IF"

  if [ "$management" = 1 ]; then
    uci set "firewall.$BP_ZT_FW_ADMIN=rule"
    uci set "firewall.$BP_ZT_FW_ADMIN.name=Allow-BlazePwifi-ZeroTier-Admin"
    uci set "firewall.$BP_ZT_FW_ADMIN.src=$BP_ZT_FW_ZONE"
    uci set "firewall.$BP_ZT_FW_ADMIN.proto=tcp"
    uci set "firewall.$BP_ZT_FW_ADMIN.dest_port=$admin_port"
    uci set "firewall.$BP_ZT_FW_ADMIN.target=ACCEPT"
    for cidr in $(bp_remote_split_cidrs "$allowlist"); do
      uci add_list "firewall.$BP_ZT_FW_ADMIN.src_ip=$cidr"
    done
  fi

  uci commit network
  uci commit firewall
}

bp_zt_interface_health() {
  device="$1"; ipv4_cidr="$2"
  ip_plain="$(printf '%s' "$ipv4_cidr" | cut -d/ -f1)"
  ip -4 addr show dev "$device" 2>/dev/null | grep -Eq "inet[[:space:]]+$ip_plain/32([[:space:]]|$)"
}

bp_zt_activate() {
  source_ip="${1:-}"
  [ "$(bp_remote_get mode disabled)" = zerotier ] || return 10
  bp_zt_supported || return 11
  [ ! -e "$BP_ZT_PENDING" ] || return 23

  bp_zt_refresh || return 12
  state="$(bp_zt_get state)"
  [ "$state" = ready ] || [ "$state" = active_staged_changes ] || return 13

  desired_network="$(bp_remote_get zt_network_id)"
  runtime_network="$(bp_zt_get network_id)"
  [ "$desired_network" = "$runtime_network" ] || return 22

  device="$(bp_zt_get device)"
  ipv4="$(bp_zt_get ipv4)"
  [ -n "$device" ] && [ -n "$ipv4" ] || return 13
  bp_zt_source_on_device "$source_ip" "$device" && return 14

  before_default="$(bp_remote_default_signature 2>/dev/null || true)"
  before_source="$(bp_remote_route_signature "$source_ip" 2>/dev/null || true)"
  [ -n "$before_default" ] || return 15

  id="$(date +%Y%m%d%H%M%S)-zt-$(bp_tmp_suffix)"
  bp_remote_lock || return 16
  bp_zt_snapshot_create "$id" || { bp_remote_unlock; return 16; }
  bp_zt_pending_write "$id" activate || { bp_remote_unlock; return 16; }
  bp_remote_unlock
  bp_zt_guard_spawn "$id"

  if ! bp_zt_write_network_firewall "$device" "$ipv4" "$source_ip"; then
    bp_zt_rollback_pending "$id" policy-write-failed
    return 17
  fi
  bp_zt_pending_owned "$id" || return 24

  if ! bp_remote_network_reload; then
    bp_zt_rollback_pending "$id" network-reload-failed
    return 18
  fi
  bp_zt_pending_owned "$id" || return 24

  if ! bp_remote_firewall_reload; then
    bp_zt_rollback_pending "$id" firewall-reload-failed
    return 19
  fi
  bp_zt_pending_owned "$id" || return 24

  if ! bp_zt_interface_health "$device" "$ipv4"; then
    bp_zt_rollback_pending "$id" interface-health-failed
    return 19
  fi
  if ! bp_remote_route_health "$source_ip" "$before_source" "$before_default"; then
    bp_zt_rollback_pending "$id" route-survival-failed
    return 20
  fi
  bp_zt_pending_owned "$id" || return 24

  listener=""
  if [ "$(bp_remote_get management 0)" = 1 ]; then
    admin_port="$(bp_cfg admin_port)"; [ -n "$admin_port" ] || admin_port=8443
    listener="$(printf '%s' "$ipv4" | cut -d/ -f1):$admin_port"
  fi

  network_id="$(bp_zt_get network_id)"
  node_id="$(bp_zt_get node_id)"
  layout="$(bp_zt_get layout)"
  bp_zt_write active "$network_id" "$node_id" "$device" "$ipv4" "$listener" "$(bp_now)" "" "$layout" 0
  bp_zt_applied_profile_set "$(bp_zt_profile_hash)" || {
    bp_zt_rollback_pending "$id" profile-finalize-failed
    return 21
  }
  bp_zt_pending_owned "$id" || return 24

  if ! bp_remote_admin_sync; then
    bp_zt_rollback_pending "$id" admin-listener-failed
    return 21
  fi
  bp_zt_pending_owned "$id" || return 24

  bp_remote_lock || {
    bp_zt_rollback_pending "$id" finalize-lock-failed
    return 24
  }
  if ! bp_zt_pending_owned "$id"; then
    bp_remote_unlock
    return 24
  fi
  bp_zt_pending_clear
  bp_remote_unlock
  return 0
}

bp_zt_disable() {
  source_ip="${1:-}"
  bp_zt_init
  [ ! -e "$BP_ZT_PENDING" ] || return 23

  device="$(bp_zt_get device)"
  bp_zt_source_on_device "$source_ip" "$device" && return 14

  before_default="$(bp_remote_default_signature 2>/dev/null || true)"
  before_source="$(bp_remote_route_signature "$source_ip" 2>/dev/null || true)"
  [ -n "$before_default" ] || return 15

  id="$(date +%Y%m%d%H%M%S)-ztdisable-$(bp_tmp_suffix)"
  bp_remote_lock || return 16
  bp_zt_snapshot_create "$id" || { bp_remote_unlock; return 16; }
  bp_zt_pending_write "$id" disable || { bp_remote_unlock; return 16; }
  bp_remote_unlock
  bp_zt_guard_spawn "$id"

  bp_remote_admin_stop || true
  bp_zt_pending_owned "$id" || return 24

  uci -q delete "network.$BP_ZT_NET_IF" || true
  bp_zt_clear_owned_routes
  uci -q delete "firewall.$BP_ZT_FW_ZONE" || true
  uci -q delete "firewall.$BP_ZT_FW_ADMIN" || true
  uci commit network
  uci commit firewall
  bp_zt_pending_owned "$id" || return 24

  if ! bp_remote_network_reload; then
    bp_zt_rollback_pending "$id" disable-network-reload-failed
    return 18
  fi
  bp_zt_pending_owned "$id" || return 24

  if ! bp_remote_firewall_reload; then
    bp_zt_rollback_pending "$id" disable-firewall-failed
    return 19
  fi
  if ! bp_remote_route_health "$source_ip" "$before_source" "$before_default"; then
    bp_zt_rollback_pending "$id" disable-route-survival-failed
    return 20
  fi
  bp_zt_pending_owned "$id" || return 24

  bp_zt_refresh || true
  network_id="$(bp_zt_get network_id)"
  node_id="$(bp_zt_get node_id)"
  dev="$(bp_zt_get device)"
  ipv4="$(bp_zt_get ipv4)"
  layout="$(bp_zt_get layout)"
  state="$(bp_zt_get state staged)"
  [ "$state" = join_error ] || state=ready
  bp_zt_write "$state" "$network_id" "$node_id" "$dev" "$ipv4" "" 0 "" "$layout" "$(bp_zt_get reboot_required 0)"
  bp_zt_applied_profile_clear
  bp_zt_pending_owned "$id" || return 24

  bp_remote_lock || {
    bp_zt_rollback_pending "$id" disable-finalize-lock-failed
    return 24
  }
  if ! bp_zt_pending_owned "$id"; then
    bp_remote_unlock
    return 24
  fi
  bp_zt_pending_clear
  bp_remote_unlock
  return 0
}

bp_zt_status_json() {
  bp_zt_refresh >/dev/null 2>&1 || true
  if bp_zt_supported; then supported=true; else supported=false; fi
  printf '{"supported":%s,"version":"%s","layout":"%s","state":"%s","network_id":"%s","node_id":"%s","device":"%s","ipv4":"%s","listener":"%s","reboot_required":%s,"last_error":"%s"}'     "$supported" "$(bp_json_escape "$(bp_zt_version)")" "$(bp_json_escape "$(bp_zt_get layout unknown)")"     "$(bp_json_escape "$(bp_zt_get state staged)")" "$(bp_json_escape "$(bp_zt_get network_id)")"     "$(bp_json_escape "$(bp_zt_get node_id)")" "$(bp_json_escape "$(bp_zt_get device)")"     "$(bp_json_escape "$(bp_zt_get ipv4)")" "$(bp_json_escape "$(bp_zt_get listener)")"     "$(bp_zt_get reboot_required 0)" "$(bp_json_escape "$(bp_zt_get last_error)")"
}

# End of BlazePwifi ZeroTier apply engine.
