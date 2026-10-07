#!/bin/sh
set -eu

ROOT="$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)"
WF="$ROOT/../../../.github/workflows/blazepwifi-build.yml"
SIGN="$ROOT/../../../.github/workflows/blazerental-v053-lineage2-sign.yml"
RELEASE="$ROOT/../../../.github/workflows/blazepwifi-v053-release.yml"
GRADLE="$ROOT/android/BlazeRentalLauncher/build.gradle"
NOTES="$ROOT/releases/0.5.3/README.md"
BOOTSTRAP="$ROOT/tools/BlazePwifi-v0.5.3-update-bootstrap.sh"
RECOVERY="$ROOT/SIGNING_RECOVERY.md"
EXPECTED='1A:18:D5:8E:1F:95:55:96:89:10:20:71:F5:6C:93:E9:B9:D2:EA:6B:E4:0E:6F:20:70:06:C9:89:62:A1:6A:25'

[ "$(cat "$ROOT/VERSION")" = "0.5.3" ]
grep -Fq 'versionCode 50300' "$GRADLE"
grep -Fq 'versionName "0.5.3"' "$GRADLE"

test -s "$NOTES"
grep -Fq 'BlazePwifi v0.5.3' "$NOTES"
grep -Fq 'versionCode: **50300**' "$NOTES"
grep -Fq 'rescue versionCode: **50301**' "$NOTES"
grep -Fq "$EXPECTED" "$NOTES"

test -s "$BOOTSTRAP"
grep -Fq 'BlazePwifi-v0.5.3-update-bootstrap.sh' "$BOOTSTRAP"
grep -Fq 'BlazePwifi v0.5.3 update staged successfully' "$BOOTSTRAP"

# Build workflow must keep dev rescue at 50299 but raise final production rescue above 50300.
grep -Fq '0.5.3) RESCUE_CODE=50301' "$WF"
grep -Fq '*) RESCUE_CODE=50299' "$WF"
grep -Fq 'sed -i "s/versionCode 50200/versionCode $RESCUE_CODE/"' "$WF"
grep -Fq '0.5.3) BOOTSTRAP="BlazePwifi-v0.5.3-update-bootstrap.sh"' "$WF"
grep -Fq 'BlazeRental-v0.5.2-rescue-for-$VERSION-release-unsigned.apk' "$WF"

# Future signing must recover permanent Lineage 2; it must never mint a replacement key.
test -s "$SIGN"
grep -Fq 'BLAZERENTAL_LINEAGE2_RECOVERY_PRIVATE_KEY_PEM' "$SIGN"
grep -Fq 'BlazeRental-v0.5.2-lineage2-signing-backup.enc' "$SIGN"
grep -Fq 'unseal-blazerental-lineage2.py' "$SIGN"
grep -Fq "$EXPECTED" "$SIGN"
grep -Fq "versionCode='50300' versionName='0.5.3'" "$SIGN"
grep -Fq "versionCode='50301' versionName='0.5.2-rescue-for-0.5.3'" "$SIGN"
grep -Fq 'BlazeRental-production-lineage2' "$SIGN"
! grep -Fq 'keytool -genkeypair' "$SIGN"
! grep -Fq 'openssl genrsa' "$SIGN"
! grep -Fq 'openssl genpkey' "$SIGN"
[ "$(grep -Fc 'name: BlazeRental v0.5.3 production Lineage 2 sign' "$SIGN")" -eq 1 ]
[ "$(grep -Fc 'Recover exact Lineage 2 signer and verify identity' "$SIGN")" -eq 1 ]
[ "$(grep -Fc '# End of BlazeRental v0.5.3 Lineage-2 signing workflow.' "$SIGN")" -eq 1 ]
[ "$(tail -n 1 "$SIGN")" = '# End of BlazeRental v0.5.3 Lineage-2 signing workflow.' ]

# Production release requires signing and derives provisioning checksum from signed BlazeRental.apk.
test -s "$RELEASE"
grep -Fq 'signing_run_id:' "$RELEASE"
grep -Fq 'BlazeRental-v0.5.3-production-signed' "$RELEASE"
grep -Fq -- '--apk release-out/BlazeRental.apk' "$RELEASE"
grep -Fq '/releases/download/v0.5.3/BlazeRental.apk' "$RELEASE"
grep -Fq 'PROVISIONING_DEVICE_ADMIN_PACKAGE_CHECKSUM' "$RELEASE"
grep -Fq 'provisioning_generated_from_signed_apk:true' "$RELEASE"
grep -Fq 'different target; refusing retag/retarget' "$RELEASE"
grep -Fq "$EXPECTED" "$RELEASE"

# Permanent v0.5.2 Lineage-2 recovery entry point remains authoritative.
test -s "$RECOVERY"
grep -Fq 'BlazeRental-production-lineage2' "$RECOVERY"
grep -Fq "$EXPECTED" "$RECOVERY"

echo "v0.5.3 production identity/signing/release contracts passed"
