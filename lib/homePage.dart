import 'dart:async';
import 'dart:io';
import 'package:enough_mail/enough_mail.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_payit/registerPage.dart';
import 'package:flutter_payit/timeInterval.dart';
import 'package:flutter_payit/trustedList.dart';
import 'package:flutter_payit/urgentPay.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/services.dart';
import 'emailBoxesPanel.dart';
import 'mediumUrgentPay.dart';
import 'notUrgentPay.dart';
import 'userOperationsOnEmails.dart';

class homePage extends StatefulWidget {
  @override
  _homePageState createState() => _homePageState();
}

class _homePageState extends State<homePage> {
  var storage = FlutterSecureStorage();
  static const platform = const MethodChannel("name");
  Timer timer;
  List<String> userEmails;
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () async {
      String username = (await storage.read(key: "username")).toString();
      //List<String> userEmails = await UserOperationsOnEmails().getLoggedUserData(username);
      timer = Timer.periodic(Duration(seconds: 10), (Timer t) => refreshEmails(username));

    });

  }
  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    PageController pageController = PageController(initialPage: 0);

    return Scaffold(
      backgroundColor: Colors.blue,
      body: PageView(
        controller: pageController,
        children: [
          urgentPay(pageController: pageController),
          mediumUrgentPay(pageController: pageController),
          notUrgentPay(pageController: pageController),
        ],
      ),
      drawer: Drawer(
        // Add a ListView to the drawer. This ensures the user can scroll
        // through the options in the drawer if there isn't enough vertical
        // space to fit everything.
        child: ListView(
          // Important: Remove any padding from the ListView.
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              child: Text('Username'),
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
            ),
            ListTile(
              title: Text('Zarządzaj adresami e-mail'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => EmailBoxesPanel()),
                );
              },
            ),

            ListTile(
              title: Text('Edytuj zaufaną listę nadawców faktur'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => TrustedListPanel()),
                );
              },
            ),

            ListTile(
              title: Text('Ustawienia'),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => TimeInterval())
                );
              },
            ),
            ListTile(
              title: Text('O aplikacji'),
              onTap: () {
                // Update the state of the app
                // ...
                // Then close the drawer
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      appBar: AppBar(
          // leading: IconButton(icon: Icon(Icons.menu), onPressed: (){
          //
          // }),
          title: Text("PayIT"),
          actions: <Widget>[
            IconButton(
                icon: Icon(Icons.people),
                onPressed: () {
                  Scaffold.of(context).showSnackBar(
                      new SnackBar(content: Text('Yay! A SnackBar!')));
                })
          ]),
    );
  
  }
  refreshEmails(String username) async {
    List<String> tempEmails = new List();
    tempEmails = await UserOperationsOnEmails().getLoggedUserData(username);
    
    setState(() {
      userEmails = tempEmails;
    });
    print("Lista maili w homeScreen "+userEmails.toString());

    //await discoverSettings('kamil.wojcikowski@wp.pl');
    //await imap();
    downloadAttachment();

  }

  Future<void> discoverSettings(String email) async {
    var config = await Discover.discover(email, isLogEnabled: true);
    if (config == null) {
      print('Unable to discover settings for $email');
    } else {
      print('Settings for $email:');
      for (var provider in config.emailProviders) {
        print('provider: ${provider.displayName}');
        print('provider-domains: ${provider.domains}');
        print('documentation-url: ${provider.documentationUrl}');
        print('Incoming:');
        print(provider.preferredIncomingServer);
        print('Outgoing:');
        print(provider.preferredOutgoingServer);
      }
    }
  }

  Future<void> imap() async {
    var client = ImapClient(isLogEnabled: false);
    await client.connectToServer('imap.poczta.onet.pl', 993, isSecure: true);
    var loginResponse = await client.login('einfall@vp.pl', 'K0nt00n3t');
    if (loginResponse.isOkStatus) {
      var listResponse = await client.listMailboxes();
      if (listResponse.isOkStatus) {
        print('mailboxes: ${listResponse.result}');
      }
      var inboxResponse = await client.selectInbox();
      if (inboxResponse.isOkStatus) {
        // fetch 10 most recent messages:
        var fetchResponse = await client.fetchRecentMessages(
            messageCount: 1, criteria: 'BODY.PEEK[]');
        if (fetchResponse.isOkStatus) {
          var messages = fetchResponse.result.messages;
          for (var message in messages) {
            printMessage(message);
          }
        }
      }
      await client.logout();
    }
  }
  void printMessage(MimeMessage message) {
    print('from: ${message.from} with subject "${message.decodeSubject()}"');
    if (!message.isTextPlainMessage()) {
      print(' content-type: ${message.mediaType}');
    } else {
      var plainText = message.decodeTextPlainPart();
      if (plainText != null) {
        var lines = plainText.split('\r\n');
        for (var line in lines) {
          if (line.startsWith('>')) {
            // break when quoted text starts
            break;
          }
          print(line);
        }
      }
    }
  }

  void downloadAttachment() async {
    String sth;
    try{
    sth = await platform.invokeMethod("downloadAttachment");
    }catch(e){
      print("Wywołanie nie zadziałało" + e);
    }
    print(sth);

  }
}
