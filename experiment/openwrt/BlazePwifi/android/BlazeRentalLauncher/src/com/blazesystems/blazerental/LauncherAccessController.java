package com.blazesystems.blazerental;

import android.content.Context;
import com.android.launcher3.AppInfo;
import java.util.ArrayList;

public final class LauncherAccessController {
    private LauncherAccessController() {}

    public static boolean isRentalRestricted(Context context) {
        return !AndroidRentalPolicyRepository.load(context).isUnrestricted();
    }

    public static boolean canOpenAppDrawer(Context context) {
        return !isRentalRestricted(context) || RentalLeaseStore.isLeaseValid(context);
    }

    public static boolean isPackageVisible(Context context, String packageName) {
        RentalPolicy policy = AndroidRentalPolicyRepository.load(context);
        if (policy.isUnrestricted()) return true;
        return RentalLeaseStore.isLeaseValid(context) && policy.isPackageAllowed(packageName);
    }

    public static ArrayList<AppInfo> filterApps(Context context, ArrayList<AppInfo> apps) {
        if (!isRentalRestricted(context)) return apps;
        ArrayList<AppInfo> filtered = new ArrayList<AppInfo>();
        if (!RentalLeaseStore.isLeaseValid(context)) return filtered;
        for (AppInfo app : apps) {
            if (app != null && app.componentName != null
                    && isPackageVisible(context, app.componentName.getPackageName())) {
                filtered.add(app);
            }
        }
        return filtered;
    }
}
