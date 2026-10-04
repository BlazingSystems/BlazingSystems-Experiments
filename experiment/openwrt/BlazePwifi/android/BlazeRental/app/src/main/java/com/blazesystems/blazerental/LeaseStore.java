package com.blazesystems.blazerental;

import android.content.Context;
import android.content.SharedPreferences;
import android.os.PersistableBundle;
import android.os.SystemClock;

public final class LeaseStore {
    private static final String PREFS = "blaze_rental";
    private LeaseStore(){}

    static SharedPreferences p(Context c){ return c.getSharedPreferences(PREFS, Context.MODE_PRIVATE); }

    public static void acceptProvisioningExtras(Context c, PersistableBundle b) {
        if (b == null) return;
        SharedPreferences.Editor e=p(c).edit();
        e.putString("server", safe(b.getString("server_url")));
        e.putString("enroll", safe(b.getString("enrollment_token")));
        e.putString("device_name", safe(b.getString("device_name")));
        e.apply();
    }

    public static void recordServerLease(Context c, long serverNowMs, long leaseUntilMs, String deviceSecret) {
        p(c).edit()
                .putLong("server_now", serverNowMs)
                .putLong("lease_until", leaseUntilMs)
                .putLong("elapsed_sync", SystemClock.elapsedRealtime())
                .putString("device_secret", safe(deviceSecret))
                .apply();
    }

    public static boolean isLeaseValid(Context c) {
        SharedPreferences s=p(c);
        long synced=s.getLong("elapsed_sync",0);
        long serverNow=s.getLong("server_now",0);
        long until=s.getLong("lease_until",0);
        long elapsed=SystemClock.elapsedRealtime();
        if (synced<=0 || serverNow<=0 || until<=serverNow || elapsed<synced) return false;
        long estimatedServerNow=serverNow+(elapsed-synced);
        return estimatedServerNow<until;
    }

    public static long remainingMs(Context c) {
        SharedPreferences s=p(c);
        long synced=s.getLong("elapsed_sync",0), serverNow=s.getLong("server_now",0), until=s.getLong("lease_until",0);
        long elapsed=SystemClock.elapsedRealtime();
        if (synced<=0 || elapsed<synced) return 0;
        return Math.max(0, until-(serverNow+(elapsed-synced)));
    }

    public static void invalidateCachedLeaseAfterBoot(Context c) {
        p(c).edit().putLong("elapsed_sync",0).apply();
    }

    public static String server(Context c){ return p(c).getString("server",""); }
    public static String enrollment(Context c){ return p(c).getString("enroll",""); }
    public static String deviceSecret(Context c){ return p(c).getString("device_secret",""); }
    public static String deviceName(Context c){ return p(c).getString("device_name","Rental phone"); }
    public static boolean isEnrolled(Context c){ return !deviceSecret(c).isEmpty(); }
    private static String safe(String s){ return s==null?"":s.trim(); }
}
