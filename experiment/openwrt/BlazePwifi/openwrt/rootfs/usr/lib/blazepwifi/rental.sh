#!/bin/sh
BP_RENTAL_DEVICES="${BP_RENTAL_DEVICES:-$BP_STATE/rental-devices.tsv}"
BP_RENTAL_ENROLL="${BP_RENTAL_ENROLL:-$BP_STATE/rental-enroll.tsv}"

bp_rental_init() {
  bp_init_dirs
  touch "$BP_RENTAL_DEVICES" "$BP_RENTAL_ENROLL"
  chmod 600 "$BP_RENTAL_DEVICES" "$BP_RENTAL_ENROLL"
}

bp_rental_clean() { printf '%s' "$1" | tr '\t\r\n' '   '; }
bp_rental_hex() { bp_auth_random_hex "$1"; }

bp_rental_hmac() {
  secret="$1"; data="$2"
  if command -v openssl >/dev/null 2>&1; then
    printf '%s' "$data" | openssl dgst -sha256 -hmac "$secret" 2>/dev/null | awk '{print $NF}'
  else
    # Portable keyed construction used consistently by the Android client/server
    # only when openssl HMAC is unavailable. The device secret remains required.
    printf '%s|%s|%s' "$secret" "$data" "$secret" | bp_sha256
  fi
}

bp_rental_enroll_create() {
  label="$(bp_rental_clean "$1")"; ttl="${2:-600}"; now="$(bp_now)"
  case "$ttl" in ''|*[!0-9]*) ttl=600;; esac
  [ "$ttl" -ge 60 ] && [ "$ttl" -le 3600 ] || ttl=600
  id="$(bp_rental_hex 6)"; secret="$(bp_rental_hex 18)"; token="$id.$secret"; expiry=$((now+ttl))
  printf '%s\t%s\t%s\t%s\n' "$id" "$secret" "$expiry" "$label" >> "$BP_RENTAL_ENROLL"
  chmod 600 "$BP_RENTAL_ENROLL"; bp_durable_sync
  printf '%s\n' "$token"
}

bp_rental_enroll_lookup() {
  awk -F '\t' -v i="$1" '$1==i {print; exit}' "$BP_RENTAL_ENROLL"
}

bp_rental_enroll_consume() {
  id="$1"; tmp="$BP_STATE/.rental-enroll.$(bp_tmp_suffix)"
  awk -F '\t' -v i="$id" '$1!=i {print}' "$BP_RENTAL_ENROLL" > "$tmp" &&
    chmod 600 "$tmp" && mv "$tmp" "$BP_RENTAL_ENROLL"
}

bp_rental_device_line() {
  awk -F '\t' -v d="$1" '$1==d {print; exit}' "$BP_RENTAL_DEVICES"
}

bp_rental_device_write() {
  id="$1"; secret="$2"; lease="$3"; label="$4"; last="$5"
  tmp="$BP_STATE/.rental-devices.$(bp_tmp_suffix)"
  awk -F '\t' -v OFS='\t' -v d="$id" '$1!=d {print}' "$BP_RENTAL_DEVICES" > "$tmp"
  printf '%s\t%s\t%s\t%s\t%s\n' "$id" "$secret" "$lease" "$(bp_rental_clean "$label")" "$last" >> "$tmp"
  chmod 600 "$tmp" && mv "$tmp" "$BP_RENTAL_DEVICES"; bp_durable_sync
}

bp_rental_list_json() {
  first=1; printf '['
  while IFS="$(printf '\t')" read -r id secret lease label last; do
    [ -n "$id" ] || continue
    [ "$first" = 1 ] || printf ','; first=0
    printf '{"device_id":"%s","label":"%s","lease_until":%s,"last_seen":%s}'       "$(bp_json_escape "$id")" "$(bp_json_escape "$label")" "${lease:-0}" "${last:-0}"
  done < "$BP_RENTAL_DEVICES"
  printf ']'
}
