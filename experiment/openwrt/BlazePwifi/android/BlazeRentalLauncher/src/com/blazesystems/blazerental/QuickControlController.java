package com.blazesystems.blazerental;

import android.content.Context;
import android.media.AudioManager;
import java.util.Arrays;
import java.util.Collections;
import java.util.List;

public final class QuickControlController {
    public static final String VOLUME_DOWN = "volume_down";
    public static final String VOLUME_UP = "volume_up";
    public static final String FLOATING_TIMER = "floating_timer";
    public static final String NETWORK_STATUS = "network_status";
    public static final String BLUETOOTH_STATUS = "bluetooth_status";

    private static final List<String> SAFE_CONTROLS = Collections.unmodifiableList(
            Arrays.asList(VOLUME_DOWN, VOLUME_UP, FLOATING_TIMER,
                    NETWORK_STATUS, BLUETOOTH_STATUS));

    private QuickControlController() {}

    public static List<String> safeControls() { return SAFE_CONTROLS; }

    public static boolean containsDangerousSettingsBridge() {
        for (String id : SAFE_CONTROLS) {
            if (id.contains("settings") || id.contains("developer") || id.contains("install")) {
                return true;
            }
        }
        return false;
    }

    public static void adjustVolume(Context context, int direction) {
        AudioManager audio = (AudioManager) context.getSystemService(Context.AUDIO_SERVICE);
        if (audio != null) audio.adjustVolume(direction, AudioManager.FLAG_SHOW_UI);
    }

    public static void setFloatingTimer(Context context, boolean enabled) {
        context.getSharedPreferences("blaze_rental_ui", Context.MODE_PRIVATE)
                .edit().putBoolean("floating_timer", enabled).apply();
        if (enabled) FloatingTimerService.ensure(context);
        else FloatingTimerService.stop(context);
    }
}
