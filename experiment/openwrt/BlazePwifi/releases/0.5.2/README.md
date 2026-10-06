# BlazePwifi v0.5.2 — LCM Branding & Rental Time Alarms

BlazePwifi v0.5.2 is a maintenance and production-readiness release built from the exact validated candidate `bf2992977fe8504d21b107df02826032c31d3a62`.

## BlazeRental changes

- Production branding now uses the supplied **LCM** artwork for the BlazeRental app icon and native admin/setup branding.
- BlazeRental version: **0.5.2**
- Android versionCode: **50200**
- The release keeps the Launcher3-based rental gate, Device Owner provisioning, daily-driver mode, Notifications/Clear All, app allow/hide policy, managed updates, and rollback recovery from v0.5.1.

## Rental time alarms

BlazeRental now has three configurable on-device rental alarms:

1. **Near End**
   - default trigger: **10 minutes remaining**
   - default ring duration: **5 seconds**
2. **Urgent Add Credit**
   - default trigger: **3 minutes remaining**
   - default ring duration: **10 seconds**
3. **Time's Up**
   - trigger: **00:00**
   - default ring duration: **15 seconds**

The Admin console can configure trigger thresholds, ring duration, forced minimum alarm volume, and sound source.

Sound sources:
- built-in BlazeRental alarm;
- Android device alarm tones;
- custom local audio file.

The Android alarm picker explicitly disables the Silent choice.

### Audible-alarm behavior

Rental alerts use Android's **ALARM** audio stream, not ordinary media volume. While an alarm is active, BlazeRental repeatedly enforces the configured non-zero minimum alarm volume so volume-down cannot reduce that active alarm to zero. The previous alarm/ringer state is restored after the configured ring duration.

For Android/OEM **Total Silence / Do Not Disturb** modes, the on-device admin exposes **Grant DND Alarm Override**. When Android grants Notification Policy access, BlazeRental temporarily permits interruptions during the rental alarm and restores the previous interruption filter afterward.

No Android application can honestly guarantee an audible alarm against every vendor-specific firmware, powered-off device, broken speaker, or policy that the OS refuses to let it override. v0.5.2 therefore uses the strongest supported Android alarm/DND path instead of bypassing the OS.

Alarms fire once per credit/lease session and automatically re-arm when credit extends the lease. Time's Up also reapplies the rental gate for managed rental mode.

## No-reflash update path

The v0.5.1 transactional update architecture remains intact:
- verified overlay update bundles;
- exact SHA-256 verification;
- last-known-good snapshot;
- automatic health rollback;
- boot health guard;
- manual rollback;
- configurable stability grace and retention.

Existing compatible installations can use the v0.5.2 update bundle instead of a full firmware reflash. Kernel/bootloader/partition/base-OS changes still require the appropriate full image update.

## Android rollback rescue

The build includes an exact known-good **v0.5.1 rescue** source with only Android recovery version metadata raised to allow PackageInstaller recovery from v0.5.2.

Initial prerelease Android assets are intentionally:
- `BlazeRental-v0.5.2-TEST.apk`
- `BlazeRental-v0.5.2-release-unsigned.apk`
- `BlazeRental-v0.5.1-rescue-for-v0.5.2-TEST.apk`
- `BlazeRental-v0.5.1-rescue-for-v0.5.2-release-unsigned.apk`

Production signing is a **separate step after this release**. Older 0.5.1 APKs are not being newly production-signed.

## Validation

Exact candidate build run: `37443570618`

Required gates include:
- static/security/config/integration/stress validation;
- v0.3/v0.4/v0.5 compatibility contracts;
- v0.5.2 alarm and LCM branding source contract;
- PNG structure/CRC validation of the LCM production artwork;
- BlazeRental normal + rescue APK build;
- Android Device Owner emulator;
- browser simulation;
- ESP8266/ESP32 builds and simulations;
- Ruijie build/simulation;
- x86 build/QEMU simulation;
- required Orange Pi builds/simulations;
- final v0.5.2 candidate gate.

## Signing state

This first v0.5.2 publication is intentionally a **prerelease** and does not claim production Android signing. A new permanent production signing lineage, with proper external recovery storage, will be handled only after the unsigned/test v0.5.2 release is frozen and verified.
