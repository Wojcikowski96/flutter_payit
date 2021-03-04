package com.example.flutter_payit;

import android.content.BroadcastReceiver;
import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;

public class RunFlutterApp extends BroadcastReceiver{

    @Override
    public void onReceive(Context context, Intent intent) {

        String date = intent.getStringExtra("date");
        System.out.println("Odpalam PayIT "+date);

        Intent runIntent = new Intent(Intent.ACTION_RUN);
        runIntent.setComponent(new ComponentName("com.example.flutter_payit", "com.example.flutter_payit.MainActivity"));
        runIntent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        context.startActivity(runIntent);

        //This is used to close the notification tray
        Intent it = new Intent(Intent.ACTION_CLOSE_SYSTEM_DIALOGS);
        context.sendBroadcast(it);
    }

}

//public class RunFlutterApp extends BroadcastReceiver {
//
//    @Override
//    public void onReceive(Context context, Intent intent) {
//
//        String date = intent.getStringExtra("date");
//        System.out.println("Odpalam PayIT "+date);
//        GetMethodChannel(context).invokeMethod("launchApp",date);
//        //This is used to close the notification tray
//        //Intent it = new Intent(Intent.ACTION_CLOSE_SYSTEM_DIALOGS);
//        //context.sendBroadcast(it);
//    }
//
//    public static MethodChannel GetMethodChannel(Context context) {
//        FlutterMain.startInitialization(context);
//        FlutterMain.ensureInitializationComplete(context, new String[0]);
//
//        FlutterEngine engine = new FlutterEngine(context.getApplicationContext());
//
//        //DartExecutor.DartEntrypoint entryPoint = new DartExecutor.DartEntrypoint("lib/Main/main.dart", "launchApp");
//
//        //engine.getDartExecutor().executeDartEntrypoint(entryPoint);
//        return new MethodChannel(engine.getDartExecutor().getBinaryMessenger(), "com.example.flutter_payit");
//    }
//
//}