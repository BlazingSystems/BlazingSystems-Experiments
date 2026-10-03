#!/bin/sh
BP_STATE=${BP_STATE:-/etc/blazepwifi/state}; BP_RUN=${BP_RUN:-/tmp/blazepwifi}
BP_CREDITS="$BP_STATE/credits.tsv"; BP_SESSIONS="$BP_STATE/sessions.tsv"; BP_VOUCHERS="$BP_STATE/vouchers.tsv"; BP_VENDOS="$BP_RUN/vendos.tsv"; BP_TARGET="$BP_RUN/coin-target.tsv"
BP_POST_BODY=""; [ "${REQUEST_METHOD:-GET}" = POST ] && IFS= read -r BP_POST_BODY || true
bp_cfg(){ uci -q get "blazepwifi.main.$1"; }; bp_now(){ date +%s; }
bp_json_escape(){ printf '%s' "$1"|sed 's/\/\\/g;s/"/\"/g'; }; bp_json(){ printf 'Content-Type: application/json\r\nCache-Control: no-store\r\n\r\n%s\n' "$1"; }; bp_fail(){ bp_json "{\"ok\":false,\"error\":\"$(bp_json_escape "$1")\"}"; exit 0; }
bp_init_dirs(){ mkdir -p "$BP_STATE" "$BP_RUN"; chmod 700 "$BP_STATE" "$BP_RUN"; touch "$BP_CREDITS" "$BP_SESSIONS" "$BP_VOUCHERS" "$BP_VENDOS"; chmod 600 "$BP_CREDITS" "$BP_SESSIONS" "$BP_VOUCHERS" "$BP_VENDOS"; }
bp_lock(){ i=0; while ! mkdir "$BP_RUN/lock" 2>/dev/null; do i=$((i+1)); [ "$i" -gt 40 ]&&return 1; sleep 0.05 2>/dev/null||sleep 1; done; }; bp_unlock(){ rmdir "$BP_RUN/lock" 2>/dev/null||true; }
bp_mac_norm(){ printf '%s' "$1"|tr 'A-F' 'a-f'|grep -Eq '^[0-9a-f]{2}(:[0-9a-f]{2}){5}$'||return 1; printf '%s' "$1"|tr 'A-F' 'a-f'; }
bp_mac_for_ip(){ ipaddr="$1"; lan_if="$(bp_cfg lan_if)"; [ -n "$lan_if" ]||lan_if=br-lan; m="$(ip neigh show "$ipaddr" dev "$lan_if" 2>/dev/null|awk '/lladdr/{print $5;exit}')"; [ -n "$m" ]||m="$(awk -v ip="$ipaddr" '$3==ip{print $2;exit}' /tmp/dhcp.leases 2>/dev/null)"; bp_mac_norm "$m" 2>/dev/null; }
bp_param(){ key="$1"; data="${QUERY_STRING:-}"; [ "${REQUEST_METHOD:-GET}" = POST ]&&data="$BP_POST_BODY"; printf '%s' "$data"|tr '&' '\n'|awk -F= -v k="$key" '$1==k{sub(/^[^=]*=/,"");gsub(/\+/," ");print;exit}'; }
bp_get_credit(){ awk -F '\t' -v m="$1" '$1==m{v=$2}END{print v+0}' "$BP_CREDITS"; }
bp_set_credit(){ mac="$1";v="$2";tmp="$BP_RUN/c.$$";awk -F '\t' -v OFS='\t' -v m="$mac" -v v="$v" 'BEGIN{f=0}$1==m{$2=v;f=1}{print}END{if(!f)print m,v}' "$BP_CREDITS">"$tmp"&&mv "$tmp" "$BP_CREDITS"; }
bp_add_credit(){ bp_lock||return 1; old="$(bp_get_credit "$1")";new=$((old+$2));bp_set_credit "$1" "$new";bp_unlock;printf '%s' "$new"; }
bp_get_session_expiry(){ awk -F '\t' -v m="$1" '$1==m{v=$2}END{print v+0}' "$BP_SESSIONS"; }
bp_set_session(){ mac="$1";e="$2";ip="$3";tmp="$BP_RUN/s.$$";awk -F '\t' -v OFS='\t' -v m="$mac" -v e="$e" -v ip="$ip" 'BEGIN{f=0}$1==m{$2=e;$3=ip;f=1}{print}END{if(!f)print m,e,ip}' "$BP_SESSIONS">"$tmp"&&mv "$tmp" "$BP_SESSIONS"; }
bp_authorize_mac(){ nft add element inet blazepwifi auth_macs "{ $1 }" 2>/dev/null||true; }; bp_deauthorize_mac(){ nft delete element inet blazepwifi auth_macs "{ $1 }" 2>/dev/null||true; }
bp_rate_seconds(){ want="$1";for s in $(uci -q show blazepwifi|sed -n 's/^blazepwifi\.\([^.=]*\)=rate$/\1/p');do c="$(uci -q get blazepwifi.$s.cents)";[ "$c" = "$want" ]&&{ uci -q get blazepwifi.$s.seconds;return;};done;return 1; }
bp_rates_json(){ first=1;printf '[';for s in $(uci -q show blazepwifi|sed -n 's/^blazepwifi\.\([^.=]*\)=rate$/\1/p');do c="$(uci -q get blazepwifi.$s.cents)";sec="$(uci -q get blazepwifi.$s.seconds)";label="$(uci -q get blazepwifi.$s.label)";[ "$first" = 1 ]||printf ',';first=0;printf '{"cents":%s,"seconds":%s,"label":"%s"}' "${c:-0}" "${sec:-0}" "$(bp_json_escape "$label")";done;printf ']'; }
bp_check_admin(){ [ -n "${HTTP_X_BLAZE_ADMIN:-}" ]&&[ "$HTTP_X_BLAZE_ADMIN" = "$(bp_cfg admin_key)" ]; }
bp_sha256(){ sha256sum|awk '{print $1}'; }
bp_vendo_sig_expected(){ secret="$(bp_cfg vendo_key)";printf '%s|%s|%s|%s|%s|%s|%s|%s' "$secret" "$1" "$2" "$3" "$4" "$5" "$6" "$secret"|bp_sha256; }
bp_check_vendo_sig(){ exp="$(bp_vendo_sig_expected "$1" "$2" "$3" "$4" "$5" "$6")"; [ -n "$7" ]&&[ "$7" = "$exp" ]; }
