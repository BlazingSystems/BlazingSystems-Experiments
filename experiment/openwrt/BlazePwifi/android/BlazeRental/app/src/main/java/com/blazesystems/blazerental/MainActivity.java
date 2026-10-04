package com.blazesystems.blazerental;

import android.app.*;
import android.app.admin.DevicePolicyManager;
import android.content.*;
import android.graphics.Color;
import android.os.*;
import android.view.*;
import android.widget.*;
import java.util.Locale;

public class MainActivity extends Activity {
    private LinearLayout root;
    private TextView status,time,mode;
    private Handler handler=new Handler(Looper.getMainLooper());

    @Override public void onCreate(Bundle b){
        super.onCreate(b);
        Policy.applyManagedPolicy(this);
        buildUi();
        new Thread(()->{ LeaseClient.sync(this); runOnUiThread(this::refresh); }).start();
        handler.post(tick);
    }

    private void buildUi(){
        root=new LinearLayout(this); root.setOrientation(LinearLayout.VERTICAL);
        root.setPadding(34,48,34,34); root.setGravity(Gravity.CENTER_HORIZONTAL); root.setBackgroundColor(Color.rgb(7,17,31));
        mode=text(14); status=text(28); time=text(44);
        TextView title=text(22); title.setText("BlazeRental"); title.setTextColor(Color.rgb(82,228,255));
        root.addView(title); root.addView(mode); root.addView(status); root.addView(time);
        Button sync=new Button(this); sync.setText("Check rental time"); sync.setOnClickListener(v->new Thread(()->{LeaseClient.sync(this);runOnUiThread(this::refresh);}).start());
        root.addView(sync,new LinearLayout.LayoutParams(-1,-2));
        TextView note=text(14); note.setText("Managed QR mode is the strongest setup. A normal APK install works too, but can be bypassed more easily.");
        root.addView(note);
        setContentView(root); refresh();
    }

    private TextView text(int sp){ TextView t=new TextView(this); t.setTextColor(Color.WHITE); t.setTextSize(sp); t.setGravity(Gravity.CENTER); t.setPadding(4,14,4,14); return t; }

    private final Runnable tick=new Runnable(){ public void run(){ refresh(); handler.postDelayed(this,1000); } };

    private void refresh(){
        boolean owner=Policy.isDeviceOwner(this), valid=LeaseStore.isLeaseValid(this);
        mode.setText(owner?"Fully managed · Device Owner":"Manual APK · lower security");
        long sec=LeaseStore.remainingMs(this)/1000;
        time.setText(String.format(Locale.US,"%02d:%02d:%02d",sec/3600,(sec/60)%60,sec%60));
        status.setText(valid?"Rental active":"Time finished");
        if(owner){
            try { if(valid && isInLockTaskMode()) stopLockTask(); else if(!valid && !isInLockTaskMode()) startLockTask(); } catch(Exception ignored){}
        }
    }

    private boolean isInLockTaskMode(){
        ActivityManager a=(ActivityManager)getSystemService(ACTIVITY_SERVICE);
        return a!=null && a.getLockTaskModeState()!=ActivityManager.LOCK_TASK_MODE_NONE;
    }

    @Override protected void onDestroy(){ handler.removeCallbacks(tick); super.onDestroy(); }
}
