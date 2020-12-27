import 'dart:async';
import 'dart:core';
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
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () async {
      String username = (await storage.read(key: "username")).toString();
      downloadAttachmentForAllMailboxes(username);
      //timer = Timer.periodic(Duration(seconds: 360), (Timer t) => refreshEmails(username));
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
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => TimeInterval()));
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

  downloadAttachmentForAllMailboxes(String username) async {
    List<List<String>> emailSettings =
        await UserOperationsOnEmails().getEmailSettings(username);

    for (var singleEmailSettings in emailSettings)
     {
       //sleep(Duration(seconds: 30));
       print("Single email w downloadattachmentforallemailboxes przed przekazaniem do funkcji: ");
       print(singleEmailSettings);
       await downloadAttachment(singleEmailSettings);
     }

  }

  Future<void> downloadAttachment(List<String> emailSettings) async {
    String sth;
    print("downloadAttachment zaczete");
    try {
      sth = await platform.invokeMethod("downloadAttachment", {
        "username": emailSettings[0],
        "password": emailSettings[1],
        "host": emailSettings[2],
        "port": emailSettings[3],
        "protocol": emailSettings[4]
      });
      print("downloadAttachment skonczone");
    } catch (e) {
      print("Wywołanie nie zadziałało" + e);
    }
    print("Sth "+sth);
  }
}
