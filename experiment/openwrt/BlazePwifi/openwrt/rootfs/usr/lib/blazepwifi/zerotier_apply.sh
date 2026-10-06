#!/bin/sh
# BlazePwifi ZeroTier compatibility and activation adapter.
# Prepare/join and live management activation are deliberately separate.

BP_ZT_RUNTIME=${BP_ZT_RUNTIME:-$BP_STATE/zerotier-runtime.tsv}
BP_ZT_CONFIG=${BP_ZT_CONFIG:-/etc/config/zerotier}
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
  [ -x /etc/init.d/zerotier ]
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

bp_zt_configure_uci() {
  network_id="$1"; layout="$(bp_zt_layout)"
  bp_zt_network_id_valid "$network_id" || return 2

  if [ "$layout" = modern ]; then
    uci -q delete zerotier.blazepwifi || true
    uci set zerotier.global=zerotier
    uci set zerotier.global.enabled='1'
    uci set zerotier.blazepwifi=network
    uci set "zerotier.blazepwifi.id=$network_id"
    uci set zerotier.blazepwifi.allow_managed='1'
    uci set zerotier.blazepwifi.allow_global='0'
    uci set zerotier.blazepwifi.allow_default='0'
    uci set zerotier.blazepwifi.allow_dns='0'
  else
    uci -q delete zerotier.blazepwifi || true
    uci set zerotier.blazepwifi=zerotier
    uci set zerotier.blazepwifi.enabled='1'
    uci add_list "zerotier.blazepwifi.join=$network_id"
  fi
  uci commit zerotier
  printf '%s' "$layout"
}

bp_zt_service_restart() {
  if [ -n "${BP_ZT_RESTART_HOOK:-}" ]; then sh -c "$BP_ZT_RESTART_HOOK"; return; fi
  /etc/init.d/zerotier restart >/dev/null 2>&1
}

bp_zt_node_id() {
  zerotier-cli info 2>/dev/null | awk '$1==200 && $2=="info" {print $3; exit}'
}

bp_zt_network_status() {
  network_id="$1"
  status="$(zerotier-cli get "$network_id" status 2>/dev/null | tail -n1 | tr -d '\r' | awk '{print $NF}')"
  case "$status" in OK|ACCESS_DENIED|REQUESTING_CONFIGURATION|NOT_FOUND|PORT_ERROR) printf '%s' "$status"; return 0;; esac
  line="$(zerotier-cli listnetworks 2>/dev/null | grep -i "$network_id" | head -n1 || true)"
  printf '%s\n' "$line" | grep -Eo 'OK|ACCESS_DENIED|REQUESTING_CONFIGURATION|NOT_FOUND|PORT_ERROR' | head -n1
}

bp_zt_device() {
  network_id="$1"
  dev="$(zerotier-cli get "$network_id" portDeviceName 2>/dev/null | tail -n1 | tr -d '\r' | awk '{print $NF}')"
  printf '%s' "$dev" | grep -Eq '^zt[[:alnum:]]{4,15}$' || return 1
  printf '%s' "$dev"
}

bp_zt_ipv4() {
  dev="$1"
  ip -4 addr show dev "$dev" 2>/dev/null | awk '/inet / {sub(/\/.*/,"",$2); print $2; exit}'
}

bp_zt_prepare() {
  [ "$(bp_remote_get mode disabled)" = zerotier ] || return 10
  bp_zt_supported || return 11
  network_id="$(bp_remote_get zt_network_id)"
  bp_zt_network_id_valid "$network_id" || return 12

  layout="$(bp_zt_configure_uci "$network_id")" || return $?
  bp_zt_service_restart || return 13
  sleep "${BP_ZT_SETTLE_SECONDS:-2}"

  node_id="$(bp_zt_node_id)"
  status="$(bp_zt_network_status "$network_id")"
  device="$(bp_zt_device "$network_id" 2>/dev/null || true)"
  ipv4=""; [ -z "$device" ] || ipv4="$(bp_zt_ipv4 "$device")"

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
  node_id="$(bp_zt_node_id)"
  status="$(bp_zt_network_status "$network_id")"
  device="$(bp_zt_device "$network_id" 2>/dev/null || true)"
  ipv4=""; [ -z "$device" ] || ipv4="$(bp_zt_ipv4 "$device")"
  listener="$(bp_zt_get listener)"
  applied_at="$(bp_zt_get applied_at 0)"
  prior="$(bp_zt_get state staged)"

  state="$prior"; reboot_required=0; error=""
  case "$status" in
    OK)
      if [ -z "$device" ]; then state=reboot_required; reboot_required=1
      elif [ -z "$ipv4" ]; then state=awaiting_address
      else
        case "$prior" in active|active_staged_changes) state="$prior";; *) state=ready;; esac
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
  case "$sig" in *"dev=$device"*) return 0;; *) return 1;; esac
}

bp_zt_snapshot_create() {
  id="$1"; snap="$BP_REMOTE_APPLY_ROOT/snapshots/$id"
  mkdir -p "$snap"; chmod 700 "$snap"
  for pair in "network:$BP_REMOTE_NETWORK_CONFIG" "firewall:$BP_REMOTE_FIREWALL_CONFIG" "ztruntime:$BP_ZT_RUNTIME"; do
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
  bp_remote_network_reload || return 1
  bp_remote_firewall_reload || return 1
  bp_remote_admin_sync || return 1
}

bp_zt_write_network_firewall() {
  device="$1"; management="$(bp_remote_get management 0)"; allowlist="$(bp_remote_get source_allowlist)"
  admin_port="$(bp_cfg admin_port)"; [ -n "$admin_port" ] || admin_port=8443

  uci -q delete "network.$BP_ZT_NET_IF" || true
  uci set "network.$BP_ZT_NET_IF=interface"
  uci set "network.$BP_ZT_NET_IF.proto=none"
  uci set "network.$BP_ZT_NET_IF.device=$device"

  uci -q delete "firewall.$BP_ZT_FW_ZONE" || true
  uci -q delete "firewall.$BP_ZT_FW_ADMIN" || true
  uci set "firewall.$BP_ZT_FW_ZONE=zone"
  uci set "firewall.$BP_ZT_FW_ZONE.name=$BP_ZT_FW_ZONE"
  uci set "firewall.$BP_ZT_FW_ZONE.input=REJECT"
  uci set "firewall.$BP_ZT_FW_ZONE.output=ACCEPT"
  uci set "firewall.$BP_ZT_FW_ZONE.forward=REJECT"
  uci add_list "firewall.$BP_ZT_FW_ZONE.network=$BP_ZT_NET_IF"

  if [ "$management" = 1 ]; then
    [ -n "$allowlist" ] || return 2
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

bp_zt_activate() {
  source_ip="${1:-}"
  [ "$(bp_remote_get mode disabled)" = zerotier ] || return 10
  bp_zt_supported || return 11
  bp_zt_refresh || return 12
  state="$(bp_zt_get state)"
  [ "$state" = ready ] || [ "$state" = active_staged_changes ] || return 13
  device="$(bp_zt_get device)"; ipv4="$(bp_zt_get ipv4)"
  [ -n "$device" ] && [ -n "$ipv4" ] || return 13
  bp_zt_source_on_device "$source_ip" "$device" && return 14

  before_default="$(bp_remote_default_signature 2>/dev/null || true)"
  before_source="$(bp_remote_route_signature "$source_ip" 2>/dev/null || true)"
  [ -n "$before_default" ] || return 15

  id="$(date +%Y%m%d%H%M%S)-zt-$(bp_tmp_suffix)"
  bp_remote_lock || return 16
  bp_zt_snapshot_create "$id" || { bp_remote_unlock; return 16; }
  bp_remote_unlock

  if ! bp_zt_write_network_firewall "$device"; then bp_zt_restore_snapshot "$id"; return 17; fi
  if ! bp_remote_network_reload; then bp_zt_restore_snapshot "$id"; return 18; fi
  if ! bp_remote_firewall_reload; then bp_zt_restore_snapshot "$id"; return 19; fi
  if ! bp_remote_route_health "$source_ip" "$before_source" "$before_default"; then bp_zt_restore_snapshot "$id"; return 20; fi

  listener=""
  if [ "$(bp_remote_get management 0)" = 1 ]; then
    admin_port="$(bp_cfg admin_port)"; [ -n "$admin_port" ] || admin_port=8443
    listener="$ipv4:$admin_port"
  fi
  network_id="$(bp_zt_get network_id)"; node_id="$(bp_zt_get node_id)"; layout="$(bp_zt_get layout)"
  bp_zt_write active "$network_id" "$node_id" "$device" "$ipv4" "$listener" "$(bp_now)" "" "$layout" 0
  if ! bp_remote_admin_sync; then bp_zt_restore_snapshot "$id"; return 21; fi
  return 0
}

bp_zt_disable() {
  source_ip="${1:-}"
  bp_zt_init
  device="$(bp_zt_get device)"
  bp_zt_source_on_device "$source_ip" "$device" && return 14

  before_default="$(bp_remote_default_signature 2>/dev/null || true)"
  before_source="$(bp_remote_route_signature "$source_ip" 2>/dev/null || true)"
  [ -n "$before_default" ] || return 15
  id="$(date +%Y%m%d%H%M%S)-ztdisable-$(bp_tmp_suffix)"
  bp_remote_lock || return 16
  bp_zt_snapshot_create "$id" || { bp_remote_unlock; return 16; }
  bp_remote_unlock

  bp_remote_admin_stop || true
  uci -q delete "network.$BP_ZT_NET_IF" || true
  uci -q delete "firewall.$BP_ZT_FW_ZONE" || true
  uci -q delete "firewall.$BP_ZT_FW_ADMIN" || true
  uci commit network
  uci commit firewall
  if ! bp_remote_network_reload; then bp_zt_restore_snapshot "$id"; return 18; fi
  if ! bp_remote_firewall_reload; then bp_zt_restore_snapshot "$id"; return 19; fi
  if ! bp_remote_route_health "$source_ip" "$before_source" "$before_default"; then bp_zt_restore_snapshot "$id"; return 20; fi

  bp_zt_refresh || true
  network_id="$(bp_zt_get network_id)"; node_id="$(bp_zt_get node_id)"; dev="$(bp_zt_get device)"
  ipv4="$(bp_zt_get ipv4)"; layout="$(bp_zt_get layout)"; state="$(bp_zt_get state staged)"
  [ "$state" = join_error ] || state=ready
  bp_zt_write "$state" "$network_id" "$node_id" "$dev" "$ipv4" "" 0 "" "$layout" "$(bp_zt_get reboot_required 0)"
}

bp_zt_status_json() {
  bp_zt_refresh >/dev/null 2>&1 || true
  if bp_zt_supported; then supported=true; else supported=false; fi
  printf '{"supported":%s,"version":"%s","layout":"%s","state":"%s","network_id":"%s","node_id":"%s","device":"%s","ipv4":"%s","listener":"%s","reboot_required":%s,"last_error":"%s"}' \
    "$supported" "$(bp_json_escape "$(bp_zt_version)")" "$(bp_json_escape "$(bp_zt_get layout unknown)")" \
    "$(bp_json_escape "$(bp_zt_get state staged)")" "$(bp_json_escape "$(bp_zt_get network_id)")" \
    "$(bp_json_escape "$(bp_zt_get node_id)")" "$(bp_json_escape "$(bp_zt_get device)")" \
    "$(bp_json_escape "$(bp_zt_get ipv4)")" "$(bp_json_escape "$(bp_zt_get listener)")" \
    "$(bp_zt_get reboot_required 0)" "$(bp_json_escape "$(bp_zt_get last_error)")"
}
