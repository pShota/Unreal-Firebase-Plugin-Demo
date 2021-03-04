package com.pshota.firebaseunrealwrapper;


import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import androidx.localbroadcastmanager.content.LocalBroadcastManager;

import java.util.HashMap;
import java.util.Map;

public class NotificationCenter{
    public enum NotificationType{
        onReceiveFcmToken
    }

    public static void addObserver(Context context, NotificationType notification, BroadcastReceiver responseHandler) {
        LocalBroadcastManager.getInstance(context).registerReceiver(responseHandler, new IntentFilter(notification.name()));
    }

    public static void removeObserver(Context context, BroadcastReceiver responseHandler) {
        LocalBroadcastManager.getInstance(context).unregisterReceiver(responseHandler);
    }

    public static void postNotification(Context context, NotificationType notification, HashMap<String, String> params) {
        Intent intent = new Intent(notification.name());

        if(params!=null){
            // insert parameters if needed
            for(Map.Entry<String, String> entry : params.entrySet()) {
                String key = entry.getKey();
                String value = entry.getValue();
                intent.putExtra(key, value);
            }
        }
        LocalBroadcastManager.getInstance(context).sendBroadcast(intent);
    }
}
