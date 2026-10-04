package com.blazesystems.blazerental;

import android.content.Context;
import org.json.JSONObject;
import java.io.ByteArrayOutputStream;
import java.io.InputStream;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.List;

public final class LeaseClient {
    private LeaseClient() {}

    public static boolean sync(Context context) {
        try {
            String base = RentalLeaseStore.server(context);
            if (base.length() == 0) return false;
            String deviceSecret = RentalLeaseStore.deviceSecret(context);
            String enrollment = RentalLeaseStore.enrollment(context);
            String nonce = Hmac.nonce();
            boolean enrolling = deviceSecret.length() == 0;
            String action = enrolling ? "enroll" : "status";
            String authSecret = enrolling ? enrollment : deviceSecret;
            if (authSecret.length() == 0) return false;

            StringBuilder body = new StringBuilder();
            body.append("action=").append(enc(action))
                    .append("&nonce=").append(enc(nonce));

            if (enrolling) {
                int dot = enrollment.indexOf('.');
                if (dot <= 0) return false;
                body.append("&enroll_id=").append(enc(enrollment.substring(0, dot)));
            } else {
                body.append("&device_id=").append(enc(RentalLeaseStore.deviceId(context)));
                body.append("&inventory=").append(enc(inventoryCsv(context)));
            }

            String canonicalAuth = action + "|" + nonce + "|" + authSecret;
            body.append("&sig=").append(enc(Hmac.sha256Hex(authSecret, canonicalAuth)));

            JSONObject response = post(base, body.toString());
            if (response == null || !response.optBoolean("ok", false)) return false;

            String newSecret = response.optString("device_secret", deviceSecret);
            String deviceId = response.optString("device_id", RentalLeaseStore.deviceId(context));
            if (deviceId.length() > 0 && newSecret.length() > 0) {
                RentalLeaseStore.setDeviceIdentity(context, deviceId, newSecret);
            }

            long serverNow = response.optLong("server_time_ms", 0L);
            long leaseUntil = response.optLong("lease_until_ms", 0L);
            if (serverNow <= 0L || leaseUntil < serverNow) return false;
            RentalLeaseStore.recordLease(context, serverNow, leaseUntil);

            if (!enrolling) {
                String allowed = response.optString("allowed_packages", "*");
                String hidden = response.optString("hidden_packages", "");
                String mode = response.optString("launcher_mode", RentalPolicy.MODE_RENTAL);
                String salt = response.optString("admin_salt", "");
                String hash = response.optString("admin_hash", "");
                int rounds = response.optInt("admin_rounds", 4096);
                String preferred = response.optString("preferred_vendo", "");
                int secondsPerPulse = response.optInt("rental_seconds_per_pulse", 600);
                String policySignature = response.optString("policy_sig", "");
                String policySignatureV2 = response.optString("policy_sig_v2", "");

                String legacyCanonical = deviceId + "|" + nonce + "|" + serverNow + "|"
                        + leaseUntil + "|" + allowed + "|" + salt + "|" + hash + "|"
                        + rounds + "|" + preferred + "|" + secondsPerPulse;
                long revision = response.has("policy_revision")
                        ? response.optLong("policy_revision", 0L)
                        : Math.max(0L, AndroidRentalPolicyRepository.revision(context) + 1L);

                if (response.has("policy_revision")) {
                    String v2Canonical = "v2|" + deviceId + "|" + nonce + "|" + serverNow + "|"
                            + leaseUntil + "|" + revision + "|" + mode + "|" + allowed + "|"
                            + hidden + "|" + salt + "|" + hash + "|" + rounds + "|"
                            + preferred + "|" + secondsPerPulse;
                    if (policySignatureV2.length() == 0
                            || !policySignatureV2.equals(Hmac.sha256Hex(newSecret, v2Canonical))) {
                        return false;
                    }
                } else if (policySignature.length() == 0
                        || !policySignature.equals(Hmac.sha256Hex(newSecret, legacyCanonical))) {
                    return false;
                }

                String effectiveAllowed = allowed;
                if ("*".equals(allowed)) effectiveAllowed = inventoryCsv(context);

                AndroidRentalPolicyRepository.applyVerified(context, revision, mode,
                        effectiveAllowed, hidden, "", legacyCanonical, policySignature);
                RentalLeaseStore.recordAdminVerifier(context, salt, hash, rounds);
            }

            ManagedPolicyController.apply(context);
            return true;
        } catch (Exception ignored) {
            return false;
        }
    }

    public static String coinStart(Context context, String preferredVendo) {
        try {
            String base = RentalLeaseStore.server(context);
            String secret = RentalLeaseStore.deviceSecret(context);
            String deviceId = RentalLeaseStore.deviceId(context);
            if (base.length() == 0 || secret.length() == 0 || deviceId.length() == 0) {
                return "Rental phone is not enrolled.";
            }
            String nonce = Hmac.nonce();
            String body = "action=coin_start&nonce=" + enc(nonce)
                    + "&device_id=" + enc(deviceId)
                    + "&sig=" + enc(Hmac.sha256Hex(secret,
                    "coin_start|" + nonce + "|" + secret));
            if (preferredVendo != null && preferredVendo.trim().length() > 0) {
                body += "&vendo=" + enc(preferredVendo.trim());
            }
            JSONObject response = post(base, body);
            if (response == null) return "Server unavailable.";
            if (!response.optBoolean("ok", false)) {
                return response.optString("error", "Unable to start coin slot.");
            }
            return "Insert coin at " + response.optString("vendo", "selected controller") + ".";
        } catch (Exception ignored) {
            return "Unable to start coin slot.";
        }
    }

    static String inventoryCsv(Context context) {
        List<String> packages = ManagedPolicyController.safeLaunchablePackages(context);
        StringBuilder out = new StringBuilder();
        for (String pkg : packages) {
            if (out.length() > 0) out.append(',');
            out.append(pkg);
        }
        return out.toString();
    }

    static JSONObject post(String base, String body) throws Exception {
        URL url = new URL(base.replaceAll("/+$", "") + "/cgi-bin/rental");
        HttpURLConnection connection = (HttpURLConnection) url.openConnection();
        connection.setConnectTimeout(3500);
        connection.setReadTimeout(3500);
        connection.setRequestMethod("POST");
        connection.setDoOutput(true);
        connection.setRequestProperty("Content-Type", "application/x-www-form-urlencoded");
        OutputStream output = connection.getOutputStream();
        output.write(body.getBytes(StandardCharsets.UTF_8));
        output.close();
        InputStream input = connection.getResponseCode() == 200
                ? connection.getInputStream() : connection.getErrorStream();
        if (input == null) return null;
        return new JSONObject(read(input));
    }

    static String enc(String value) throws Exception {
        return URLEncoder.encode(value == null ? "" : value, "UTF-8");
    }

    private static String read(InputStream input) throws Exception {
        ByteArrayOutputStream output = new ByteArrayOutputStream();
        byte[] buffer = new byte[2048];
        int count;
        while ((count = input.read(buffer)) > 0) output.write(buffer, 0, count);
        input.close();
        return output.toString("UTF-8");
    }
}
