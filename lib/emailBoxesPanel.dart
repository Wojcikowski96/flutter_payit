import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:firebase_database/firebase_database.dart';

class EmailBoxesPanel extends StatefulWidget {
  @override
  _EmailBoxesPanelState createState() => _EmailBoxesPanelState();
}

class _EmailBoxesPanelState extends State<EmailBoxesPanel> {
  var storage = FlutterSecureStorage();
  String username = "JohnDoe", password = "qwerty";
  List<Container> emailPanels = new List();

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () async {
      String tempUsername = (await storage.read(key: "username")).toString();
      String tempPassword = (await storage.read(key: "password")).toString();
      List<Container> tempEmailPanels=await getLoggedUserData();

      setState(() {
        username = tempUsername;
        password = tempPassword;
        emailPanels = tempEmailPanels;
      });
    });

  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
        body: Column(children: [
      Expanded(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: ListView(
            children:
                List.generate(emailPanels.length, (index) => emailPanels[index]),
          ),
        ),
      ),
      FlatButton(
        color: Colors.grey.withOpacity(0.7),
        splashColor: Colors.blue,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18.0),
            side: BorderSide(color: Colors.black)),
        onPressed: () {
          getLoggedUserData();
        },
        focusColor: Colors.grey,
        child: Column(
          children: <Widget>[
            Icon(
              Icons.add,
              color: Colors.white,
            ),
            Text(
              "Dodaj swój e-mail",
              style: TextStyle(fontSize: 20, color: Colors.white),
            )
          ],
        ),
      )
    ]));
  }

  Container emailPanel(String email) {
    return new Container(
      height: 80,

      decoration: BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
      child: Center(
        child: Text(
          email,
          style: TextStyle(fontSize: 40, color: Colors.white),
        ),
      ),
    );
  }

  Future<List<Container>> getLoggedUserData() async {
    List<String> myEmails = new List();
    List<Container> emailPanels = new List();

    final dbSnapshot = await FirebaseDatabase.instance
        .reference()
        .child("Users")
        .child(username)
        .child("myEmails").once();
    int i = 0;

      Map<dynamic, dynamic> values = dbSnapshot.value;
      values.forEach((key, values) {
        i++;
        if (key.toString() == "email" + i.toString())
          myEmails.add(values.toString());
      });

      for (var email in myEmails) {
        emailPanels.add(emailPanel(email));
      }

return emailPanels;

  }
}
