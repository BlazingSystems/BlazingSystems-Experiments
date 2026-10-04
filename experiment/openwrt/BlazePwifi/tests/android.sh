#!/bin/sh
set -eu
ROOT="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
A="$ROOT/android/BlazeRental"
[ -f "$A/app/src/main/AndroidManifest.xml" ]
grep -q 'com.blazesystems.blazerental' "$A/app/build.gradle"
grep -q 'BIND_DEVICE_ADMIN' "$A/app/src/main/AndroidManifest.xml"
grep -q 'PROFILE_PROVISIONING_COMPLETE' "$A/app/src/main/AndroidManifest.xml"
grep -q 'CATEGORY.HOME' "$A/app/src/main/java/com/blazesystems/blazerental/Policy.java"
grep -q 'setLockTaskPackages' "$A/app/src/main/java/com/blazesystems/blazerental/Policy.java"
grep -q 'isDeviceOwnerApp' "$A/app/src/main/java/com/blazesystems/blazerental/Policy.java"
grep -q 'elapsedRealtime' "$A/app/src/main/java/com/blazesystems/blazerental/LeaseStore.java"
grep -q 'Manual APK' "$A/app/src/main/java/com/blazesystems/blazerental/MainActivity.java"
echo "BlazeRental source gates passed"
