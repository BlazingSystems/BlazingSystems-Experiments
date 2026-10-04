#!/bin/sh
set -eu
ROOT="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
L="$ROOT/android/BlazeRentalLauncher"
N="$L/src/com/google/android/apps/nexuslauncher/NexusLauncherActivity.java"
M="$L/src/com/blazesystems/blazerental/ManagedPolicyController.java"
A="$L/src/com/blazesystems/blazerental/BlazeAdminActivity.java"

grep -Fq 'ManagedPolicyController.enforceLauncherTask(this);' "$N"
grep -Fq 'setUninstallBlocked(admin, context.getPackageName(), true)' "$M"
grep -Fq 'TRANSFER TO ANOTHER SERVER / RUN INITIAL SETUP' "$A"
grep -Fq 'SAVE APP ALLOW / HIDE POLICY' "$A"
grep -Fq 'InitialSetupPolicy' "$L/tests/unit/com/blazesystems/blazerental/InitialSetupPolicyTest.java"
echo "v0.4 Android source contract passed"
