import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:firebase_database/firebase_database.dart';

class EmailBoxesPanel extends StatefulWidget {
  @override
  _EmailBoxesPanelState createState() => _EmailBoxesPanelState();
}

class _EmailBoxesPanelState extends State<EmailBoxesPanel> {
  final TextEditingController emailController = new TextEditingController();
  var storage = FlutterSecureStorage();
  String username = "JohnDoe", password = "qwerty";
  List<Container> emailPanels = new List();
  final DBRef = FirebaseDatabase.instance.reference();

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () async {
      String tempUsername = (await storage.read(key: "username")).toString();
      String tempPassword = (await storage.read(key: "password")).toString();

      setState(() {
        username = tempUsername;
      });

      List<Container> tempEmailPanels = await getLoggedUserData();

      setState(() {
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
              children: List.generate(
                  emailPanels.length, (index) => emailPanels[index]),
            ),
          ),
        ),
      ]),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        child: Icon(Icons.add),
        onPressed: () {
          displayDialog(context, "Dodaj swój e-mail");
        },
      ),
    );
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

    final dbSnapshot =
        await DBRef.child("Users").child(username).child("myEmails").once();

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

  updateUserEmails(String email) {

    DBRef.child('Users').child(username).child('myEmails').update({
      'email'+(emailPanels.length+1).toString(): email,
    });

    List<Container> tempEmailPanels = emailPanels;
    tempEmailPanels.add(emailPanel(email));

    setState(() {
      emailPanels = tempEmailPanels;
    });
  }

  void displayDialog(BuildContext context, String title) =>
      showDialog(
        context: context,
        builder: (context) =>
            AlertDialog(
                title: Text(title),
                content: Container(

                    child: Column(
                      children: [
                        TextField(
                          controller: emailController,
                          decoration: InputDecoration(
                              contentPadding:
                              EdgeInsets.only(top: 20, bottom: 20),
                              prefixIcon: Padding(
                                padding:
                                const EdgeInsets.only(left: 20, right: 20),
                                child: Icon(Icons.person_outline),
                              ),
                              filled: true,
                              fillColor: Colors.grey.withOpacity(0.7),
                              hintText: "Login",
                              focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30),
                                  borderSide:
                                  BorderSide(color: Colors.grey, width: 2)),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  borderSide: BorderSide(
                                    width: 2,
                                    color: Colors.grey,
                                  ))),
                        ),
                        RaisedButton(
                          child: Text('Dodaj'),
                            onPressed: (){
                              updateUserEmails(emailController.text);
                        })
                      ],
                    ),
                )
            ),
      );
}
