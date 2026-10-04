package com.blazesystems.blazerental;

import android.content.Context;
import android.content.SharedPreferences;
import android.os.Build;
import android.os.PersistableBundle;
import android.os.SystemClock;

public final class RentalLeaseStore {
    private static final String PREFS = "blaze_rental_v04";
    private RentalLeaseStore() {}

    private static Context storage(Context context) {
        return Build.VERSION.SDK_INT >= 24
                ? context.createDeviceProtectedStorageContext() : context;
    }

    private static SharedPreferences prefs(Context context) {
        return storage(context).getSharedPreferences(PREFS, Context.MODE_PRIVATE);
    }

    public static void acceptProvisioningExtras(Context context, PersistableBundle extras) {
        if (extras == null) return;
        prefs(context).edit()
                .putString("server", safe(extras.getString("server_url")))
                .putString("enrollment", safe(extras.getString("enrollment_token")))
                .putString("device_name", safe(extras.getString("device_name")))
                .apply();
    }

    public static void saveManualEnrollment(Context context, String server, String token, String name) {
        prefs(context).edit()
                .putString("server", safe(server))
                .putString("enrollment", safe(token))
                .putString("device_name", safe(name))
                .remove("device_id")
                .remove("device_secret")
                .remove("lease_duration_ms")
                .remove("lease_sync_elapsed")
                .apply();
    }

    public static void setDeviceIdentity(Context context, String id, String secret) {
        prefs(context).edit()
                .putString("device_id", safe(id))
                .putString("device_secret", safe(secret))
                .apply();
    }

    public static void recordLease(Context context, long serverNowMs, long leaseUntilMs) {
        long duration = Math.max(0L, leaseUntilMs - serverNowMs);
        prefs(context).edit()
                .putLong("lease_duration_ms", duration)
                .putLong("lease_sync_elapsed", SystemClock.elapsedRealtime())
                .putLong("server_time_ms", serverNowMs)
                .putLong("lease_until_ms", leaseUntilMs)
                .apply();
        RentalAlarmReceiver.schedule(context, duration);
    }

    public static RentalState rentalState(Context context) {
        SharedPreferences p = prefs(context);
        long sync = p.getLong("lease_sync_elapsed", 0L);
        long duration = p.getLong("lease_duration_ms", 0L);
        if (sync <= 0L || duration <= 0L || SystemClock.elapsedRealtime() < sync) {
            return new RentalState(0L);
        }
        return new RentalState(sync + duration);
    }

    public static boolean isLeaseValid(Context context) {
        return rentalState(context).isPaid(SystemClock.elapsedRealtime());
    }

    public static long remainingMs(Context context) {
        return rentalState(context).remainingMs(SystemClock.elapsedRealtime());
    }

    public static void invalidateLeaseAfterBoot(Context context) {
        prefs(context).edit().putLong("lease_sync_elapsed", 0L).apply();
    }

    public static void recordAdminVerifier(Context context, String salt, String hash, int rounds) {
        prefs(context).edit()
                .putString("admin_salt", safe(salt))
                .putString("admin_hash", safe(hash))
                .putInt("admin_rounds", Math.max(1, rounds))
                .apply();
    }

    public static boolean verifyAdminPassword(Context context, String password) {
        SharedPreferences p = prefs(context);
        long now = SystemClock.elapsedRealtime();
        if (now < p.getLong("admin_locked_until", 0L)) return false;
        String salt = p.getString("admin_salt", "");
        String expected = p.getString("admin_hash", "");
        if (salt.length() == 0 || expected.length() == 0) return false;
        boolean ok = false;
        try {
            ok = expected.equals(Hmac.sha256Iter(password, salt, p.getInt("admin_rounds", 4096)));
        } catch (Exception ignored) {}
        SharedPreferences.Editor edit = p.edit();
        if (ok) {
            edit.putInt("admin_failures", 0)
                    .putLong("admin_locked_until", 0L)
                    .putLong("admin_unlock_until", now + 300000L).apply();
            return true;
        }
        int failures = p.getInt("admin_failures", 0) + 1;
        if (failures >= 5) {
            edit.putInt("admin_failures", 0)
                    .putLong("admin_locked_until", now + 900000L).apply();
        } else {
            edit.putInt("admin_failures", failures).apply();
        }
        return false;
    }

    public static boolean isAdminWindowActive(Context context) {
        return prefs(context).getLong("admin_unlock_until", 0L) > SystemClock.elapsedRealtime();
    }

    public static String server(Context c) { return prefs(c).getString("server", ""); }
    public static String enrollment(Context c) { return prefs(c).getString("enrollment", ""); }
    public static String deviceId(Context c) { return prefs(c).getString("device_id", ""); }
    public static String deviceSecret(Context c) { return prefs(c).getString("device_secret", ""); }
    public static String deviceName(Context c) { return prefs(c).getString("device_name", "Rental phone"); }
    public static boolean isEnrolled(Context c) { return deviceSecret(c).length() > 0; }

    private static String safe(String value) { return value == null ? "" : value.trim(); }
}
