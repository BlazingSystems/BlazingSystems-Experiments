package com.blazesystems.blazerental;

import android.content.Context;
import org.json.JSONObject;

public final class RentalPolicyClient {
    private RentalPolicyClient() {}

    public static boolean sync(Context context) {
        return LeaseClient.sync(context);
    }

    public static JSONObject policyPatch(Context context, long expectedRevision, String patchJson) {
        try {
            String base = RentalLeaseStore.server(context);
            String secret = RentalLeaseStore.deviceSecret(context);
            String deviceId = RentalLeaseStore.deviceId(context);
            if (base.length() == 0 || secret.length() == 0 || deviceId.length() == 0) return null;
            String nonce = Hmac.nonce();
            String canonical = "policy_patch|" + nonce + "|" + deviceId + "|"
                    + expectedRevision + "|" + patchJson;
            String body = "action=policy_patch&nonce=" + LeaseClient.enc(nonce)
                    + "&device_id=" + LeaseClient.enc(deviceId)
                    + "&expected_revision=" + expectedRevision
                    + "&patch=" + LeaseClient.enc(patchJson)
                    + "&sig=" + LeaseClient.enc(Hmac.sha256Hex(secret, canonical));
            return LeaseClient.post(base, body);
        } catch (Exception ignored) {
            return null;
        }
    }
}
