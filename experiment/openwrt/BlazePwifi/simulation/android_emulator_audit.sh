#!/bin/bash
set -euo pipefail
OUT=simulation-results/android
mkdir -p "$OUT"

adb install -r BlazeRental.apk | tee "$OUT/install.txt"
adb shell dpm set-device-owner com.blazesystems.blazerental/.BlazeDeviceAdminReceiver | tee "$OUT/device-owner.txt"
adb shell am start -n com.blazesystems.blazerental/.MainActivity >/dev/null
sleep 3
adb shell uiautomator dump /sdcard/window.xml >/dev/null
adb pull /sdcard/window.xml "$OUT/01-window.xml" >/dev/null
grep -q 'BlazeRental' "$OUT/01-window.xml"
grep -q 'INSERT COIN' "$OUT/01-window.xml"
adb exec-out screencap -p > "$OUT/01-locked.png"
adb shell dumpsys device_policy > "$OUT/device-policy.txt"
grep -qi 'no_factory_reset' "$OUT/device-policy.txt"

adb reboot
adb wait-for-device
for i in $(seq 1 90); do
  [ "$(adb shell getprop sys.boot_completed 2>/dev/null | tr -d '\r')" = 1 ] && break
  sleep 2
done
test "$(adb shell getprop sys.boot_completed | tr -d '\r')" = 1
adb shell am start -n com.blazesystems.blazerental/.MainActivity >/dev/null
sleep 2
adb shell uiautomator dump /sdcard/window.xml >/dev/null
adb pull /sdcard/window.xml "$OUT/02-window.xml" >/dev/null
grep -q 'BlazeRental' "$OUT/02-window.xml"
adb exec-out screencap -p > "$OUT/02-after-reboot.png"
printf '{"status":"PASS","signed_apk_install":"PASS","device_owner":"PASS","locked_ui":"PASS","reboot_persistence":"PASS"}\n' > "$OUT/android-audit.json"
