package com.blazesystems.blazerental;

import android.app.Activity;
import android.app.AlertDialog;
import android.app.admin.DevicePolicyManager;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.content.pm.ResolveInfo;
import android.graphics.Color;
import android.graphics.Typeface;
import android.graphics.drawable.GradientDrawable;
import android.net.Uri;
import android.os.Bundle;
import android.os.Build;
import android.provider.Settings;
import android.text.InputType;
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

public class BlazeAdminActivity extends Activity {
    private static final int REQUEST_QR = 441;
    private static final int REQUEST_DEVICE_ADMIN = 442;

    private LinearLayout content;
    private final List<CheckBox> appChecks = new ArrayList<CheckBox>();
    private final List<CheckBox> hiddenAppChecks = new ArrayList<CheckBox>();

    @Override protected void onCreate(Bundle state) {
        super.onCreate(state);
        route();
    }

    private void route() {
        if (!RentalLeaseStore.isInitialSetupComplete(this)
                || !RentalLeaseStore.hasAdminVerifier(this)) {
            RentalLeaseStore.beginInitialSetupWindow(this);
            ManagedPolicyController.apply(this);
            showInitialSetup();
        } else if (RentalLeaseStore.isAdminWindowActive(this)) {
            showDashboard();
        } else {
            showPasswordGate();
        }
    }

    private void showInitialSetup() {
        content = page();
        content.addView(title("BlazeRental Initial Setup"));
        content.addView(label("Configure administrator protection, bind this phone to BlazePwifi, "
                + "and enable the strongest protection available."));

        section("1 · Administrator");
        final EditText localPassword = field("Create local admin password (8+ characters)", true);
        content.addView(localPassword, full());
        Button savePassword = primary(RentalLeaseStore.hasAdminVerifier(this)
                ? "ADMIN PASSWORD READY" : "SET ADMIN PASSWORD");
        content.addView(savePassword, full());
        savePassword.setEnabled(!RentalLeaseStore.hasAdminVerifier(this));
        savePassword.setOnClickListener(new View.OnClickListener() {
            @Override public void onClick(View v) {
                if (!RentalLeaseStore.setLocalAdminPassword(
                        BlazeAdminActivity.this, localPassword.getText().toString())) {
                    Toast.makeText(BlazeAdminActivity.this,
                            "Use at least 8 characters", Toast.LENGTH_LONG).show();
                    return;
                }
                Toast.makeText(BlazeAdminActivity.this,
                        "Local administrator password saved", Toast.LENGTH_SHORT).show();
                showInitialSetup();
            }
        });

        section("2 · BlazePwifi binding");
        addStatus("Server", emptyAs(RentalLeaseStore.server(this), "Not bound"));
        addStatus("Enrollment", RentalLeaseStore.isEnrolled(this)
                ? "ENROLLED" : RentalLeaseStore.hasEnrollmentConfig(this)
                    ? "READY TO SYNC" : "NOT CONFIGURED");
        Button scan = primary("SCAN BLAZEPWIFI ENROLLMENT QR");
        content.addView(scan, full());
        scan.setOnClickListener(new View.OnClickListener() {
            @Override public void onClick(View v) {
                startActivityForResult(new Intent(BlazeAdminActivity.this,
                        QrEnrollmentScannerActivity.class), REQUEST_QR);
            }
        });
        Button sync = secondary("SYNC / COMPLETE ENROLLMENT");
        content.addView(sync, full());
        sync.setEnabled(RentalLeaseStore.hasEnrollmentConfig(this));
        sync.setOnClickListener(new View.OnClickListener() {
            @Override public void onClick(View v) { syncNow(true); }
        });

        section("3 · Uninstall defence");
        addStatus("Managed security", ManagedPolicyController.isDeviceOwner(this)
                ? "DEVICE OWNER · STRONGEST"
                : ManagedPolicyController.isAdminActive(this)
                    ? "DEVICE ADMIN ACTIVE · MANUAL INSTALL"
                    : "NOT ACTIVE");
        if (!ManagedPolicyController.isDeviceOwner(this)
                && !ManagedPolicyController.isAdminActive(this)) {
            Button activate = secondary("ENABLE DEVICE ADMIN DEFENCE");
            content.addView(activate, full());
            activate.setOnClickListener(new View.OnClickListener() {
                @Override public void onClick(View v) {
                    Intent intent = new Intent(DevicePolicyManager.ACTION_ADD_DEVICE_ADMIN);
                    intent.putExtra(DevicePolicyManager.EXTRA_DEVICE_ADMIN,
                            ManagedPolicyController.admin(BlazeAdminActivity.this));
                    intent.putExtra(DevicePolicyManager.EXTRA_ADD_EXPLANATION,
                            "BlazeRental uses Device Admin to make casual uninstall and bypass harder. "
                                    + "Factory-reset Device Owner provisioning gives stronger protection.");
                    startActivityForResult(intent, REQUEST_DEVICE_ADMIN);
                }
            });
        }

        section("4 · Rental special access");
        specialAccessButtons();

        Button finish = primary("FINISH INITIAL SETUP");
        content.addView(finish, full());
        finish.setOnClickListener(new View.OnClickListener() {
            @Override public void onClick(View v) {
                if (!RentalLeaseStore.hasAdminVerifier(BlazeAdminActivity.this)) {
                    Toast.makeText(BlazeAdminActivity.this,
                            "Set the administrator password first", Toast.LENGTH_LONG).show();
                    return;
                }
                if (!RentalLeaseStore.isEnrolled(BlazeAdminActivity.this)) {
                    Toast.makeText(BlazeAdminActivity.this,
                            "Bind and enroll this phone with BlazePwifi first", Toast.LENGTH_LONG).show();
                    return;
                }
                RentalLeaseStore.markInitialSetupComplete(BlazeAdminActivity.this, true);
                ManagedPolicyController.apply(BlazeAdminActivity.this);
                showDashboard();
            }
        });
        setContentView(wrap(content));
    }

    private void showPasswordGate() {
        LinearLayout root = page();
        root.addView(title("BlazeRental Admin"));
        root.addView(label("Administrator authentication is required."));
        final EditText password = field("Admin password", true);
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
        content.addView(label("Native Launcher3 administration · v0.4 Launcher Edition"));

        section("Dashboard");
        addStatus("Security", ManagedPolicyController.isDeviceOwner(this)
                ? "Device Owner" : ManagedPolicyController.isAdminActive(this)
                    ? "Device Admin" : "Manual install · lower security");
        addStatus("Rental", RentalLeaseStore.isLeaseValid(this) ? "PAID" : "LOCKED");
        addStatus("Server", emptyAs(RentalLeaseStore.server(this), "Not bound"));
        addStatus("Device ID", emptyAs(RentalLeaseStore.deviceId(this), "Not enrolled"));
        addStatus("Policy revision", String.valueOf(AndroidRentalPolicyRepository.revision(this)));

        section("Apps");
        buildAppInventory();
        Button saveApps = secondary("SAVE APP ALLOW / HIDE POLICY");
        content.addView(saveApps, full());
        saveApps.setOnClickListener(new View.OnClickListener() {
            @Override public void onClick(View v) { saveAppPolicy(); }
        });

        section("Binding");
        Button scan = secondary("SCAN NEW BLAZEPWIFI QR");
        content.addView(scan, full());
        scan.setOnClickListener(new View.OnClickListener() {
            @Override public void onClick(View v) {
                startActivityForResult(new Intent(BlazeAdminActivity.this,
                        QrEnrollmentScannerActivity.class), REQUEST_QR);
            }
        });

        Button transfer = secondary("TRANSFER TO ANOTHER SERVER / RUN INITIAL SETUP");
        content.addView(transfer, full());
        transfer.setOnClickListener(new View.OnClickListener() {
            @Override public void onClick(View v) {
                new AlertDialog.Builder(BlazeAdminActivity.this)
                        .setTitle("Transfer rental phone?")
                        .setMessage("This clears the local server binding and lease. "
                                + "The administrator password is kept so the phone remains protected.")
                        .setPositiveButton("Transfer", new DialogInterface.OnClickListener() {
                            @Override public void onClick(DialogInterface d, int which) {
                                RentalLeaseStore.prepareTransfer(BlazeAdminActivity.this);
                                AndroidRentalPolicyRepository.clear(BlazeAdminActivity.this);
                                ManagedPolicyController.apply(BlazeAdminActivity.this);
                                showInitialSetup();
                            }
                        }).setNegativeButton("Cancel", null).show();
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

        Button gesture = secondary("ADMIN SECRET TIMER-HOLD DURATION");
        content.addView(gesture, full());
        gesture.setOnClickListener(new View.OnClickListener() {
            @Override public void onClick(View v) { chooseGestureDuration(); }
        });

        section("Notifications / overlay");
        specialAccessButtons();

        section("Diagnostics");
        addStatus("Package", getPackageName());
        addStatus("Android", Build.VERSION.RELEASE + " / API " + Build.VERSION.SDK_INT);
        addStatus("Launcher engine", "Launcher3 o-mr1 derivative");
        addStatus("Notification mirror", hasNotificationAccess() ? "GRANTED" : "MISSING");
        addStatus("Floating overlay",
                Build.VERSION.SDK_INT < 23 || Settings.canDrawOverlays(this) ? "GRANTED" : "MISSING");

        Button close = primary("RETURN TO LAUNCHER");
        content.addView(close, full());
        close.setOnClickListener(new View.OnClickListener() {
            @Override public void onClick(View v) {
                RentalLeaseStore.endAdminWindow(BlazeAdminActivity.this);
                ManagedPolicyController.apply(BlazeAdminActivity.this);
                ManagedPolicyController.openHome(BlazeAdminActivity.this);
                finish();
            }
        });
        setContentView(wrap(content));
    }

    private void specialAccessButtons() {
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
    }

    private void syncNow(final boolean returnToSetup) {
        Toast.makeText(this, "Synchronizing with BlazePwifi...", Toast.LENGTH_SHORT).show();
        new Thread(new Runnable() {
            @Override public void run() {
                final boolean ok = LeaseClient.sync(BlazeAdminActivity.this);
                runOnUiThread(new Runnable() {
                    @Override public void run() {
                        Toast.makeText(BlazeAdminActivity.this,
                                ok ? "BlazePwifi synchronization complete" : "Server rejected synchronization",
                                Toast.LENGTH_LONG).show();
                        if (returnToSetup) showInitialSetup();
                    }
                });
            }
        }).start();
    }

    private void buildAppInventory() {
        appChecks.clear();
        hiddenAppChecks.clear();
        Intent query = new Intent(Intent.ACTION_MAIN);
        query.addCategory(Intent.CATEGORY_LAUNCHER);
        final PackageManager pm = getPackageManager();
        List<ResolveInfo> apps = pm.queryIntentActivities(query, PackageManager.MATCH_ALL);
        Collections.sort(apps, new Comparator<ResolveInfo>() {
            @Override public int compare(ResolveInfo a, ResolveInfo b) {
                return String.valueOf(a.loadLabel(pm))
                        .compareToIgnoreCase(String.valueOf(b.loadLabel(pm)));
            }
        });
        RentalPolicy policy = AndroidRentalPolicyRepository.load(this);
        for (ResolveInfo resolve : apps) {
            if (resolve.activityInfo == null) continue;
            final String pkg = resolve.activityInfo.packageName;
            if (pkg == null || pkg.equals(getPackageName())) continue;

            LinearLayout card = card();
            TextView appName = label(String.valueOf(resolve.loadLabel(pm)));
            appName.setTextColor(Color.WHITE);
            appName.setTypeface(Typeface.DEFAULT, Typeface.BOLD);
            card.addView(appName);
            TextView packageName = label(pkg);
            packageName.setTextSize(12f);
            card.addView(packageName);

            LinearLayout choices = new LinearLayout(this);
            choices.setOrientation(LinearLayout.HORIZONTAL);
            final CheckBox allow = new CheckBox(this);
            allow.setText("ALLOW");
            allow.setTextColor(Color.rgb(180, 220, 255));
            allow.setTag(pkg);
            allow.setChecked(policy.getAllowedPackages().contains(pkg)
                    && !policy.getHiddenPackages().contains(pkg));
            final CheckBox hide = new CheckBox(this);
            hide.setText("HIDE");
            hide.setTextColor(Color.rgb(255, 180, 180));
            hide.setTag(pkg);
            hide.setChecked(policy.getHiddenPackages().contains(pkg)
                    || policy.getSensitivePackages().contains(pkg));

            allow.setOnClickListener(new View.OnClickListener() {
                @Override public void onClick(View v) {
                    if (allow.isChecked()) hide.setChecked(false);
                }
            });
            hide.setOnClickListener(new View.OnClickListener() {
                @Override public void onClick(View v) {
                    if (hide.isChecked()) allow.setChecked(false);
                }
            });

            appChecks.add(allow);
            hiddenAppChecks.add(hide);
            choices.addView(allow, new LinearLayout.LayoutParams(
                    0, ViewGroup.LayoutParams.WRAP_CONTENT, 1f));
            choices.addView(hide, new LinearLayout.LayoutParams(
                    0, ViewGroup.LayoutParams.WRAP_CONTENT, 1f));
            card.addView(choices);
            content.addView(card, full());
        }
    }

    private void saveAppPolicy() {
        HashSet<String> allowed = new HashSet<String>();
        HashSet<String> hidden = new HashSet<String>();
        for (CheckBox box : appChecks) {
            if (box.isChecked()) allowed.add((String) box.getTag());
        }
        for (CheckBox box : hiddenAppChecks) {
            if (box.isChecked()) hidden.add((String) box.getTag());
        }
        try {
            AppPolicySelection selection = AppPolicySelection.of(allowed, hidden);
            JSONObject patch = new JSONObject();
            patch.put("allowed_packages", selection.allowedCsv());
            patch.put("hidden_packages", selection.hiddenCsv());
            sendPatch(patch.toString());
        } catch (Exception e) {
            Toast.makeText(this, "Unable to build app allow/hide policy",
                    Toast.LENGTH_SHORT).show();
        }
    }

    private void promptPasswordChange() {
        final EditText input = field("New administrator password", true);
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
                }).setNegativeButton("Cancel", null).show();
    }

    private void chooseGestureDuration() {
        final String[] values = {"3 seconds", "5 seconds", "7 seconds"};
        new AlertDialog.Builder(this).setTitle("Secret timer-hold duration")
                .setItems(values, new DialogInterface.OnClickListener() {
                    @Override public void onClick(DialogInterface d, int which) {
                        long value = which == 0 ? 3000L : which == 1 ? 5000L : 7000L;
                        try {
                            JSONObject patch = new JSONObject();
                            patch.put("admin_gesture_value", String.valueOf(value));
                            sendPatch(patch.toString());
                        } catch (Exception ignored) {
                            Toast.makeText(BlazeAdminActivity.this,
                                    "Unable to update admin gesture", Toast.LENGTH_SHORT).show();
                        }
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
        if (request == REQUEST_QR && result == RESULT_OK) {
            if (!RentalLeaseStore.isInitialSetupComplete(this)) showInitialSetup();
            else showDashboard();
        } else if (request == REQUEST_DEVICE_ADMIN) {
            showInitialSetup();
        }
    }

    private ScrollView wrap(View child) {
        ScrollView scroll = new ScrollView(this);
        scroll.setFillViewport(true);
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

    private LinearLayout card() {
        LinearLayout card = new LinearLayout(this);
        card.setOrientation(LinearLayout.VERTICAL);
        card.setPadding(dp(14), dp(12), dp(14), dp(12));
        GradientDrawable bg = new GradientDrawable();
        bg.setColor(Color.rgb(20, 30, 49));
        bg.setCornerRadius(dp(12));
        card.setBackground(bg);
        return card;
    }

    private void section(String name) {
        TextView v = title(name);
        v.setTextSize(18f);
        v.setPadding(0, dp(24), 0, dp(8));
        content.addView(v);
    }

    private void addStatus(String key, String value) {
        LinearLayout card = card();
        TextView k = label(key);
        k.setTypeface(Typeface.DEFAULT, Typeface.BOLD);
        k.setTextColor(Color.WHITE);
        TextView v = label(value);
        card.addView(k);
        card.addView(v);
        content.addView(card, full());
    }

    private EditText field(String hint, boolean password) {
        EditText input = new EditText(this);
        input.setHint(hint);
        input.setTextColor(Color.WHITE);
        input.setHintTextColor(Color.rgb(120, 139, 164));
        input.setBackgroundColor(Color.rgb(15, 23, 42));
        input.setPadding(dp(12), dp(10), dp(12), dp(10));
        if (password) input.setInputType(
                InputType.TYPE_CLASS_TEXT | InputType.TYPE_TEXT_VARIATION_PASSWORD);
        return input;
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
        v.setPadding(0, dp(5), 0, dp(5));
        return v;
    }

    private Button primary(String text) {
        Button b = new Button(this);
        b.setText(text);
        b.setTextColor(Color.WHITE);
        b.setBackgroundColor(Color.rgb(70, 95, 255));
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
