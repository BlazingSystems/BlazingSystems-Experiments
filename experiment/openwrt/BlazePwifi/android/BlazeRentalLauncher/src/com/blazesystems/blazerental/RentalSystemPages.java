package com.blazesystems.blazerental;

import android.bluetooth.BluetoothAdapter;
import android.content.Context;
import android.graphics.Color;
import android.graphics.Typeface;
import android.graphics.drawable.GradientDrawable;
import android.media.AudioManager;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;
import android.view.Gravity;
import android.view.MotionEvent;
import android.view.View;
import android.content.Intent;
import android.content.IntentFilter;
import android.os.BatteryManager;
import android.os.SystemClock;
import android.text.TextUtils;
import android.os.Handler;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.LinearLayout;
import android.widget.ScrollView;
import android.widget.TextView;
import android.widget.Toast;
import com.android.launcher3.CellLayout;
import com.android.launcher3.Hotseat;
import com.android.launcher3.Launcher;
import com.android.launcher3.Workspace;
import java.util.List;

public final class RentalSystemPages {
    public static final long PAGE_RENTAL = -401L;
    public static final long PAGE_QUICK = -402L;
    public static final long PAGE_NOTIFICATIONS = -403L;

    private RentalSystemPages() {}

    public static void apply(final Launcher launcher) {
        Workspace workspace = launcher.getWorkspace();
        if (workspace == null) return;
        boolean restricted = LauncherAccessController.isRentalRestricted(launcher);
        ManagedPolicyController.apply(launcher);
        ManagedPolicyController.enforceLauncherTask(launcher);

        if (!restricted) {
            if (workspace.getScreenWithId(PAGE_RENTAL) != null
                    || workspace.getScreenWithId(PAGE_QUICK) != null
                    || workspace.getScreenWithId(PAGE_NOTIFICATIONS) != null) {
                launcher.getModel().forceReload();
            }
            Hotseat hotseat = launcher.getHotseat();
            if (hotseat != null) hotseat.setVisibility(View.VISIBLE);
            return;
        }

        workspace.removeAllWorkspaceScreens();
        CellLayout rental = workspace.getScreenWithId(Workspace.FIRST_SCREEN_ID);
        if (rental == null) rental = workspace.insertNewWorkspaceScreen(Workspace.FIRST_SCREEN_ID, 0);
        rental.removeAllViews();
        workspace.insertNewWorkspaceScreen(PAGE_QUICK);
        CellLayout quick = workspace.getScreenWithId(PAGE_QUICK);
        workspace.insertNewWorkspaceScreen(PAGE_NOTIFICATIONS);
        CellLayout notifications = workspace.getScreenWithId(PAGE_NOTIFICATIONS);

        attachFullPage(rental, createRentalPage(launcher), 0x740401);
        attachFullPage(quick, createQuickPage(launcher), 0x740402);
        attachFullPage(notifications, createNotificationsPage(launcher), 0x740403);
        workspace.setCurrentPage(0);

        reassertRestrictedChrome(launcher);
        workspace.post(new Runnable() {
            @Override public void run() { reassertRestrictedChrome(launcher); }
        });
        workspace.postDelayed(new Runnable() {
            @Override public void run() { reassertRestrictedChrome(launcher); }
        }, 750L);
    }

    public static void reassertRestrictedChrome(final Launcher launcher) {
        if (launcher == null || !LauncherAccessController.isRentalRestricted(launcher)) return;
        Hotseat hotseat = launcher.getHotseat();
        if (hotseat != null) {
            hotseat.setVisibility(View.GONE);
            hotseat.setEnabled(false);
        }
        View hotseatView = launcher.findViewById(com.android.launcher3.R.id.hotseat);
        if (hotseatView != null) {
            hotseatView.setVisibility(View.GONE);
            hotseatView.setEnabled(false);
        }
    }

    private static void attachFullPage(CellLayout page, View view, int id) {
        CellLayout.LayoutParams lp = new CellLayout.LayoutParams(
                0, 0, page.getCountX(), page.getCountY());
        lp.canReorder = false;
        page.addViewToCellLayout(view, 0, id, lp, true);
    }

    private static View createRentalPage(final Launcher launcher) {
        final LinearLayout root = basePage(launcher);
        final TextView state = headline(launcher, "BLAZERENTAL");
        final TextView timer = headline(launcher, "00:00:00");
        timer.setTextSize(42f);
        final Handler adminHandler = new Handler();
        final long holdMs = RentalUiPolicy.adminHoldMs(launcher);
        final AdminGestureController adminGesture = new AdminGestureController(holdMs);
        final Runnable openAdmin = new Runnable() {
            @Override public void run() {
                if (adminGesture.shouldTrigger(SystemClock.elapsedRealtime())) {
                    adminGesture.cancel();
                    launcher.startActivity(new Intent(launcher, BlazeAdminActivity.class));
                }
            }
        };
        timer.setOnTouchListener(new View.OnTouchListener() {
            @Override public boolean onTouch(View v, MotionEvent event) {
                if (event.getAction() == MotionEvent.ACTION_DOWN) {
                    adminGesture.onDown(SystemClock.elapsedRealtime());
                    adminHandler.postDelayed(openAdmin, holdMs);
                    return true;
                }
                if (event.getAction() == MotionEvent.ACTION_UP
                        || event.getAction() == MotionEvent.ACTION_CANCEL) {
                    adminHandler.removeCallbacks(openAdmin);
                    adminGesture.onUp(SystemClock.elapsedRealtime());
                    return true;
                }
                return true;
            }
        });
        final TextView detail = body(launcher, "TIME FINISHED");
        final Button coin = actionButton(launcher, "INSERT COIN");

        root.addView(state);
        root.addView(timer);
        root.addView(detail);
        root.addView(coin, buttonMargins(launcher));

        coin.setOnClickListener(new View.OnClickListener() {
            @Override public void onClick(View v) {
                coin.setEnabled(false);
                detail.setText("Waiting for coin controller...");
                new Thread(new Runnable() {
                    @Override public void run() {
                        final String result = LeaseClient.coinStart(launcher, "");
                        launcher.runOnUiThread(new Runnable() {
                            @Override public void run() {
                                detail.setText(result);
                                coin.setEnabled(true);
                            }
                        });
                    }
                }).start();
            }
        });

        final Runnable refresh = new Runnable() {
            @Override public void run() {
                long remaining = RentalLeaseStore.remainingMs(launcher);
                boolean paid = remaining > 0L;
                if (paid) FloatingTimerService.ensure(launcher);
                else FloatingTimerService.stop(launcher);
                setTextIfChanged(timer, formatDuration(remaining));
                setTextIfChanged(detail, paid ? "RENTAL ACTIVE" : "TIME FINISHED");
                setTextIfChanged(coin, paid ? "ADD MORE TIME" : "INSERT COIN");
                if (root.getWindowToken() != null) root.postDelayed(this, 1000L);
            }
        };
        root.post(refresh);
        return root;
    }

    private static View createQuickPage(final Launcher launcher) {
        LinearLayout root = basePage(launcher);
        root.addView(headline(launcher, "QUICK CONTROLS"));

        final AudioManager audio = (AudioManager) launcher.getSystemService(Context.AUDIO_SERVICE);
        if (RentalUiPolicy.quickControlAllowed(launcher, "volume_down")
                || RentalUiPolicy.quickControlAllowed(launcher, "volume_up")) {
            LinearLayout volume = horizontal(launcher);
            Button down = smallButton(launcher, "VOLUME −");
            Button up = smallButton(launcher, "VOLUME +");
            if (RentalUiPolicy.quickControlAllowed(launcher, "volume_down")) {
                volume.addView(down, weight());
                down.setOnClickListener(new View.OnClickListener() {
                    @Override public void onClick(View v) {
                        QuickControlController.adjustVolume(launcher, AudioManager.ADJUST_LOWER);
                    }
                });
            }
            if (RentalUiPolicy.quickControlAllowed(launcher, "volume_up")) {
                volume.addView(up, weight());
                up.setOnClickListener(new View.OnClickListener() {
                    @Override public void onClick(View v) {
                        QuickControlController.adjustVolume(launcher, AudioManager.ADJUST_RAISE);
                    }
                });
            }
            root.addView(volume, rowMargins(launcher));
        }

        if (RentalUiPolicy.quickControlAllowed(launcher, "bluetooth")) {
            final Button bluetoothToggle = smallButton(launcher,
                    QuickControlController.isBluetoothEnabled() ? "BLUETOOTH: ON" : "BLUETOOTH: OFF");
            root.addView(bluetoothToggle, rowMargins(launcher));
            bluetoothToggle.setOnClickListener(new View.OnClickListener() {
                @Override public void onClick(View v) {
                    boolean next = !QuickControlController.isBluetoothEnabled();
                    boolean requested = QuickControlController.setBluetoothEnabled(next);
                    bluetoothToggle.setText(next && requested ? "BLUETOOTH: ON" : "BLUETOOTH: OFF");
                    if (!requested) Toast.makeText(launcher,
                            "Bluetooth control is unavailable on this device", Toast.LENGTH_SHORT).show();
                }
            });
    
            }

        if (RentalUiPolicy.quickControlAllowed(launcher, "flashlight")) {
            final Button torchToggle = smallButton(launcher,
                    QuickControlController.torchEnabled(launcher) ? "FLASHLIGHT: ON" : "FLASHLIGHT: OFF");
            root.addView(torchToggle, rowMargins(launcher));
            torchToggle.setOnClickListener(new View.OnClickListener() {
                @Override public void onClick(View v) {
                    boolean next = !QuickControlController.torchEnabled(launcher);
                    if (QuickControlController.setTorch(launcher, next)) {
                        torchToggle.setText(next ? "FLASHLIGHT: ON" : "FLASHLIGHT: OFF");
                    } else {
                        Toast.makeText(launcher, "Flashlight unavailable", Toast.LENGTH_SHORT).show();
                    }
                }
            });
    
            }

        if (RentalUiPolicy.quickControlAllowed(launcher, "network_status")) {
            root.addView(infoCard(launcher, networkStatus(launcher)));
        }
        if (RentalUiPolicy.quickControlAllowed(launcher, "battery_status")) {
            root.addView(infoCard(launcher, batteryStatus(launcher)));
        }


        if (RentalUiPolicy.floatingTimerUserToggleAllowed(launcher)) {
            final Button timerToggle = smallButton(launcher,
                    launcher.getSharedPreferences("blaze_rental_ui", Context.MODE_PRIVATE)
                            .getBoolean("floating_timer", true)
                            ? "FLOATING TIMER: ON" : "FLOATING TIMER: OFF");
            root.addView(timerToggle, rowMargins(launcher));
            timerToggle.setOnClickListener(new View.OnClickListener() {
                @Override public void onClick(View v) {
                    boolean current = launcher.getSharedPreferences(
                            "blaze_rental_ui", Context.MODE_PRIVATE)
                            .getBoolean("floating_timer", true);
                    boolean next = !current;
                    QuickControlController.setFloatingTimer(launcher, next);
                    timerToggle.setText(next ? "FLOATING TIMER: ON" : "FLOATING TIMER: OFF");
                    Toast.makeText(launcher, next ? "Floating timer enabled" :
                            "Floating timer disabled", Toast.LENGTH_SHORT).show();
                }
            });
        } else if (RentalUiPolicy.quickControlAllowed(launcher, "floating_timer")) {
            root.addView(infoCard(launcher,
                    RentalUiPolicy.floatingTimerForcedOn(launcher)
                            ? "Floating timer: always on (operator policy)"
                            : "Floating timer: off (operator policy)"));
        }

        root.addView(body(launcher,
                "Safe controls only. Android Settings and the system notification shade stay locked in Rental Mode."));
        ScrollView scroll = new ScrollView(launcher);
        scroll.setFillViewport(true);
        scroll.addView(root);
        return scroll;
    }

    private static View createNotificationsPage(final Launcher launcher) {
        final LinearLayout root = basePage(launcher);
        root.addView(headline(launcher, "NOTIFICATIONS"));
        if (!RentalUiPolicy.notificationsEnabled(launcher)) {
            root.addView(infoCard(launcher, "Notification page disabled by operator policy."));
            ScrollView disabled = new ScrollView(launcher);
            disabled.setFillViewport(true);
            disabled.addView(root);
            return disabled;
        }
        final LinearLayout list = new LinearLayout(launcher);
        list.setOrientation(LinearLayout.VERTICAL);
        root.addView(list, new LinearLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT));

        final String[] renderedSignature = new String[] { null };
        final Runnable refresh = new Runnable() {
            @Override public void run() {
                List<RentalNotificationService.Entry> entries =
                        RentalNotificationService.snapshot();
                StringBuilder signature = new StringBuilder();
                for (RentalNotificationService.Entry entry : entries) {
                    signature.append(entry.key).append('|')
                            .append(entry.title).append('|')
                            .append(entry.text).append(';');
                }
                String nextSignature = signature.toString();
                if (TextUtils.equals(renderedSignature[0], nextSignature)) {
                    if (root.getWindowToken() != null) root.postDelayed(this, 2000L);
                    return;
                }
                renderedSignature[0] = nextSignature;
                list.removeAllViews();
                if (entries.isEmpty()) {
                    list.addView(infoCard(launcher,
                            "No mirrored notifications yet. Notification access is granted during managed setup."));
                } else {
                    int start = Math.max(0, entries.size() - 8);
                    for (int i = entries.size() - 1; i >= start; i--) {
                        RentalNotificationService.Entry e = entries.get(i);
                        String title = e.title.length() == 0 ? e.packageName : e.title;
                        String text = e.text.length() == 0 ? e.packageName : e.text;
                        final RentalNotificationService.Entry entry = e;
                        TextView card = infoCard(launcher, title + "\n" + text);
                        card.setOnClickListener(new View.OnClickListener() {
                            @Override public void onClick(View v) {
                                if (!RentalNotificationService.open(launcher, entry.key)) {
                                    Toast.makeText(launcher,
                                            "This notification cannot open a blocked app",
                                            Toast.LENGTH_SHORT).show();
                                }
                            }
                        });
                        card.setOnLongClickListener(new View.OnLongClickListener() {
                            @Override public boolean onLongClick(View v) {
                                RentalNotificationService.dismiss(entry.key);
                                return true;
                            }
                        });
                        list.addView(card);
                    }
                }
                if (root.getWindowToken() != null) root.postDelayed(this, 2000L);
            }
        };
        root.post(refresh);
        ScrollView scroll = new ScrollView(launcher);
        scroll.setFillViewport(true);
        scroll.addView(root);
        return scroll;
    }

    private static LinearLayout basePage(Context context) {
        LinearLayout root = new LinearLayout(context);
        root.setOrientation(LinearLayout.VERTICAL);
        root.setGravity(Gravity.CENTER_HORIZONTAL);
        int p = dp(context, 24);
        root.setPadding(p, dp(context, 54), p, p);
        root.setBackgroundColor(Color.rgb(10, 16, 29));
        return root;
    }

    private static LinearLayout horizontal(Context context) {
        LinearLayout row = new LinearLayout(context);
        row.setOrientation(LinearLayout.HORIZONTAL);
        return row;
    }

    private static TextView headline(Context c, String text) {
        TextView v = new TextView(c);
        v.setText(text);
        v.setTextColor(Color.WHITE);
        v.setTextSize(26f);
        v.setGravity(Gravity.CENTER);
        v.setTypeface(Typeface.DEFAULT, Typeface.BOLD);
        v.setPadding(0, dp(c, 8), 0, dp(c, 8));
        return v;
    }

    private static TextView body(Context c, String text) {
        TextView v = new TextView(c);
        v.setText(text);
        v.setTextColor(Color.rgb(180, 194, 217));
        v.setTextSize(15f);
        v.setGravity(Gravity.CENTER);
        v.setPadding(dp(c, 8), dp(c, 10), dp(c, 8), dp(c, 10));
        return v;
    }

    private static TextView infoCard(Context c, String text) {
        TextView v = body(c, text);
        v.setGravity(Gravity.START | Gravity.CENTER_VERTICAL);
        GradientDrawable bg = new GradientDrawable();
        bg.setColor(Color.rgb(20, 30, 49));
        bg.setCornerRadius(dp(c, 14));
        v.setBackground(bg);
        LinearLayout.LayoutParams lp = rowMargins(c);
        v.setLayoutParams(lp);
        return v;
    }

    private static Button actionButton(Context c, String text) {
        Button b = new Button(c);
        b.setText(text);
        b.setTextSize(18f);
        b.setTypeface(Typeface.DEFAULT, Typeface.BOLD);
        b.setTextColor(Color.WHITE);
        GradientDrawable bg = new GradientDrawable();
        bg.setColor(Color.rgb(37, 99, 235));
        bg.setCornerRadius(dp(c, 14));
        b.setBackground(bg);
        b.setMinHeight(dp(c, 58));
        return b;
    }

    private static Button smallButton(Context c, String text) {
        Button b = actionButton(c, text);
        b.setTextSize(13f);
        b.setMinHeight(dp(c, 48));
        return b;
    }

    private static LinearLayout.LayoutParams buttonMargins(Context c) {
        LinearLayout.LayoutParams lp = new LinearLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT, dp(c, 62));
        lp.setMargins(0, dp(c, 24), 0, dp(c, 18));
        return lp;
    }

    private static LinearLayout.LayoutParams rowMargins(Context c) {
        LinearLayout.LayoutParams lp = new LinearLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT);
        lp.setMargins(0, dp(c, 8), 0, dp(c, 8));
        return lp;
    }

    private static LinearLayout.LayoutParams weight() {
        return new LinearLayout.LayoutParams(0, ViewGroup.LayoutParams.WRAP_CONTENT, 1f);
    }

    private static void setTextIfChanged(TextView view, CharSequence value) {
        if (!TextUtils.equals(view.getText(), value)) view.setText(value);
    }

    private static String batteryStatus(Context c) {
        try {
            Intent state = c.registerReceiver(null, new IntentFilter(Intent.ACTION_BATTERY_CHANGED));
            if (state == null) return "Battery: unavailable";
            int level = state.getIntExtra(BatteryManager.EXTRA_LEVEL, -1);
            int scale = state.getIntExtra(BatteryManager.EXTRA_SCALE, 100);
            int percent = level < 0 ? -1 : Math.round(level * 100f / Math.max(1, scale));
            return percent < 0 ? "Battery: unavailable" : "Battery: " + percent + "%";
        } catch (Exception ignored) {
            return "Battery: unavailable";
        }
    }

    private static String networkStatus(Context c) {
        try {
            ConnectivityManager cm = (ConnectivityManager)
                    c.getSystemService(Context.CONNECTIVITY_SERVICE);
            NetworkInfo active = cm == null ? null : cm.getActiveNetworkInfo();
            return active != null && active.isConnected()
                    ? "Network: connected via " + active.getTypeName()
                    : "Network: offline";
        } catch (Exception ignored) {
            return "Network: unavailable";
        }
    }

    private static String formatDuration(long ms) {
        long total = Math.max(0L, ms / 1000L);
        long hours = total / 3600L;
        long minutes = (total % 3600L) / 60L;
        long seconds = total % 60L;
        return String.format("%02d:%02d:%02d", hours, minutes, seconds);
    }

    private static int dp(Context c, int value) {
        return Math.round(value * c.getResources().getDisplayMetrics().density);
    }
}
