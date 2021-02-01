package com.example.flutter_payit;
import android.app.Activity;
import android.app.AlertDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.util.Log;
import android.widget.Toast;

import com.google.firebase.database.DatabaseReference;
import com.google.firebase.database.FirebaseDatabase;

import io.flutter.app.FlutterActivity;
import io.flutter.plugin.common.MethodChannel;

import io.flutter.plugins.GeneratedPluginRegistrant;

import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Date;
import java.util.List;
import java.util.Properties;
import java.util.Set;
import java.util.concurrent.CopyOnWriteArraySet;

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


public class MainActivity extends FlutterActivity {
    private static final String CHANNEL = "name";

    @Override
    protected void onCreate(Bundle savedInstanceState) {

        super.onCreate(savedInstanceState);
        GeneratedPluginRegistrant.registerWith(this);

        new MethodChannel(getFlutterView(), CHANNEL).setMethodCallHandler((methodCall, result) -> {

            if (methodCall.method.equals("downloadAttachment")) {

                String emailAddress = methodCall.argument("emailAddress");
                String password = methodCall.argument("password");
                String host = methodCall.argument("host");
                String port = methodCall.argument("port");
                String protocol = methodCall.argument("protocol");
                Integer oldUID = methodCall.argument("newUID");
                List <String> trustedEmails = methodCall.argument("trustedEmails");
                String path =  methodCall.argument("path");
                String username = methodCall.argument("username");
                Integer counter = methodCall.argument("counter");

                MainThreadResult m = new MainThreadResult(result);

                downloadThread dt = new downloadThread(host, port, emailAddress, password, protocol, oldUID, trustedEmails, path, username, counter);
                dt.addListener(runner -> m.success("Sukces dla "+emailAddress));
                dt.start();
            }
        });
    }

    public void downloadEmailAttachments(String host, String port, String emailAddress, String password, String protocol, Integer oldUID, List<String> trustedEmails, String path, String username, int counter) {

        String callbackMessage = "Zsynchronizowano pomyślnie! " + emailAddress;

        List<Integer> allUIDS = new ArrayList<>();

        allUIDS.add(oldUID);

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
        //properties.setProperty("mail.imaps.socketFactory.class", "javax.net.ssl.SSLSocketFactory");
        //properties.setProperty("mail.imaps.socketFactory.fallback", "false");
        //properties.setProperty("mail.imaps.socketFactory.port", String.valueOf(port));
        properties.put(String.format("mail.ssl.%s.enable", protocolPart), "true");
        //properties.put("mail.debug", "true");

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

            //Procedura do sprawdzenia jak nazywa się folder spamu w skrzynce, wydzielić w funkcję
            String mySpamFolderName = "SPAM";

            String[] spamFolderNames = {"Junk", "Spam", "JUNK", "SPAM"};
            for (String spamFolderName : spamFolderNames) {
                for (Folder folder : store.getDefaultFolder().list()) {
                    if (spamFolderName.equals(folder.getName())) {
                        mySpamFolderName = spamFolderName;
                    }
                }
            }

            Folder folderSpam = store.getFolder(mySpamFolderName);

            //System.out.println("store.getDefaultFolder() dla konta "+emailAddress+ " " + Arrays.toString(store.getDefaultFolder().list()) +" sraka");

            folderInbox.open(Folder.READ_ONLY);
            folderSpam.open(Folder.READ_ONLY);

            //System.out.println("Username w Java "+username);
            //System.out.println("Emailkey "+emailAddress.replace(".",""));

            ref = FirebaseDatabase.getInstance().getReference().child("Users").child(username).child("myEmails").child(emailAddress.replace(".", "")).child("lastUID");

            //System.out.println("Last seen UID "+oldUID);
            // fetches new messages from server
            Message[] arrayMessages = ((UIDFolder) folderInbox).getMessagesByUID(oldUID + 1, UIDFolder.MAXUID);
            //Message[] arraySpamMessages = ((UIDFolder)folderSpam).getMessagesByUID(lastSeenSpam + 1, UIDFolder.MAXUID);

            //Message[] arrayMessages = JavaUtils.concatenate(arrayInboxMessages,arraySpamMessages);

            //System.out.println("Liczba maili dla skrzynki " + emailAddress+ " wynosi "+ arrayMessages.length + "MAXUID: " +UIDFolder.MAXUID);

            for (int i = 0; i < arrayMessages.length; i++) {

                Message message = arrayMessages[i];
                //System.out.println("Email numer" + i + " UID "+ (int) ((UIDFolder) folderInbox).getUID(message));

                Address[] fromAddress = message.getFrom();

                String from = fromAddress[0].toString();
                Date messageDate = message.getSentDate();

                int newUID = (int) ((UIDFolder) folderInbox).getUID(message);
                allUIDS.add(newUID);

                for (int t = 0; t < trustedEmails.size(); t++) {
                    //System.out.println("Różnica ile dni :");
                    //System.out.println(((System.currentTimeMillis())-messageDate.getTime())/(86400000));
                    if (from.contains(trustedEmails.get(t)) && ((System.currentTimeMillis()) - messageDate.getTime()) / (86400000) <= 30) {

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
                                    // this part is attachment
                                    String fileName = emailAddress + ";" + trustedEmails.get(t) + ";" + sentDate + ".pdf";
                                    attachFiles += fileName + ", ";
                                    //File directory = new File(getCacheDir().toString()+File.separator+"invoicesPDF");
                                    //directory.mkdirs();
                                    System.out.println("Path w Javie: " + path);
                                    part.saveFile(path + File.separator + fileName);
                                } else {
                                    // this part may be the message content
                                    messageContent = part.getContent().toString();
                                }
                            }

                            if (attachFiles.length() > 1) {
                                attachFiles = attachFiles.substring(0, attachFiles.length() - 2);
                            }
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
            System.out.println("UID dla: " + emailAddress + ": " + maxUID);
            ref.setValue(maxUID);
            // disconnect
            folderInbox.close(false);
            store.close();

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
        System.out.println("Rozłączam się " + emailAddress);

        if (counter == 0) {
            Activity thisActivity = this;
            String finalCallbackMessage = callbackMessage;
            thisActivity.runOnUiThread(() -> popupMessage(finalCallbackMessage, allUIDS.get(allUIDS.size()-1)));
        }
    }

    private Integer findLatestUID(List<Integer> allUIDS) {

        if (allUIDS == null || allUIDS.size() == 0) {
            return Integer.MIN_VALUE;
        }
        List<Integer> sortedList = new ArrayList<>(allUIDS);
        Collections.sort(sortedList);
        return sortedList.get(sortedList.size() - 1);
    }

    public void popupMessage(String finalCallbackMessage, int UID){
        AlertDialog.Builder alertDialogBuilder = new AlertDialog.Builder(this);
        alertDialogBuilder.setMessage(finalCallbackMessage);
        if(UID !=0){
            alertDialogBuilder.setTitle("Sukces!: ");
        }else{
            alertDialogBuilder.setTitle("Nieprawidłowy login lub hasło: ");
        }
        AlertDialog alertDialog = alertDialogBuilder.create();
        alertDialogBuilder.setNegativeButton("Rozumiem", new DialogInterface.OnClickListener(){

            @Override
            public void onClick(DialogInterface dialogInterface, int i) {
                alertDialog.dismiss();
            }
        });
        alertDialog.show();
    }

    public class downloadThread extends Thread {

        private final java.util.List<TaskListener> listeners = Collections.synchronizedList( new ArrayList<TaskListener>() );

        void addListener(TaskListener listener){
            listeners.add(listener);
        }

        public void removeListener( TaskListener listener ){
            listeners.remove(listener);
        }

        private void notifyListeners() {
            synchronized ( listeners ){
                for (TaskListener listener : listeners) {
                    listener.threadComplete(this);
                }
            }
        }

        private String host, port, userName, password, protocol, path, username;
        private int newUID;
        private List<String> trustedEmails;
        private int counter;
        downloadThread(String host, String port, String userName, String password, String protocol, Integer newUID, List<String> trustedEmails, String path, String username, int counter) {
            this.host=host;
            this.port = port;
            this.userName=userName;
            this.password=password;
            this.protocol=protocol;
            this.newUID =newUID;
            this.trustedEmails=trustedEmails;
            this.path=path;
            this.username=username;
            this.counter=counter;
        }

        public void run() {
            downloadEmailAttachments(host, port, userName, password, protocol, newUID, trustedEmails,path, username, counter);
            notifyListeners();
        }
    }
}

interface TaskListener {
    void threadComplete(Runnable runner);
}

