import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_payit/databaseOperations.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'constrants.dart';

class TrustedListPanel extends StatefulWidget {
  @override
  _TrustedListPanelState createState() => _TrustedListPanelState();
}

class _TrustedListPanelState extends State<TrustedListPanel> {
  final TextEditingController emailController = new TextEditingController();
  final TextEditingController nameController = new TextEditingController();
  var storage = FlutterSecureStorage();
  String username = "JohnDoe", password = "qwerty";
  List<Padding> emailPanels = new List();
  List<String> trustedEmails = new List();
  List<String> emailKeys = new List();
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

      print("Username " + username);

      List<Padding> tempEmailPanels = await getLoggedUserData();

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
        SizedBox(height: 40,),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text("Zaufana lista", style: TextStyle(fontSize: 35, color: Colors.blue),),
        ),

        Container(
          child:Image.asset(
            "invoices.png",
            height: 150,
            width: 150,

          ),
        ),
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
          displayDialog(context, "Dodaj nadawcę faktur:");
        },
      ),
    );
  }

  Padding emailPanel(String email, String emailKey) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: new Container(
        decoration: BoxDecoration(
            border: Border.all(
              color: Colors.blue,
              width: 4,
            ),
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(20))),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                flex: 9,
                child: Text(
                  email,
                  style: TextStyle(fontSize: 25, color: Colors.blue),
                ),
              ),
              Expanded(
                flex: 2,
                child: IconButton(
                  color: Colors.blue,
                  icon: Center(child: Icon(Icons.delete, size: 30.0)),
                  onPressed: () {
                    removeUserEmail(emailKey,email);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<List<Padding>> getLoggedUserData() async {
    List<String> tempUserEmails = new List();
    List<String> tempEmailKeys = new List();
    List<Padding> emailPanels = new List();

    final dbSnapshot =
    await DBRef.child("Users").child(username).child("invoicesEmails").once();

    Map<dynamic, dynamic> values = dbSnapshot.value;

    if (values!=null) {
      values.forEach((key, values) {
        tempUserEmails.add(values["username"].toString());
        tempEmailKeys.add(key.toString());
      });
    }

    for (int i = 0; i < tempUserEmails.length; i++) {
      emailPanels.add(emailPanel(tempUserEmails[i], tempEmailKeys[i]));
    }

    setState(() {
      trustedEmails = tempUserEmails;
      print("User emails w trusted:");
      print(trustedEmails);
      emailKeys = tempEmailKeys;
    });

    return emailPanels;
  }

  prepareListsForDrawing(String email, String customName) {

    String emailKey = email.replaceAll(new RegExp(r'\.'),'');
    List<String> tempEmailKeys = emailKeys;
    List<String> tempUserEmails = trustedEmails;

    DatabaseOperations().addTrustedEmailsToDatabase(emailKey, email, customName, username);

    List<Padding> tempEmailPanels = emailPanels;
    tempEmailPanels.add(emailPanel(email, emailKey));
    tempEmailKeys.add(emailKey);
    tempUserEmails.add(email);

    setState(() {
      emailPanels = tempEmailPanels;
      emailKeys = tempEmailKeys;
      trustedEmails = tempUserEmails;
    });
  }



  removeUserEmail(String emailKey, String email) {
    DBRef.child('Users')
        .child(username)
        .child('invoicesEmails')
        .child(emailKey)
        .remove();

    List<Padding> tempEmailPanels = emailPanels;

    tempEmailPanels.removeAt(emailKeys.indexOf(emailKey));

    emailKeys.remove(emailKey);
    trustedEmails.remove(email);

    setState(() {
      emailPanels = tempEmailPanels;
    });
  }

  bool checkIfEmailsTheSame(String thisMail){

    bool emailAlreadyExists=false;
    print(trustedEmails);
    for(String otherEmail in trustedEmails){
      if(otherEmail == thisMail){
        emailAlreadyExists= true;
        break;
      }
    }
    return emailAlreadyExists;
  }

  void displayDialog(BuildContext context, String title) => showDialog(
    context: context,
    builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Constants.padding),
        ),
        title: Center(child: Text(title, style: TextStyle(color: Colors.blue),)),
        content: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Container(
            height: 264,
            child: Column(
              children: [
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                      contentPadding: EdgeInsets.only(top: 20, bottom: 20),
                      prefixIcon: Padding(
                        padding: const EdgeInsets.only(left: 20, right: 20),
                        child: Icon(Icons.person_outline),
                      ),
                      filled: true,
                      fillColor: Colors.grey.withOpacity(0.7),
                      hintText: "Email",
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
                SizedBox(height: 25),
                Center(child: Text("Nazwij nadawcę faktur:", style: TextStyle(color: Colors.blue),)),
                SizedBox(height: 20),
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                      contentPadding: EdgeInsets.only(top: 20, bottom: 20),
                      prefixIcon: Padding(
                        padding: const EdgeInsets.only(left: 20, right: 20),
                        child: Icon(Icons.person_outline),
                      ),
                      filled: true,
                      fillColor: Colors.grey.withOpacity(0.7),
                      hintText: "Nazwa",
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
                SizedBox(height: 25),
                RaisedButton(
                    child: Text('Dodaj',style: TextStyle(color: Colors.white),),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    color: Colors.blue,
                    onPressed: () {
                      Navigator.pop(context, false);
                      if(!checkIfEmailsTheSame(emailController.text))
                        prepareListsForDrawing(emailController.text, nameController.text);
                      else{
                        Fluttertoast.showToast(
                            msg: 'Taki mail jest już zdefiniowany',
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.CENTER,
                            timeInSecForIos: 1,
                            backgroundColor: Colors.red,
                            textColor: Colors.white
                        );
                      }
                    })
              ],
            ),
          ),
        )),
  );
}
