package com.example.flutter_payit;
import android.os.Bundle;

import io.flutter.app.FlutterActivity;
import io.flutter.plugin.common.MethodChannel;

import io.flutter.plugins.GeneratedPluginRegistrant;

import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.Properties;

import javax.mail.Address;
import javax.mail.Authenticator;
import javax.mail.Flags;
import javax.mail.Folder;
import javax.mail.Message;
import javax.mail.MessagingException;
import javax.mail.Multipart;
import javax.mail.NoSuchProviderException;
import javax.mail.Part;
import javax.mail.PasswordAuthentication;
import javax.mail.Session;
import javax.mail.Store;
import javax.mail.internet.MimeBodyPart;
import javax.mail.search.FlagTerm;
import javax.mail.search.FromStringTerm;

public class MainActivity extends FlutterActivity {
    private static final String CHANNEL = "name";
    //private boolean isThreadDone = false;
    List<Thread> threadList = new ArrayList<>();

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        System.out.println("On create java");
        super.onCreate(savedInstanceState);
        GeneratedPluginRegistrant.registerWith(this);
        new MethodChannel(getFlutterView(), CHANNEL).setMethodCallHandler((methodCall, result) -> {
            if (methodCall.method.equals("downloadAttachment")) {

                //isThreadDone = false;

                String username = methodCall.argument("username");
                String password = methodCall.argument("password");
                String host = methodCall.argument("host");
                String port = methodCall.argument("port");
                String protocol = methodCall.argument("protocol");

                Thread t = new Thread(new downloadThread(host, port, username, password, protocol));
                t.start();

                while (true) {
                    if (!t.isAlive()) {
                        result.success("Sukces dla " + username);
                        break;
                    }
                }
            }
        });
    }

    public void downloadEmailAttachments(String host, String port, String userName, String password, String protocol) {

        String protocolPart="";

        if (protocol.equals("ServerType.pop"))
            protocolPart="pop3s";
        else if (protocol.equals("ServerType.imap"))
            protocolPart="imaps";

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
        properties.put("mail.debug", "true");

        Session session = Session.getInstance(properties, new Authenticator(){
            public PasswordAuthentication getPasswordAuthentication(){
                return new PasswordAuthentication(userName,password);
            }
        });

        try {
            System.out.println("Username: "+userName);
            System.out.println("Password: "+password);
            System.out.println("Host: "+host);
            System.out.println("Port: "+port);

            // connects to the message store
            Store store = session.getStore(protocolPart);
            store.connect(userName, password);

            // opens the inbox folder
            Folder folderInbox = store.getFolder("INBOX");

            System.out.println("store.getDefaultFolder() dla konta "+userName+ " " + Arrays.toString(store.getDefaultFolder().list()) +" sraka");

            folderInbox.open(Folder.READ_ONLY);

            // fetches new messages from server
            Message[] arrayMessages = folderInbox.getMessages();

            System.out.println("Liczba wiadomości od kamil_wojcikowski@tdi.com.pl "+arrayMessages.length + " na skrzynce "+userName);

            for (int i = arrayMessages.length-1; i > arrayMessages.length-Math.min(arrayMessages.length,10); i--) {

                Message message = arrayMessages[i];
                Address[] fromAddress = message.getFrom();

                String from = fromAddress[0].toString();

                if (from.contains("kamil_wojcikowski@tdi.com.pl")) {
                    String subject = message.getSubject();
                    String sentDate = message.getSentDate().toString();

                    System.out.println("Wiadomość od: "+from);
                    System.out.println("Wiadomość przyszła na adres: "+message.getRecipients(Message.RecipientType.TO) [0].toString());
                    System.out.println("Data wysłania: "+sentDate);

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
                                String fileName = part.getFileName();
                                attachFiles += fileName + ", ";
                                part.saveFile(getCacheDir().toString() + File.separator + fileName);
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
                    //System.out.println("\t Message: " + messageContent);
                    System.out.println("\t Attachments: " + attachFiles);
                }

                }

            // disconnect
            folderInbox.close(false);
            store.close();

        } catch (NoSuchProviderException ex) {
            System.out.println("No provider for imaps.");
            ex.printStackTrace();
        } catch (MessagingException ex) {
            System.out.println("Could not connect to the message store");
            ex.printStackTrace();
        } catch (IOException ex) {
            ex.printStackTrace();
        }
        System.out.println("Rozłączam się "+userName);
        //isThreadDone = true;
    }

    public class downloadThread implements Runnable {

        private String host, port, userName, password, protocol;

        downloadThread(String host, String port, String userName, String password, String protocol) {
            this.host=host;
            this.port = port;
            this.userName=userName;
            this.password=password;
            this.protocol=protocol;
        }

        public void run() {
            downloadEmailAttachments(host, port, userName, password, protocol);
        }
    }
}
