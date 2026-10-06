package com.blazesystems.blazerental;

import android.app.admin.DeviceAdminReceiver;
import android.content.Context;
import android.content.Intent;
import android.os.Build;

public class BlazeDeviceAdminReceiver extends DeviceAdminReceiver {
    @Override
    public void onProfileProvisioningComplete(Context context, Intent intent) {
        BlazeProvisioningContract.capture(context, intent);
        ManagedPolicyController.apply(context);
        final Context app = context.getApplicationContext();
        new Thread(new Runnable() {
            @Override public void run() {
                boolean ok = false;
                if (RentalLeaseStore.hasEnrollmentConfig(app)) {
                    ok = LeaseClient.sync(app) && RentalLeaseStore.isEnrolled(app);
                    if (ok) LeaseClient.sync(app);
                }
                ManagedPolicyController.apply(app);
                if (ok) RentalLeaseStore.markInitialSetupComplete(app, true);
                // Android 8+ has provisioning-success/compliance activities.
                // Older devices need this callback to return to the managed launcher.
                if (ok && Build.VERSION.SDK_INT < 26) {
                    ManagedPolicyController.openHome(app);
                }
            }
        }).start();
    }

    @Override
    public void onEnabled(Context context, Intent intent) {
        ManagedPolicyController.apply(context);
    }
}
