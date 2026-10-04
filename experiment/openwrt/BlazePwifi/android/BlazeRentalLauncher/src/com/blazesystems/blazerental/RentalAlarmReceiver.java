package com.blazesystems.blazerental;

import android.app.AlarmManager;
import android.app.PendingIntent;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.os.SystemClock;

public class RentalAlarmReceiver extends BroadcastReceiver {
    private static final int REQUEST_CODE = 9404;

    public static void schedule(Context context, long remainingMs) {
        AlarmManager manager = (AlarmManager) context.getSystemService(Context.ALARM_SERVICE);
        if (manager == null) return;
        long delay = Math.max(1000L, Math.min(remainingMs > 0L ? remainingMs : 15000L, 60000L));
        Intent intent = new Intent(context, RentalAlarmReceiver.class);
        PendingIntent pending = PendingIntent.getBroadcast(context, REQUEST_CODE, intent,
                PendingIntent.FLAG_UPDATE_CURRENT | PendingIntent.FLAG_IMMUTABLE);
        manager.setExactAndAllowWhileIdle(AlarmManager.ELAPSED_REALTIME_WAKEUP,
                SystemClock.elapsedRealtime() + delay, pending);
    }

    @Override
    public void onReceive(final Context context, Intent intent) {
        final PendingResult pending = goAsync();
        new Thread(new Runnable() {
            @Override public void run() {
                try {
                    if (RentalLeaseStore.isEnrolled(context)) LeaseClient.sync(context);
                    ManagedPolicyController.apply(context);
                    if (!RentalLeaseStore.isLeaseValid(context)
                            && !AndroidRentalPolicyRepository.load(context).isUnrestricted()) {
                        ManagedPolicyController.openHome(context);
                    }
                    schedule(context, RentalLeaseStore.remainingMs(context));
                } finally {
                    pending.finish();
                }
            }
        }).start();
    }
}
