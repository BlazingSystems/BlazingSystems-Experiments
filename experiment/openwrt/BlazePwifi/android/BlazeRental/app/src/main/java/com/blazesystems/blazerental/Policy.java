package com.blazesystems.blazerental;

import android.app.admin.DevicePolicyManager;
import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.os.UserManager;

public final class Policy {
    private Policy(){}

    public static ComponentName admin(Context c){ return new ComponentName(c, BlazeDeviceAdminReceiver.class); }

    public static boolean isDeviceOwner(Context c) {
        DevicePolicyManager d=(DevicePolicyManager)c.getSystemService(Context.DEVICE_POLICY_SERVICE);
        return d!=null && d.isDeviceOwnerApp(c.getPackageName());
    }

    public static void applyManagedPolicy(Context c) {
        DevicePolicyManager d=(DevicePolicyManager)c.getSystemService(Context.DEVICE_POLICY_SERVICE);
        if(d==null || !d.isDeviceOwnerApp(c.getPackageName())) return;
        ComponentName a=admin(c);
        try { d.setLockTaskPackages(a,new String[]{c.getPackageName()}); } catch(Exception ignored){}
        try {
            IntentFilter f=new IntentFilter(Intent.ACTION_MAIN);
            f.addCategory(Intent.CATEGORY_HOME); f.addCategory(Intent.CATEGORY_DEFAULT);
            d.addPersistentPreferredActivity(a,f,new ComponentName(c,MainActivity.class));
        } catch(Exception ignored){}
        addRestriction(d,a,UserManager.DISALLOW_ADD_USER);
        addRestriction(d,a,UserManager.DISALLOW_SAFE_BOOT);
        addRestriction(d,a,UserManager.DISALLOW_DEBUGGING_FEATURES);
        addRestriction(d,a,UserManager.DISALLOW_INSTALL_UNKNOWN_SOURCES);
        try { d.setStatusBarDisabled(a,true); } catch(Exception ignored){}
        try { d.setKeyguardDisabled(a,true); } catch(Exception ignored){}
    }

    private static void addRestriction(DevicePolicyManager d,ComponentName a,String r){
        try { d.addUserRestriction(a,r); } catch(Exception ignored){}
    }

    public static void openHome(Context c) {
        Intent i=new Intent(c,MainActivity.class).addFlags(Intent.FLAG_ACTIVITY_NEW_TASK|Intent.FLAG_ACTIVITY_CLEAR_TOP);
        try { c.startActivity(i); } catch(Exception ignored){}
    }
}
