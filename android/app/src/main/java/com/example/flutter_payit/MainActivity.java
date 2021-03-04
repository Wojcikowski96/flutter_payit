package com.example.flutter_payit;

import android.app.AlertDialog;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import android.os.Build;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;

import androidx.annotation.RequiresApi;

import com.google.firebase.database.DatabaseReference;
import com.google.firebase.database.FirebaseDatabase;

import io.flutter.app.FlutterActivity;
import io.flutter.plugin.common.MethodChannel;

import io.flutter.plugins.GeneratedPluginRegistrant;

import java.io.File;
import java.io.IOException;
import java.text.Normalizer;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.Properties;
import java.util.Random;
import java.util.Timer;
import java.util.TimerTask;
import java.util.concurrent.atomic.AtomicBoolean;
import java.util.function.BiConsumer;

import javax.mail.Address;
import javax.mail.AuthenticationFailedException;
import javax.mail.Authenticator;
import javax.mail.Folder;
import javax.mail.Message;
import javax.mail.MessagingException;
import javax.mail.Multipart;
import javax.mail.NoSuchProviderException;
import javax.mail.Part;
import javax.mail.PasswordAuthentication;
import javax.mail.Session;
import javax.mail.Store;
import javax.mail.UIDFolder;
import javax.mail.internet.MimeBodyPart;
import javax.mail.internet.MimeUtility;


public class MainActivity extends FlutterActivity {
    public static final int NOTIFICATION_ID = 666;
    private static final String CHANNEL = "com.example.flutter_payit";

    private Intent forService;
    private MethodChannel methodChannel;

    Map<String, DownloadThread> threadMap = new HashMap<>();
    private Timer downloadTimer;
    private Timer remindingTimer;

    @RequiresApi(api = Build.VERSION_CODES.O)
    @Override
    protected void onCreate(Bundle savedInstanceState) {

        super.onCreate(savedInstanceState);
        System.out.println("Java onCreate");
        createNotificationChanel();

        GeneratedPluginRegistrant.registerWith(this);
        forService = new Intent(this, MyService.class);
        methodChannel = new MethodChannel(getFlutterView(), CHANNEL);
        methodChannel.setMethodCallHandler((methodCall, result) -> {
            System.out.println("new MethodChannel ID wątku "+Thread.currentThread().getId()+" methodCall.method "+methodCall.method);

            switch (methodCall.method) {
                case "downloadAttachment":

                    String emailAddress = methodCall.argument("emailAddress");
                    String password = methodCall.argument("password");
                    String host = methodCall.argument("host");
                    String port = methodCall.argument("port");
                    String protocol = methodCall.argument("protocol");
                    List<String> trustedEmails = methodCall.argument("trustedEmails");
                    String path = methodCall.argument("path");
                    String username = methodCall.argument("username");
                    Integer frequency = methodCall.argument("frequency");
                    System.out.println("-------------------------------------------------------------------------------------------");

                    downloadTimer = new Timer();
                    downloadTimer.scheduleAtFixedRate(new TimerTask() {
                        @Override
                        public void run() {

                            JavaDatabaseOperations.getUIDFromDB(username, emailAddress, UID -> {

                                System.out.println("UID z bazy "+UID);
                                if (threadMap.get(emailAddress)==null || !threadMap.get(emailAddress).isAlive()) {
                                    DownloadThread thread = new DownloadThread(host, port, emailAddress, password, protocol, UID, trustedEmails, path, username, MainActivity.this);
                                    thread.start();
                                    threadMap.put(emailAddress,thread);
                                }
                            });
                        }
                    }, 0, frequency * 1000);
                    break;
                case "startService":
                    startService();
                    //moveTaskToBack(true);
                    result.success("Service Started");
                    break;
                case "stopService":
                    stopService(forService);
                    result.success("Service Stopped");
                    break;
                case "startMonitoringUrgentPayment":
                    String date = methodCall.argument("paymentDate");
                    String categoryName = methodCall.argument("categoryName");
                    String senderMail  = methodCall.argument("senderMail");
                    int remindFreq = methodCall.argument("remindFreq");
                    startReminding(this, date, categoryName, senderMail, remindFreq);
                    break;
                case "stopThreadsAndTimers":
                    stopThreadsAndTimers();
                    break;
            }
        });
    }

    @Override
    protected void onDestroy() {

        System.out.println("Java onDestroy");
        super.onDestroy();
    }

    void stopThreadsAndTimers() {

        System.out.println("Stop Java");
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            threadMap.forEach((k,v) -> v.interrupt());
            threadMap.forEach((k,v) -> System.out.println("Wątek " + v.getId()+ " żyje? "+v.isAlive()+ " status "+v.isInterrupted()));
        }
        if (downloadTimer!=null)
        downloadTimer.cancel();
        if (remindingTimer!=null)
        remindingTimer.cancel();


    }

    private void startReminding(Context context, String date, String categoryName, String senderMail, int remindFreq) {
        long period = Math.round((24.0/remindFreq)*60*60*1000);
        System.out.println("Period "+period);
        remindingTimer = new Timer();
        remindingTimer.scheduleAtFixedRate(new TimerTask() {
            @RequiresApi(api = Build.VERSION_CODES.O)
            @Override
            public void run() {

                if (LocalDate.now().getDayOfYear()-LocalDate.parse(date).getDayOfYear()<=0) {
                        CreateReminderNotification(context, senderMail, categoryName, date);
                }
                else {
                    CreateOverdueNotification(context, senderMail, categoryName, date);
                };
            }
        }, 0, period);
    }

    private void createNotificationChanel() {
        if(Build.VERSION.SDK_INT >= Build.VERSION_CODES.O){
            NotificationChannel channel = new NotificationChannel("messages","PayIT", NotificationManager.IMPORTANCE_LOW);
            NotificationManager manager = getSystemService(NotificationManager.class);
            assert manager != null;
            manager.createNotificationChannel(channel);
        }
    }

    public void downloadEmailAttachments(String host, String port, String emailAddress, String password, String protocol, int UID, List<String> trustedEmails, String path, String username, Context context) {

        File tempDir = new File(path.replaceAll("invoicesPDF","Temp"));
        tempDir.mkdirs();

        String callbackMessage = "Zsynchronizowano pomyślnie! " + emailAddress;

        List<Integer> allUIDS = new ArrayList<>();

        allUIDS.add(UID);

        DatabaseReference ref;

        System.setProperty("mail.mime.decodeparameters", "false");

        String protocolPart = "";

        if (protocol.equals("ServerType.pop"))
            protocolPart = "pop3s";
        else if (protocol.equals("ServerType.imap"))
            protocolPart = "imaps";

        Properties properties = new Properties();

        // server setting
        properties.put(String.format("mail.%s.host", protocolPart), host);
        properties.put(String.format("mail.%s.port", protocolPart), port);
        properties.put(String.format("mail.%s.auth", protocolPart), "true");

        // SSL setting
        properties.put(String.format("mail.ssl.%s.enable", protocolPart), "true");

        Session session = Session.getInstance(properties, new Authenticator() {
            public PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(emailAddress, password);
            }
        });

        try {
            // connects to the message store
            Store store = session.getStore(protocolPart);
            store.connect(emailAddress, password);

            // opens the inbox folder
            Folder folderInbox = store.getFolder("INBOX");

            folderInbox.open(Folder.READ_ONLY);

            ref = FirebaseDatabase.getInstance().getReference().child("Users").child(username).child("myEmails").child(emailAddress.replace(".", "")).child("lastUID");

            // fetches new messages from server
            Message[] arrayMessages = ((UIDFolder) folderInbox).getMessagesByUID(UID + 1, UIDFolder.MAXUID);

            for (int i = 0; i < arrayMessages.length; i++) {

                Message message = arrayMessages[i];
                System.out.println("Email numer" + i + " UID "+ (int) ((UIDFolder) folderInbox).getUID(message) + "adres: "+ emailAddress);

                int finalI = i;
                new Handler(Looper.getMainLooper()).post(() -> methodChannel.invokeMethod("syncStarted", emailAddress + " postęp "+Math.round(((double) finalI / (double) arrayMessages.length)*100.0)+"%", null));

                Address[] fromAddress = message.getFrom();

                String from = fromAddress[0].toString();
                Date messageDate = message.getSentDate();

                int newUID = (int) ((UIDFolder) folderInbox).getUID(message);
                allUIDS.add(newUID);

                for (int t = 0; t < trustedEmails.size(); t++) {

                    if (from.contains(trustedEmails.get(t)) && ((System.currentTimeMillis()) - messageDate.getTime()) / (86400000) <= 365) {

                        System.out.println("Znaleziono wiadomość od: " + trustedEmails.get(t));
                        String subject = message.getSubject();
                        String sentDate = message.getSentDate().toString();

                        System.out.println("Wiadomość od: " + from);
                        System.out.println("Wiadomość przyszła na adres: " + message.getRecipients(Message.RecipientType.TO)[0].toString());
                        System.out.println("Data wysłania: " + sentDate);

                        String contentType = message.getContentType();
                        String messageContent = "";

                        // store attachment file name, separated by comma
                        String attachFiles = "";

                        if (contentType.contains("multipart")) {
                            // content may contain attachments
                            Multipart multiPart = (Multipart) message.getContent();
                            int numberOfParts = multiPart.getCount();
                            for (int partCount = 0; partCount < numberOfParts; partCount++) {
                                MimeBodyPart part = (MimeBodyPart) multiPart.getBodyPart(partCount);

                                if (Part.ATTACHMENT.equalsIgnoreCase(part.getDisposition())) {
                                    String decodedFileName = MimeUtility.decodeText(part.getFileName());
                                    Normalizer.normalize(decodedFileName, Normalizer.Form.NFC);
                                    if (decodedFileName.contains("pdf")) {
                                        String fileName = emailAddress + ";" + trustedEmails.get(t) + ";" + sentDate + ";"+decodedFileName;
                                        attachFiles += fileName + ", ";
                                        part.saveFile(path.replaceAll("invoicesPDF","Temp") + File.separator+ fileName);
                                    }
                                } else {
                                    // this part may be the message content
                                    messageContent = part.getContent().toString();
                                }
                            }

                            if (attachFiles.length() > 1) {
                                attachFiles = attachFiles.substring(0, attachFiles.length() - 2);
                            }

                            CreateNewInvoiceNotification(emailAddress, trustedEmails, context, t, sentDate);

                        } else if (contentType.contains("text/plain")
                                || contentType.contains("text/html")) {
                            Object content = message.getContent();
                            if (content != null) {
                                messageContent = content.toString();
                            }
                        }

                        // print out details of each message
                        System.out.println("Message #" + (i + 1) + ":");
                        System.out.println("\t From: " + from);
                        System.out.println("\t Subject: " + subject);
                        System.out.println("\t Sent Date: " + sentDate);
                        System.out.println("\t Message: " + messageContent);
                        System.out.println("\t Attachments: " + attachFiles);
                        //message.setFlag(Flags.Flag.SEEN, true);
                    }
                }
            }
            Integer maxUID = findLatestUID(allUIDS);
            //System.out.println("UID dla: " + emailAddress + ": " + maxUID);
            ref.setValue(maxUID);
            // disconnect
            folderInbox.close(false);
            store.close();

            moveFilesFromTemp(path);

        } catch (NoSuchProviderException ex) {
            System.out.println("No provider for imaps.");
            ex.printStackTrace();
        } catch (AuthenticationFailedException ex) {
            callbackMessage = "Nieudane połączenie ze skrzynką " + emailAddress + ", być może problem dotyczy poprawności danych logowania. Sprawdź czy podałeś poprawny login i hasło i dodaj tę skrzynkę ponownie.";
            ex.printStackTrace();
        } catch (MessagingException ex) {
            System.out.println("Could not connect to the message store");
            ex.printStackTrace();
        } catch (IOException ex) {
            ex.printStackTrace();
        }

        CreateNewFinishedSyncNotification(emailAddress, UID, context);
        new Handler(Looper.getMainLooper()).post(() -> methodChannel.invokeMethod("syncCompleted",emailAddress,null));

    }

    private void CreateNewFinishedSyncNotification(String emailAddress, int UID, Context context) {
        NotificationManager notificationManager =
                (NotificationManager) getSystemService(Context.NOTIFICATION_SERVICE);
        if(UID == 0){
            notificationManager.notify((new Random()).nextInt(Integer.MAX_VALUE), MyNotifications.notifyOnFinishSync(context,emailAddress).build());
        }
    }

    private void CreateReminderNotification(Context context, String emailAddress, String category, String date) {
        NotificationManager notificationManager =
                (NotificationManager) getSystemService(Context.NOTIFICATION_SERVICE);
        Intent forRunApp = new Intent(context, RunFlutterApp.class);
        forRunApp.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK| Intent.FLAG_ACTIVITY_CLEAR_TASK);
        forRunApp.putExtra("date",date);
        PendingIntent forRunAppPending = PendingIntent.getBroadcast(context, 0, forRunApp, PendingIntent.FLAG_ONE_SHOT);
        notificationManager.notify(2, MyNotifications.remindForPay(context,emailAddress, category, date, forRunAppPending).build());
    }

    private void CreateOverdueNotification(Context context, String emailAddress, String category, String date) {
        NotificationManager notificationManager =
                (NotificationManager) getSystemService(Context.NOTIFICATION_SERVICE);
        Intent forRunApp = new Intent(context, RunFlutterApp.class);
        forRunApp.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK| Intent.FLAG_ACTIVITY_CLEAR_TASK);
        forRunApp.putExtra("date",date);
        PendingIntent forRunAppPending = PendingIntent.getBroadcast(context, 0, forRunApp, PendingIntent.FLAG_ONE_SHOT);
        notificationManager.notify(3, MyNotifications.remindForOverdue(context,emailAddress, category, date, forRunAppPending).build());
    }

    private void CreateNewInvoiceNotification(String emailAddress, List<String> trustedEmails, Context context, int t, String sentDate) {
        NotificationManager notificationManager =
                (NotificationManager) getSystemService(Context.NOTIFICATION_SERVICE);
        Intent forRunApp = new Intent(context, RunFlutterApp.class);
        forRunApp.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK| Intent.FLAG_ACTIVITY_CLEAR_TASK);
        forRunApp.putExtra("date",sentDate);
        PendingIntent forRunAppPending = PendingIntent.getBroadcast(context, 0, forRunApp, PendingIntent.FLAG_ONE_SHOT);
        notificationManager.notify(4, MyNotifications.notifyOnNewInvoice(context, trustedEmails.get(t), sentDate, emailAddress, forRunAppPending).build());
    }

    private void moveFilesFromTemp(String path) {
        File tempDir = new File(path.replaceAll("invoicesPDF","Temp"));
        List<File> tempFiles = listFilesForFolder(tempDir);

        for(File myFile : tempFiles){
            myFile.renameTo(new File(path+File.separator+myFile.getName()));
        }

        //tempDir.delete();
    }

    private Integer findLatestUID(List<Integer> allUIDS) {

        if (allUIDS == null || allUIDS.size() == 0) {
            return Integer.MIN_VALUE;
        }
        List<Integer> sortedList = new ArrayList<>(allUIDS);
        Collections.sort(sortedList);
        return sortedList.get(sortedList.size() - 1);
    }

    public class DownloadThread extends Thread {

        private String host, port, emailAddress, password, protocol, path, username;
        private int UID;
        private List<String> trustedEmails;
        private Context context;

        DownloadThread(String host, String port, String emailAddress, String password, String protocol, Integer UID, List<String> trustedEmails, String path, String username, Context context) {
            this.host=host;
            this.port = port;
            this.emailAddress=emailAddress;
            this.password=password;
            this.protocol=protocol;
            this.UID =UID;
            this.trustedEmails=trustedEmails;
            this.path=path;
            this.username=username;
            this.context=context;
        }

        public void run() {
                downloadEmailAttachments(host, port, emailAddress, password, protocol, UID, trustedEmails, path, username, context);
        }
    }

     public List <File> listFilesForFolder(final File folder) {

        List<File> files = new ArrayList<>();

        if (folder.listFiles()!=null) {
            for (final File fileEntry : Objects.requireNonNull(folder.listFiles())) {
                if (fileEntry.isDirectory()) {
                    listFilesForFolder(fileEntry);
                } else {
                    System.out.println(fileEntry.getName());
                    files.add(fileEntry);
                }
            }
        }
        return files;
    }

    private void startService(){
        if(Build.VERSION.SDK_INT >= Build.VERSION_CODES.O){
            startForegroundService(forService);
        } else {
            startService(forService);
        }
    }
}

