package com.blazesystems.blazerental;

import android.app.Notification;
import android.service.notification.NotificationListenerService;
import android.service.notification.StatusBarNotification;
import java.util.ArrayList;
import java.util.Collections;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

public class RentalNotificationService extends NotificationListenerService {
    public static final class Entry {
        public final String key;
        public final String packageName;
        public final String title;
        public final String text;
        public final long postedAt;

        Entry(String key, String packageName, String title, String text, long postedAt) {
            this.key = key;
            this.packageName = packageName;
            this.title = title;
            this.text = text;
            this.postedAt = postedAt;
        }
    }

    private static final Map<String, Entry> ACTIVE =
            Collections.synchronizedMap(new LinkedHashMap<String, Entry>());

    @Override public void onNotificationPosted(StatusBarNotification sbn) {
        Notification notification = sbn.getNotification();
        CharSequence title = notification.extras.getCharSequence(Notification.EXTRA_TITLE, "");
        CharSequence text = notification.extras.getCharSequence(Notification.EXTRA_TEXT, "");
        ACTIVE.put(sbn.getKey(), new Entry(
                sbn.getKey(), sbn.getPackageName(),
                title == null ? "" : title.toString(),
                text == null ? "" : text.toString(),
                sbn.getPostTime()));
    }

    @Override public void onNotificationRemoved(StatusBarNotification sbn) {
        ACTIVE.remove(sbn.getKey());
    }

    public static List<Entry> snapshot() {
        synchronized (ACTIVE) {
            return new ArrayList<Entry>(ACTIVE.values());
        }
    }
}
