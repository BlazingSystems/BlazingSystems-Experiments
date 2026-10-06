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
                // Android 8+ invokes ACTION_PROVISIONING_SUCCESSFUL and modern
                // Android invokes ADMIN_POLICY_COMPLIANCE. Older devices do not,
                // so only they need the receiver to launch home after verified bind.
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
