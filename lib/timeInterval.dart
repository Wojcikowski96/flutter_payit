import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'databaseOperations.dart';
import 'homePage.dart';
import 'loginScreen.dart';


class TimeInterval extends StatefulWidget {

  @override
  _TimeIntervalState createState() => _TimeIntervalState();
}

class _TimeIntervalState extends State <TimeInterval>{
  String username;
  var storage = FlutterSecureStorage();
  List <int> preferences;
  final TextEditingController urgentController = new TextEditingController();
  final TextEditingController notUrgentController = new TextEditingController();
  final TextEditingController monitorController = new TextEditingController();
  final TextEditingController remaindsController = new TextEditingController();
  int i = 0;
  final DBRef = FirebaseDatabase.instance.reference();

  @override
void initState(){
    super.initState();
    Future.delayed(Duration.zero, () async {
      username = (await storage.read(key: "username")).toString();
      print(username);
      List <int> tempPreferences = new List();
      tempPreferences =  await DatabaseOperations().getUserPrefsFromDB(username);
      setState(() {
        preferences = tempPreferences;
      });
    });

}


  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    print("preferences w buildzie timeInterval");
    print(preferences);
    return Scaffold(
        body: SingleChildScrollView(
            child: Container(
                width: width,
                child: Column(children: <Widget>[
                  SizedBox(
                    height: height * 0.08,

                  ),
                  Container(
                    child:Image.asset(
                      "time.png",
                      height: 150,
                      width: 150,
                      color: Colors.blue,

                    ),
                  ),
                  Text("Zdefiniuj stopnie pilności:", style: TextStyle(fontSize: 30, color: Colors.blue),),
                  SizedBox(
                    height: 10,
                  ),

                  Text(
                    "Dla pilnych:",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 26,
                      color: Color.fromRGBO(27, 27, 27, 1),
                    ),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Container(
                      margin: EdgeInsets.only(right: 10, left: 10),
                      width: 250,
                      child: TextField(
                        controller: urgentController,
                        decoration: InputDecoration(
                            contentPadding: EdgeInsets.only(top: 20, bottom: 20),
                            prefixIcon: Padding(
                              padding: const EdgeInsets.only(left: 20, right: 20),
                              child: Icon(Icons.timer),
                            ),
                            filled: true,
                            fillColor: Colors.grey.withOpacity(0.7),

                            hintText: "Mniej niż : " +  preferences[0].toString() + " dni",
                            focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: BorderSide(
                                    color: Colors.blueAccent,
                                    width: 2
                                )
                            ),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                                borderSide: BorderSide(
                                  width: 2,
                                  color: Colors.blueAccent,
                                )
                            )
                        ),
                      )
                  ),
                  SizedBox(
                    height: 10,
                  ),


                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    "Dla mało pilnych:",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 26,
                      color: Color.fromRGBO(27, 27, 27, 1),
                    ),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Container(
                      margin: EdgeInsets.only(right: 10, left: 10),
                      width: 250,
                      child: TextField(
                        controller: notUrgentController,
                        decoration: InputDecoration(
                            contentPadding: EdgeInsets.only(top: 20, bottom: 20),
                            prefixIcon: Padding(
                              padding: const EdgeInsets.only(left: 20, right: 20),
                              child: Icon(Icons.timer),
                            ),
                            filled: true,
                            fillColor: Colors.grey.withOpacity(0.7),
                            hintText: "Więcej niż: " +  preferences[1].toString() + " dni",
                            focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: BorderSide(
                                    color: Colors.blueAccent,
                                    width: 2
                                )
                            ),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                                borderSide: BorderSide(
                                  width: 2,
                                  color: Colors.blueAccent,
                                )
                            )
                        ),
                      )
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    "Częstotliwość sprawdzania skrzynek:",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Color.fromRGBO(27, 27, 27, 1),
                    ),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Container(
                      margin: EdgeInsets.only(right: 10, left: 10),
                      width: 250,
                      child: TextField(
                        controller: monitorController,
                        decoration: InputDecoration(
                            contentPadding: EdgeInsets.only(top: 20, bottom: 20),
                            prefixIcon: Padding(
                              padding: const EdgeInsets.only(left: 20, right: 20),
                              child: Icon(Icons.timer),
                            ),
                            filled: true,
                            fillColor: Colors.grey.withOpacity(0.7),
                            hintText: "Co: " +  preferences[2].toString() + " sekund",
                            focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: BorderSide(
                                    color: Colors.blueAccent,
                                    width: 2
                                )
                            ),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                                borderSide: BorderSide(
                                  width: 2,
                                  color: Colors.blueAccent,
                                )
                            )
                        ),
                      )
                  ),
                  Text(
                    "Dzienna liczba przypomnień:",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 26,
                      color: Color.fromRGBO(27, 27, 27, 1),
                    ),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Container(
                      margin: EdgeInsets.only(right: 10, left: 10),
                      width: 250,
                      child: TextField(
                        controller: remaindsController,
                        decoration: InputDecoration(
                            contentPadding: EdgeInsets.only(top: 20, bottom: 20),
                            prefixIcon: Padding(
                              padding: const EdgeInsets.only(left: 20, right: 20),
                              child: Icon(Icons.timer),
                            ),
                            filled: true,
                            fillColor: Colors.grey.withOpacity(0.7),
                            hintText: preferences[3].toString() + " razy na dobę",
                            focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: BorderSide(
                                    color: Colors.blueAccent,
                                    width: 2
                                )
                            ),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                                borderSide: BorderSide(
                                  width: 2,
                                  color: Colors.blueAccent,
                                )
                            )
                        ),
                      )
                  ),
                  SizedBox(
                    height: 35,
                  ),
                  SizedBox(
                    child: RaisedButton(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      onPressed: (){
                        writeData();
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => homePage()),
                        );
                      },
                      child: Text("Zapisz"),
                      color: Colors.blueAccent,
                      textColor: Colors.white,
                      padding: EdgeInsets.fromLTRB(5, 5, 5, 5),
                      splashColor: Colors.white,
                    ),
                    width: 200,
                    height: 70,
                  ),



                ]))));
  }

  Future<void> writeData() async {

    DBRef.child('Users').child((await storage.read(key: "username")).toString()).child('userPrefs').set({
      "dailyReminds": int.parse(remaindsController.text),
      "monitorFreq": int.parse(monitorController.text),
      "notUrgent": int.parse(notUrgentController.text),
      "urgent": int.parse(urgentController.text)
    });

  }

}







