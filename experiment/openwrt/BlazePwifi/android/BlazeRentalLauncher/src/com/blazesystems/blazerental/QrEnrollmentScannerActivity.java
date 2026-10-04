package com.blazesystems.blazerental;

import android.Manifest;
import android.app.Activity;
import android.content.pm.PackageManager;
import android.hardware.Camera;
import android.net.Uri;
import android.os.Bundle;
import android.view.Gravity;
import android.view.SurfaceHolder;
import android.view.SurfaceView;
import android.widget.FrameLayout;
import android.widget.TextView;
import android.widget.Toast;
import com.google.zxing.BinaryBitmap;
import com.google.zxing.PlanarYUVLuminanceSource;
import com.google.zxing.Result;
import com.google.zxing.common.HybridBinarizer;
import com.google.zxing.qrcode.QRCodeReader;
import org.json.JSONObject;

public class QrEnrollmentScannerActivity extends Activity
        implements SurfaceHolder.Callback, Camera.PreviewCallback {
    private static final int CAMERA_PERMISSION = 742;
    private SurfaceView surface;
    private Camera camera;
    private boolean decoded;
    private int frames;

    @Override protected void onCreate(Bundle state) {
        super.onCreate(state);
        FrameLayout root = new FrameLayout(this);
        surface = new SurfaceView(this);
        root.addView(surface, new FrameLayout.LayoutParams(
                FrameLayout.LayoutParams.MATCH_PARENT, FrameLayout.LayoutParams.MATCH_PARENT));
        TextView hint = new TextView(this);
        hint.setText("Scan BlazePwifi enrollment QR");
        hint.setTextSize(18f);
        hint.setGravity(Gravity.CENTER);
        hint.setTextColor(0xffffffff);
        hint.setBackgroundColor(0xaa000000);
        FrameLayout.LayoutParams hp = new FrameLayout.LayoutParams(
                FrameLayout.LayoutParams.MATCH_PARENT, dp(56), Gravity.BOTTOM);
        root.addView(hint, hp);
        setContentView(root);

        if (android.os.Build.VERSION.SDK_INT >= 23
                && checkSelfPermission(Manifest.permission.CAMERA) != PackageManager.PERMISSION_GRANTED) {
            requestPermissions(new String[]{Manifest.permission.CAMERA}, CAMERA_PERMISSION);
        } else {
            startSurface();
        }
    }

    private void startSurface() {
        surface.getHolder().addCallback(this);
    }

    @Override public void surfaceCreated(SurfaceHolder holder) {
        try {
            camera = Camera.open();
            camera.setPreviewDisplay(holder);
            camera.setPreviewCallback(this);
            camera.startPreview();
            try { camera.autoFocus(null); } catch (Exception ignored) {}
        } catch (Exception e) {
            Toast.makeText(this, "Camera unavailable", Toast.LENGTH_LONG).show();
            finish();
        }
    }

    @Override public void surfaceChanged(SurfaceHolder holder, int format, int width, int height) {}
    @Override public void surfaceDestroyed(SurfaceHolder holder) { stopCamera(); }

    @Override public void onPreviewFrame(byte[] data, Camera source) {
        if (decoded || data == null || (++frames % 4) != 0) return;
        try {
            Camera.Size size = source.getParameters().getPreviewSize();
            PlanarYUVLuminanceSource lum = new PlanarYUVLuminanceSource(
                    data, size.width, size.height, 0, 0, size.width, size.height, false);
            Result result = new QRCodeReader().decode(new BinaryBitmap(new HybridBinarizer(lum)));
            if (result != null && result.getText() != null) {
                decoded = true;
                handlePayload(result.getText());
            }
        } catch (Exception ignored) {}
    }

    private void handlePayload(String raw) {
        try {
            String server;
            String token;
            String name = "Rental phone";
            if (raw.trim().startsWith("{")) {
                JSONObject json = new JSONObject(raw);
                server = json.optString("server_url", "");
                token = json.optString("enrollment_token", "");
                name = json.optString("device_name", name);
            } else {
                Uri uri = Uri.parse(raw);
                if (!"blazepwifi".equalsIgnoreCase(uri.getScheme())) throw new IllegalArgumentException();
                server = uri.getQueryParameter("server");
                token = uri.getQueryParameter("token");
                String supplied = uri.getQueryParameter("name");
                if (supplied != null && supplied.length() > 0) name = supplied;
            }
            if (server == null || !(server.startsWith("http://") || server.startsWith("https://"))
                    || token == null || token.indexOf('.') <= 0) {
                throw new IllegalArgumentException();
            }
            RentalLeaseStore.saveManualEnrollment(this, server, token, name);
            final Activity self = this;
            new Thread(new Runnable() {
                @Override public void run() {
                    final boolean ok = LeaseClient.sync(self);
                    runOnUiThread(new Runnable() {
                        @Override public void run() {
                            if (ok) {
                                Toast.makeText(self, "BlazePwifi binding complete",
                                        Toast.LENGTH_LONG).show();
                                setResult(RESULT_OK);
                                finish();
                            } else {
                                decoded = false;
                                Toast.makeText(self, "Enrollment rejected; scan a fresh QR",
                                        Toast.LENGTH_LONG).show();
                            }
                        }
                    });
                }
            }).start();
        } catch (Exception e) {
            decoded = false;
            Toast.makeText(this, "Not a valid BlazePwifi enrollment QR",
                    Toast.LENGTH_SHORT).show();
        }
    }

    @Override public void onRequestPermissionsResult(int requestCode, String[] permissions,
                                                     int[] results) {
        super.onRequestPermissionsResult(requestCode, permissions, results);
        if (requestCode == CAMERA_PERMISSION && results.length > 0
                && results[0] == PackageManager.PERMISSION_GRANTED) {
            startSurface();
        } else {
            Toast.makeText(this, "Camera permission is required for QR binding",
                    Toast.LENGTH_LONG).show();
            finish();
        }
    }

    private void stopCamera() {
        if (camera == null) return;
        try { camera.setPreviewCallback(null); camera.stopPreview(); camera.release(); }
        catch (Exception ignored) {}
        camera = null;
    }

    @Override protected void onPause() {
        stopCamera();
        super.onPause();
    }

    private int dp(int value) {
        return Math.round(value * getResources().getDisplayMetrics().density);
    }
}
