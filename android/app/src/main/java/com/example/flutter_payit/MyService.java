package com.example.flutter_payit;

import android.app.Service;
import android.content.Intent;
import android.os.Build;
import android.os.IBinder;

import androidx.annotation.Nullable;
import androidx.core.app.NotificationCompat;

import io.flutter.view.FlutterMain;

public class MyService extends Service {

    @Override
    public void onCreate() {
        super.onCreate();
            System.out.println("MyService działa");
        if(Build.VERSION.SDK_INT >= Build.VERSION_CODES.O){
            NotificationCompat.Builder builder = new NotificationCompat.Builder(this,"messages")
                    .setContentText("PayIT")
                    .setContentTitle("PayIT działa w tle")
                    .setSmallIcon(R.drawable.app_icon);
            startForeground(101,builder.build());
        }
    }

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        System.out.println("LocalService received start id " + startId + ": " + intent);
        return START_STICKY;
    }

    @Nullable
    @Override
    public IBinder onBind(Intent intent) {
        return null;
    }
}