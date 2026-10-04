package com.blazesystems.blazerental;

import android.util.Base64;
import java.nio.charset.StandardCharsets;
import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;

public final class Hmac {
    private Hmac(){}
    public static String sha256Hex(String secret,String message) throws Exception {
        Mac m=Mac.getInstance("HmacSHA256");
        m.init(new SecretKeySpec(secret.getBytes(StandardCharsets.UTF_8),"HmacSHA256"));
        byte[] b=m.doFinal(message.getBytes(StandardCharsets.UTF_8));
        StringBuilder s=new StringBuilder(64);
        for(byte x:b) s.append(String.format("%02x",x&0xff));
        return s.toString();
    }
    public static String nonce(){
        byte[] b=new byte[12]; new java.security.SecureRandom().nextBytes(b);
        return Base64.encodeToString(b,Base64.URL_SAFE|Base64.NO_WRAP|Base64.NO_PADDING);
    }
}
