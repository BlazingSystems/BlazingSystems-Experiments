package com.blazesystems.blazerental;

import android.content.Context;
import org.json.JSONObject;
import java.io.*;
import java.net.*;
import java.nio.charset.StandardCharsets;

public final class LeaseClient {
    private LeaseClient(){}

    public static boolean sync(Context c) {
        try {
            String base=LeaseStore.server(c);
            if(base.isEmpty()) return false;
            String secret=LeaseStore.deviceSecret(c);
            String enroll=LeaseStore.enrollment(c);
            String nonce=Hmac.nonce();
            String action=secret.isEmpty()?"enroll":"status";
            String authSecret=secret.isEmpty()?enroll:secret;
            if(authSecret.isEmpty()) return false;
            String body="action="+action+"&nonce="+enc(nonce)+"&device="+enc(android.os.Build.SERIAL)+"&sig="+
                    enc(Hmac.sha256Hex(authSecret,action+"|"+nonce+"|"+authSecret));
            URL u=new URL(base.replaceAll("/+$","")+"/cgi-bin/rental");
            HttpURLConnection h=(HttpURLConnection)u.openConnection();
            h.setConnectTimeout(3500); h.setReadTimeout(3500); h.setRequestMethod("POST"); h.setDoOutput(true);
            h.setRequestProperty("Content-Type","application/x-www-form-urlencoded");
            try(OutputStream o=h.getOutputStream()){ o.write(body.getBytes(StandardCharsets.UTF_8)); }
            if(h.getResponseCode()!=200) return false;
            String json=read(h.getInputStream());
            JSONObject j=new JSONObject(json);
            if(!j.optBoolean("ok",false)) return false;
            String newSecret=j.optString("device_secret",secret);
            long now=j.optLong("server_time_ms",0), until=j.optLong("lease_until_ms",0);
            if(now<=0 || until<now) return false;
            LeaseStore.recordServerLease(c,now,until,newSecret);
            return true;
        } catch(Exception ignored){ return false; }
    }

    private static String enc(String s) throws Exception { return URLEncoder.encode(s,"UTF-8"); }
    private static String read(InputStream in) throws Exception {
        ByteArrayOutputStream b=new ByteArrayOutputStream(); byte[] x=new byte[2048]; int n;
        while((n=in.read(x))>0) b.write(x,0,n);
        return b.toString("UTF-8");
    }
}
