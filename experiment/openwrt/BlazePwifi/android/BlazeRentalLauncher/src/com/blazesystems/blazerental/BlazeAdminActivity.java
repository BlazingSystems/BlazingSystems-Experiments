package com.blazesystems.blazerental;

import android.app.Activity;
import android.app.AlertDialog;
import android.app.admin.DevicePolicyManager;
import android.content.ComponentName;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.content.pm.ResolveInfo;
import android.graphics.Color;
import android.graphics.Typeface;
import android.net.Uri;
import android.os.Bundle;
import android.os.Build;
import android.provider.Settings;
import android.text.InputType;
import android.view.Gravity;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.CheckBox;
import android.widget.EditText;
import android.widget.LinearLayout;
import android.widget.ScrollView;
import android.widget.TextView;
import android.widget.Toast;
import org.json.JSONObject;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

public class BlazeAdminActivity extends Activity {
    private LinearLayout content;
    private final List<CheckBox> appChecks = new ArrayList<CheckBox>();

    @Override protected void onCreate(Bundle state) {
        super.onCreate(state);
        if (RentalLeaseStore.isAdminWindowActive(this)) showDashboard();
        else showPasswordGate();
    }

    private void showPasswordGate() {
        LinearLayout root = page();
        TextView title = title("BlazeRental Admin");
        root.addView(title);
        root.addView(label("Administrator authentication is required."));
        final EditText password = new EditText(this);
        password.setHint("Admin password");
        password.setInputType(InputType.TYPE_CLASS_TEXT | InputType.TYPE_TEXT_VARIATION_PASSWORD);
        root.addView(password, full());
        Button unlock = primary("UNLOCK ADMIN");
        root.addView(unlock, full());
        unlock.setOnClickListener(new View.OnClickListener() {
            @Override public void onClick(View v) {
                if (RentalLeaseStore.verifyAdminPassword(BlazeAdminActivity.this,
                        password.getText().toString())) {
                    ManagedPolicyController.apply(BlazeAdminActivity.this);
                    showDashboard();
                } else {
                    Toast.makeText(BlazeAdminActivity.this,
                            "Invalid password or admin entry temporarily locked",
                            Toast.LENGTH_LONG).show();
                }
            }
        });
        setContentView(wrap(root));
    }

    private void showDashboard() {
        content = page();
        content.addView(title("BlazeRental Control Center"));
        content.addView(label("Native device administration • v0.4 Launcher Edition"));

        section("Dashboard");
        addStatus("Device Owner", ManagedPolicyController.isDeviceOwner(this) ? "ACTIVE" : "NOT PROVISIONED");
        addStatus("Rental", RentalLeaseStore.isLeaseValid(this) ? "PAID" : "LOCKED");
        addStatus("Server", emptyAs(RentalLeaseStore.server(this), "Not bound"));
        addStatus("Device ID", emptyAs(RentalLeaseStore.deviceId(this), "Not enrolled"));
        addStatus("Policy revision", String.valueOf(AndroidRentalPolicyRepository.revision(this)));

        section("Apps");
        buildAppInventory();
        Button saveApps = secondary("SAVE APP ALLOWLIST");
        content.addView(saveApps, full());
        saveApps.setOnClickListener(new View.OnClickListener() {
            @Override public void onClick(View v) { saveAppPolicy(); }
        });

        section("Binding");
        Button scan = secondary("SCAN BLAZEPWIFI QR");
        content.addView(scan, full());
        scan.setOnClickListener(new View.OnClickListener() {
            @Override public void onClick(View v) {
                startActivityForResult(new Intent(BlazeAdminActivity.this,
                        QrEnrollmentScannerActivity.class), 441);
            }
        });

        section("Rental mode");
        final CheckBox unrestricted = new CheckBox(this);
        unrestricted.setText("Use device as is (unrestricted launcher)");
        unrestricted.setTextColor(Color.WHITE);
        unrestricted.setChecked(AndroidRentalPolicyRepository.load(this).isUnrestricted());
        content.addView(unrestricted, full());
        unrestricted.setOnClickListener(new View.OnClickListener() {
            @Override public void onClick(View v) {
                sendPatch("{\"launcher_mode\":\""
                        + (unrestricted.isChecked() ? "unrestricted" : "rental") + "\"}");
            }
        });

        section("Security");
        Button password = secondary("CHANGE ADMIN PASSWORD");
        content.addView(password, full());
        password.setOnClickListener(new View.OnClickListener() {
            @Override public void onClick(View v) { promptPasswordChange(); }
        });

        Button gesture = secondary("ADMIN SECRET HOLD DURATION");
        content.addView(gesture, full());
        gesture.setOnClickListener(new View.OnClickListener() {
            @Override public void onClick(View v) { chooseGestureDuration(); }
        });

        section("Notifications / overlay");
        addStatus("Notification mirror", hasNotificationAccess() ? "GRANTED" : "MISSING");
        addStatus("Floating overlay",
                Build.VERSION.SDK_INT < 23 || Settings.canDrawOverlays(this) ? "GRANTED" : "MISSING");

        Button grantNotifications = secondary("GRANT NOTIFICATION ACCESS");
        content.addView(grantNotifications, full());
        grantNotifications.setOnClickListener(new View.OnClickListener() {
            @Override public void onClick(View v) {
                try { startActivity(new Intent("android.settings.ACTION_NOTIFICATION_LISTENER_SETTINGS")); }
                catch (Exception e) {
                    try { startActivity(new Intent("android.settings.NOTIFICATION_LISTENER_SETTINGS")); }
                    catch (Exception ignored) {}
                }
            }
        });

        Button grantOverlay = secondary("GRANT FLOATING TIMER OVERLAY");
        content.addView(grantOverlay, full());
        grantOverlay.setOnClickListener(new View.OnClickListener() {
            @Override public void onClick(View v) {
                if (Build.VERSION.SDK_INT < 23) return;
                try {
                    startActivity(new Intent(Settings.ACTION_MANAGE_OVERLAY_PERMISSION,
                            Uri.parse("package:" + getPackageName())));
                } catch (Exception ignored) {}
            }
        });

        section("Diagnostics");
        addStatus("Package", getPackageName());
        addStatus("Android", Build.VERSION.RELEASE + " / API " + Build.VERSION.SDK_INT);
        addStatus("Security mode", ManagedPolicyController.isDeviceOwner(this)
                ? "Managed Device Owner" : "Manual install (lower security)");

        Button close = primary("RETURN TO LAUNCHER");
        content.addView(close, full());
        close.setOnClickListener(new View.OnClickListener() {
            @Override public void onClick(View v) {
                ManagedPolicyController.apply(BlazeAdminActivity.this);
                ManagedPolicyController.openHome(BlazeAdminActivity.this);
                finish();
            }
        });

        setContentView(wrap(content));
    }

    private void buildAppInventory() {
        appChecks.clear();
        Intent query = new Intent(Intent.ACTION_MAIN);
        query.addCategory(Intent.CATEGORY_LAUNCHER);
        final PackageManager pm = getPackageManager();
        List<ResolveInfo> apps = pm.queryIntentActivities(query, PackageManager.MATCH_ALL);
        Collections.sort(apps, new Comparator<ResolveInfo>() {
            @Override public int compare(ResolveInfo a, ResolveInfo b) {
                return String.valueOf(a.loadLabel(pm)).compareToIgnoreCase(String.valueOf(b.loadLabel(pm)));
            }
        });
        RentalPolicy policy = AndroidRentalPolicyRepository.load(this);
        for (ResolveInfo resolve : apps) {
            if (resolve.activityInfo == null) continue;
            String pkg = resolve.activityInfo.packageName;
            if (pkg == null || pkg.equals(getPackageName())) continue;
            CheckBox box = new CheckBox(this);
            box.setText(resolve.loadLabel(pm) + "\n" + pkg);
            box.setTextColor(Color.rgb(225, 232, 244));
            box.setTag(pkg);
            box.setChecked(policy.isPackageAllowed(pkg));
            appChecks.add(box);
            content.addView(box, full());
        }
    }

    private void saveAppPolicy() {
        StringBuilder csv = new StringBuilder();
        for (CheckBox box : appChecks) {
            if (!box.isChecked()) continue;
            if (csv.length() > 0) csv.append(',');
            csv.append((String) box.getTag());
        }
        try {
            JSONObject patch = new JSONObject();
            patch.put("allowed_packages", csv.toString());
            sendPatch(patch.toString());
        } catch (Exception e) {
            Toast.makeText(this, "Unable to build policy update", Toast.LENGTH_SHORT).show();
        }
    }

    private void promptPasswordChange() {
        final EditText input = new EditText(this);
        input.setHint("New administrator password");
        input.setInputType(InputType.TYPE_CLASS_TEXT | InputType.TYPE_TEXT_VARIATION_PASSWORD);
        new AlertDialog.Builder(this)
                .setTitle("Change admin password")
                .setView(input)
                .setPositiveButton("Save", new DialogInterface.OnClickListener() {
                    @Override public void onClick(DialogInterface d, int which) {
                        try {
                            JSONObject patch = new JSONObject();
                            patch.put("admin_password", input.getText().toString());
                            sendPatch(patch.toString());
                        } catch (Exception ignored) {}
                    }
                })
                .setNegativeButton("Cancel", null).show();
    }

    private void chooseGestureDuration() {
        final String[] values = {"3 seconds", "5 seconds", "7 seconds"};
        new AlertDialog.Builder(this).setTitle("Secret hold duration")
                .setItems(values, new DialogInterface.OnClickListener() {
                    @Override public void onClick(DialogInterface d, int which) {
                        long value = which == 0 ? 3000L : which == 1 ? 5000L : 7000L;
                        getSharedPreferences("blaze_rental_ui", MODE_PRIVATE)
                                .edit().putLong("admin_hold_ms", value).apply();
                        Toast.makeText(BlazeAdminActivity.this,
                                "Admin hold set to " + values[which], Toast.LENGTH_SHORT).show();
                    }
                }).show();
    }

    private void sendPatch(final String patchJson) {
        final long revision = AndroidRentalPolicyRepository.revision(this);
        Toast.makeText(this, "Applying policy...", Toast.LENGTH_SHORT).show();
        new Thread(new Runnable() {
            @Override public void run() {
                final JSONObject response = RentalPolicyClient.policyPatch(
                        BlazeAdminActivity.this, revision, patchJson);
                final boolean ok = response != null && response.optBoolean("ok", false);
                if (ok) LeaseClient.sync(BlazeAdminActivity.this);
                runOnUiThread(new Runnable() {
                    @Override public void run() {
                        Toast.makeText(BlazeAdminActivity.this,
                                ok ? "Policy updated" :
                                        response == null ? "Server unavailable" :
                                                response.optString("error", "Policy rejected"),
                                Toast.LENGTH_LONG).show();
                        if (ok) showDashboard();
                    }
                });
            }
        }).start();
    }

    private boolean hasNotificationAccess() {
        String enabled = Settings.Secure.getString(getContentResolver(),
                "enabled_notification_listeners");
        return enabled != null && enabled.contains(getPackageName());
    }

    @Override protected void onActivityResult(int request, int result, Intent data) {
        super.onActivityResult(request, result, data);
        if (request == 441 && result == RESULT_OK) showDashboard();
    }

    private ScrollView wrap(View child) {
        ScrollView scroll = new ScrollView(this);
        scroll.setBackgroundColor(Color.rgb(8, 13, 24));
        scroll.addView(child);
        return scroll;
    }

    private LinearLayout page() {
        LinearLayout root = new LinearLayout(this);
        root.setOrientation(LinearLayout.VERTICAL);
        root.setPadding(dp(18), dp(24), dp(18), dp(40));
        return root;
    }

    private void section(String name) {
        TextView v = title(name);
        v.setTextSize(18f);
        v.setPadding(0, dp(24), 0, dp(8));
        content.addView(v);
    }

    private void addStatus(String key, String value) {
        TextView v = label(key + "\n" + value);
        v.setBackgroundColor(Color.rgb(20, 30, 49));
        v.setPadding(dp(14), dp(12), dp(14), dp(12));
        LinearLayout.LayoutParams lp = full();
        lp.setMargins(0, dp(5), 0, dp(5));
        content.addView(v, lp);
    }

    private TextView title(String text) {
        TextView v = new TextView(this);
        v.setText(text);
        v.setTextColor(Color.WHITE);
        v.setTextSize(25f);
        v.setTypeface(Typeface.DEFAULT, Typeface.BOLD);
        return v;
    }

    private TextView label(String text) {
        TextView v = new TextView(this);
        v.setText(text);
        v.setTextColor(Color.rgb(180, 194, 217));
        v.setTextSize(14f);
        v.setPadding(0, dp(8), 0, dp(8));
        return v;
    }

    private Button primary(String text) {
        Button b = new Button(this);
        b.setText(text);
        b.setTextColor(Color.WHITE);
        b.setBackgroundColor(Color.rgb(37, 99, 235));
        return b;
    }

    private Button secondary(String text) {
        Button b = primary(text);
        b.setBackgroundColor(Color.rgb(30, 41, 59));
        return b;
    }

    private LinearLayout.LayoutParams full() {
        LinearLayout.LayoutParams lp = new LinearLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT);
        lp.setMargins(0, dp(7), 0, dp(7));
        return lp;
    }

    private String emptyAs(String value, String fallback) {
        return value == null || value.length() == 0 ? fallback : value;
    }

    private int dp(int value) {
        return Math.round(value * getResources().getDisplayMetrics().density);
    }
}
