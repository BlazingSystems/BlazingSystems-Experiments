#!/bin/sh

BP_STATE=${BP_STATE:-/etc/blazepwifi/state}
BP_RUN=${BP_RUN:-/tmp/blazepwifi}
BP_CREDITS="$BP_STATE/credits.tsv"
BP_SESSIONS="$BP_STATE/sessions.tsv"
BP_VENDOS="$BP_STATE/vendos.tsv"
BP_TARGET="$BP_RUN/coin-target.tsv"
BP_VOUCHERS="$BP_STATE/vouchers.tsv"
BP_POST_BODY_SET=0
BP_POST_BODY=""
if [ "${REQUEST_METHOD:-GET}" = POST ]; then IFS= read -r BP_POST_BODY; BP_POST_BODY_SET=1; fi

bp_cfg() { uci -q get "blazepwifi.main.$1"; }
bp_now() { date +%s; }
bp_json_escape() { printf '%s' "$1" | sed 's/\\/\\\\/g; s/"/\\"/g'; }
bp_json() { printf 'Content-Type: application/json\r\nCache-Control: no-store\r\n\r\n%s\n' "$1"; }
bp_fail() { bp_json "{\"ok\":false,\"error\":\"$(bp_json_escape "$1")\"}"; exit 0; }

bp_init_dirs() {
	mkdir -p "$BP_STATE" "$BP_RUN"
	chmod 700 "$BP_STATE" "$BP_RUN"
	touch "$BP_CREDITS" "$BP_SESSIONS" "$BP_VENDOS" "$BP_VOUCHERS"
	chmod 600 "$BP_CREDITS" "$BP_SESSIONS" "$BP_VENDOS" "$BP_VOUCHERS"
}

bp_lock() {
	i=0
	while ! mkdir "$BP_RUN/lock" 2>/dev/null; do
		i=$((i+1)); [ "$i" -gt 40 ] && return 1; usleep 50000 2>/dev/null || sleep 1
	done
}
bp_unlock() { rmdir "$BP_RUN/lock" 2>/dev/null || true; }

bp_mac_norm() {
	printf '%s' "$1" | tr 'A-F' 'a-f' | grep -Eq '^[0-9a-f]{2}(:[0-9a-f]{2}){5}$' || return 1
	printf '%s' "$1" | tr 'A-F' 'a-f'
}

bp_mac_for_ip() {
	ipaddr="$1"; lan_if="$(bp_cfg lan_if)"; [ -n "$lan_if" ] || lan_if=br-lan
	ip neigh show "$ipaddr" dev "$lan_if" 2>/dev/null | awk '/lladdr/ {print $5; exit}' | tr 'A-F' 'a-f'
}

bp_param() {
	key="$1"; data="${QUERY_STRING:-}"
	[ "${REQUEST_METHOD:-GET}" = POST ] && data="$BP_POST_BODY"
	printf '%s' "$data" | tr '&' '\n' | awk -F= -v k="$key" '$1==k {sub(/^[^=]*=/,""); gsub(/\+/," "); print; exit}'
}

bp_get_credit() {
	mac="$1"; awk -F '\t' -v m="$mac" '$1==m {v=$2} END {print v+0}' "$BP_CREDITS"
}

bp_set_credit() {
	mac="$1"; value="$2"; tmp="$BP_RUN/credits.$$"
	awk -F '\t' -v OFS='\t' -v m="$mac" -v v="$value" 'BEGIN{f=0} $1==m {$2=v;f=1} {print} END{if(!f) print m,v}' "$BP_CREDITS" > "$tmp" && mv "$tmp" "$BP_CREDITS"
}

bp_add_credit() {
	mac="$1"; add="$2"; bp_lock || return 1
	old="$(bp_get_credit "$mac")"; new=$((old+add)); bp_set_credit "$mac" "$new"; bp_unlock
	printf '%s' "$new"
}

bp_get_session_expiry() {
	mac="$1"; awk -F '\t' -v m="$mac" '$1==m {v=$2} END {print v+0}' "$BP_SESSIONS"
}

bp_set_session() {
	mac="$1"; expiry="$2"; ipaddr="$3"; tmp="$BP_RUN/sessions.$$"
	awk -F '\t' -v OFS='\t' -v m="$mac" -v e="$expiry" -v ip="$ipaddr" 'BEGIN{f=0} $1==m {$2=e;$3=ip;f=1} {print} END{if(!f) print m,e,ip}' "$BP_SESSIONS" > "$tmp" && mv "$tmp" "$BP_SESSIONS"
}

bp_authorize_mac() { nft add element inet blazepwifi auth_macs "{ $1 }" 2>/dev/null || true; }
bp_deauthorize_mac() { nft delete element inet blazepwifi auth_macs "{ $1 }" 2>/dev/null || true; }

bp_rate_seconds() {
	want="$1"
	for s in $(uci -q show blazepwifi | sed -n "s/^blazepwifi\.\([^.=]*\)=rate$/\1/p"); do
		c="$(uci -q get blazepwifi.$s.cents)"; [ "$c" = "$want" ] && { uci -q get blazepwifi.$s.seconds; return; }
	done
	return 1
}
bp_rates_json() {
	first=1; printf '['
	for s in $(uci -q show blazepwifi | sed -n "s/^blazepwifi\.\([^.=]*\)=rate$/\1/p"); do
		c="$(uci -q get blazepwifi.$s.cents)"; sec="$(uci -q get blazepwifi.$s.seconds)"; label="$(uci -q get blazepwifi.$s.label)"
		[ "$first" = 1 ] || printf ','; first=0
		printf '{"cents":%s,"seconds":%s,"label":"%s"}' "${c:-0}" "${sec:-0}" "$(bp_json_escape "$label")"
	done
	printf ']'
}

bp_check_admin() { [ "${HTTP_X_BLAZE_ADMIN:-$(bp_param key)}" = "$(bp_cfg admin_key)" ]; }
bp_sha256() { sha256sum | awk '{print $1}'; }
bp_vendo_sig_expected() {
	action="$1"; id="$2"; nonce="$3"; pulses="$4"; secret="$(bp_cfg vendo_key)"
	printf '%s|%s|%s|%s|%s|%s' "$secret" "$action" "$id" "$nonce" "$pulses" "$secret" | bp_sha256
}
bp_check_vendo_sig() {
	action="$1"; id="$2"; nonce="$3"; pulses="$4"; got="$5"
	[ -n "$nonce" ] && [ -n "$got" ] || return 1
	exp="$(bp_vendo_sig_expected "$action" "$id" "$nonce" "$pulses")"
	[ "$got" = "$exp" ]
}
