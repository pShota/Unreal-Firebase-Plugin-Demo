package com.pshota.firebaseunrealwrapper;

import android.app.Application;
import android.content.Context;
import android.util.Log;

import androidx.annotation.NonNull;

import com.google.android.gms.tasks.OnCompleteListener;
import com.google.android.gms.tasks.Task;
import com.google.firebase.analytics.FirebaseAnalytics;
import com.google.firebase.messaging.FirebaseMessaging;
import com.google.firebase.messaging.FirebaseMessagingService;

import java.lang.ref.WeakReference;
import java.util.HashMap;

public class FirebaseUnrealWrapper extends FirebaseMessagingService {
    public static final String NOTIFY_FCM_TOKEN_KEY = "FCM_TOKEN_KEY";
    private static FirebaseUnrealWrapper s_instance;
    private static WeakReference<Context> myContext;
    private static FirebaseAnalytics mFirebaseAnalytics;

    public static FirebaseUnrealWrapper getInstance(){
        if(s_instance==null){
            s_instance = new FirebaseUnrealWrapper();
        }
        return s_instance;
    }
    public static void firebase_init(Context context) {
        myContext = new WeakReference<Context>(context);
        mFirebaseAnalytics = FirebaseAnalytics.getInstance(context);
    }

    public static void fetchFcmToken() {
        FirebaseMessaging.getInstance().getToken()
                .addOnCompleteListener(new OnCompleteListener<String>() {
                    @Override
                    public void onComplete(@NonNull Task<String> task) {
                        if (!task.isSuccessful()) {
                            Log.w("FirebaseUnrealWrapper", "Fetching FCM registration token failed", task.getException());
                            return;
                        }

                        // Get new FCM registration token
                        String token = task.getResult();


                        Log.d("FirebaseUnrealWrapper", token);

                        HashMap<String,String> params = new HashMap<String,String>();
                        params.put(NOTIFY_FCM_TOKEN_KEY,token);

                        NotificationCenter.postNotification(myContext.get(),
                                NotificationCenter.NotificationType.onReceiveFcmToken,params);
                    }
                });
    }
    /**
     * There are two scenarios when onNewToken is called:
     * 1) When a new token is generated on initial app startup
     * 2) Whenever an existing token is changed
     * Under #2, there are three scenarios when the existing token is changed:
     * A) App is restored to a new device
     * B) User uninstalls/reinstalls the app
     * C) User clears app data
     */
    @Override
    public void onNewToken(String token) {
        HashMap<String,String> params = new HashMap<String,String>();
        params.put(NOTIFY_FCM_TOKEN_KEY,token);

        NotificationCenter.postNotification(myContext.get(),
                NotificationCenter.NotificationType.onReceiveFcmToken,params);
    }

    public static void firebaseLogEventTest() {
        mFirebaseAnalytics.logEvent(FirebaseAnalytics.Event.LOGIN,null);
    }
}
