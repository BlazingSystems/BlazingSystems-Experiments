package com.blazesystems.blazerental;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;

public class BlazeBootReceiver extends BroadcastReceiver {
    @Override
    public void onReceive(Context context, Intent intent) {
        RentalLeaseStore.invalidateLeaseAfterBoot(context);
        ManagedPolicyController.apply(context);
        ManagedPolicyController.openHome(context);
        RentalAlarmReceiver.schedule(context, 1000L);
    }
}
