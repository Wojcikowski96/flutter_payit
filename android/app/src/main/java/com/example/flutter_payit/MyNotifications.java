package com.example.flutter_payit;

import android.app.PendingIntent;
import android.content.Context;
import android.os.Build;
import androidx.core.app.NotificationCompat;

class MyNotifications {

    static NotificationCompat.Builder notifyOnNewInvoice(Context context, String sender, String date, String emailAddress, PendingIntent intent) {

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            return new NotificationCompat.Builder(context, "messages")
                    .setContentTitle("Nowa faktura")
                    .setStyle(new NotificationCompat.BigTextStyle()
                            .bigText("Nowa faktura od "+sender+" przysłana dnia "+date+" na adres "+ emailAddress))
                    .setSmallIcon(R.drawable.app_icon)
                    .addAction(R.drawable.app_icon, "Do kalendarza", intent);

        } else {
            return null;
        }

    }


    static NotificationCompat.Builder notifyOnFinishSync(Context context, String emailAddress) {

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            return new NotificationCompat.Builder(context, "messages")
                    .setContentText("Przejdź do kalendarza")
                    .setStyle(new NotificationCompat.BigTextStyle()
                            .bigText("Zakończono pierwszą synchronizacje dla skrzynki: "+ emailAddress))
                    .setSmallIcon(R.drawable.app_icon);
        } else {
            return null;
        }

    }

    static NotificationCompat.Builder remindForPay(Context context, String emailAddress, String categoryName, String paymentDate, PendingIntent intent) {

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            return new NotificationCompat.Builder(context, "messages")
                    .setContentTitle("Faktura od: " +categoryName)
                    .setContentText("Pokaż w kalendarzu")
                    .setStyle(new NotificationCompat.BigTextStyle()
                            .bigText("Z adresu: "+emailAddress+ " opłać do: "+paymentDate))
                    .setSmallIcon(R.drawable.app_icon)
                    .setColor(0xff0000)
                    .addAction(R.drawable.app_icon, "Do kalendarza", intent);

        } else {
            return null;
        }

    }
}