package com.blazesystems.blazerental;

import android.app.admin.DeviceAdminService;
import android.os.Handler;
import android.os.Looper;
import android.os.SystemClock;

public class BlazeDeviceAdminService extends DeviceAdminService {
    private final Handler handler = new Handler(Looper.getMainLooper());
    private long lastSync;
    private long lastHome;

    private final Runnable loop = new Runnable() {
        @Override public void run() {
            try {
                ManagedPolicyController.apply(BlazeDeviceAdminService.this);
                long now = SystemClock.elapsedRealtime();
                long interval = RentalLeaseStore.isLeaseValid(BlazeDeviceAdminService.this)
                        ? 15000L : 4000L;
                if (RentalLeaseStore.hasEnrollmentConfig(BlazeDeviceAdminService.this)
                        && now - lastSync > interval) {
                    lastSync = now;
                    new Thread(new Runnable() {
                        @Override public void run() {
                            LeaseClient.sync(BlazeDeviceAdminService.this);
                        }
                    }).start();
                }
                if (!RentalLeaseStore.isAdminWindowActive(BlazeDeviceAdminService.this)
                        && !RentalLeaseStore.isLeaseValid(BlazeDeviceAdminService.this)
                        && !AndroidRentalPolicyRepository.load(
                                BlazeDeviceAdminService.this).isUnrestricted()
                        && now - lastHome > 2500L) {
                    lastHome = now;
                    ManagedPolicyController.openHome(BlazeDeviceAdminService.this);
                }
            } catch (Exception ignored) {}
            handler.postDelayed(this, 2000L);
        }
    };

    @Override public void onCreate() {
        super.onCreate();
        handler.post(loop);
    }

    @Override public void onDestroy() {
        handler.removeCallbacks(loop);
        super.onDestroy();
    }
}
