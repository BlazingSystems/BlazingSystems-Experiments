package com.blazesystems.blazerental;

import android.content.Context;
import android.content.Intent;
import android.os.PersistableBundle;
import java.util.ArrayList;

public final class BlazeProvisioningContract {
    public static final String ACTION_GET_PROVISIONING_MODE =
            "android.app.action.GET_PROVISIONING_MODE";
    public static final String ACTION_ADMIN_POLICY_COMPLIANCE =
            "android.app.action.ADMIN_POLICY_COMPLIANCE";
    public static final String ACTION_PROVISIONING_SUCCESSFUL =
            "android.app.action.PROVISIONING_SUCCESSFUL";
    public static final String EXTRA_ADMIN_EXTRAS =
            "android.app.extra.PROVISIONING_ADMIN_EXTRAS_BUNDLE";
    public static final String EXTRA_ALLOWED_MODES =
            "android.app.extra.PROVISIONING_ALLOWED_PROVISIONING_MODES";
    public static final String EXTRA_MODE =
            "android.app.extra.PROVISIONING_MODE";
    public static final String EXTRA_SKIP_EDUCATION =
            "android.app.extra.PROVISIONING_SKIP_EDUCATION_SCREENS";
    public static final int MODE_FULLY_MANAGED_DEVICE = 1;
    public static final String SCHEMA = "blazerental.provisioning.v1";

    private BlazeProvisioningContract() {}

    public static PersistableBundle extras(Intent intent) {
        if (intent == null) return null;
        try {
            return (PersistableBundle) intent.getParcelableExtra(EXTRA_ADMIN_EXTRAS);
        } catch (Exception ignored) {
            return null;
        }
    }

    public static boolean isValid(PersistableBundle extras) {
        if (extras == null) return false;
        String schema = clean(extras.getString("blaze_schema"));
        String server = clean(extras.getString("server_url"));
        String token = clean(extras.getString("enrollment_token"));
        String pin = clean(extras.getString("server_cert_sha256")).replace(":", "").toLowerCase();
        if (!SCHEMA.equals(schema)) return false;
        if (!server.startsWith("https://")) return false;
        int dot = token.indexOf('.');
        if (dot < 8 || dot >= token.length() - 16
                || !token.matches("[A-Fa-f0-9]+\\.[A-Fa-f0-9]+")) return false;
        return pin.matches("[0-9a-f]{64}");
    }

    public static boolean capture(Context context, Intent intent) {
        PersistableBundle extras = extras(intent);
        if (!isValid(extras)) return false;
        RentalLeaseStore.acceptProvisioningExtras(context, extras);
        return true;
    }

    public static boolean allowsFullyManaged(Intent intent) {
        if (intent == null) return true;
        try {
            ArrayList<Integer> modes = intent.getIntegerArrayListExtra(EXTRA_ALLOWED_MODES);
            return modes == null || modes.size() == 0
                    || modes.contains(Integer.valueOf(MODE_FULLY_MANAGED_DEVICE));
        } catch (Exception ignored) {
            return true;
        }
    }

    public static Intent modeResult(PersistableBundle extras) {
        Intent result = new Intent();
        result.putExtra(EXTRA_MODE, MODE_FULLY_MANAGED_DEVICE);
        result.putExtra(EXTRA_SKIP_EDUCATION, true);
        if (extras != null) result.putExtra(EXTRA_ADMIN_EXTRAS, extras);
        return result;
    }

    private static String clean(String value) {
        return value == null ? "" : value.trim();
    }
}
