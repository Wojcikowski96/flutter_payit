import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_payit/Database/databaseOperations.dart';
import 'package:flutter_payit/UI/Screens/homePage.dart';


class TimeInterval extends StatefulWidget {
  @override
  _TimeIntervalState createState() => _TimeIntervalState();
}

class _TimeIntervalState extends State<TimeInterval> {
  String username;
  var storage = FlutterSecureStorage();
  List<int> preferences = [0, 0, 0, 0];
  final TextEditingController urgentController = new TextEditingController();
  final TextEditingController notUrgentController = new TextEditingController();
  final TextEditingController monitorController = new TextEditingController();
  final TextEditingController remindsController = new TextEditingController();

  int i = 0;
  final DBRef = FirebaseDatabase.instance.reference();

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () async {
      username = (await storage.read(key: "username")).toString();
      print(username);
      List<int> tempPreferences = new List();
      tempPreferences = await DatabaseOperations().getUserPrefsFromDB(username);
      setState(() {
        preferences = tempPreferences;
      });
      setTextsFromDb();
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
                    child: Image.asset(
                      "time.png",
                      height: 150,
                      width: 150,
                      color: Colors.blue,
                    ),
                  ),
                  Text(
                    "Zdefiniuj stopnie pilności:",
                    style: TextStyle(
                      fontSize: 30,
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  Text(
                    "Dla pilnych:",
                    style: TextStyle(
                      fontSize: 25,
                      color: Colors.blue,
                    ),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Container(
                      margin: EdgeInsets.only(right: 10, left: 10),
                      width: 250,
                      child: Row(
                        children: [
                          Expanded(
                              flex: 2,
                              child: Align(
                                  alignment: Alignment.centerRight,
                                  child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Text(
                                        "Mniej niż: ",
                                        style: TextStyle(
                                          fontSize: 20,
                                          color: Colors.black54,
                                        ),
                                      )))),
                          Expanded(
                            flex: 2,
                            child: TextField(
                              controller: urgentController,
                              decoration: InputDecoration(
                                  contentPadding:
                                      EdgeInsets.only(top: 20, bottom: 20),
                                  prefixIcon: Padding(
                                    padding: const EdgeInsets.only(
                                        left: 20, right: 20),
                                    child: Icon(Icons.timer),
                                  ),
                                  filled: true,
                                  fillColor: Colors.grey.withOpacity(0.7),
                                  hintText: preferences[0].toString(),
                                  focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(30),
                                      borderSide: BorderSide(
                                          color: Colors.blueAccent, width: 2)),
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(20),
                                      borderSide: BorderSide(
                                        width: 2,
                                        color: Colors.blueAccent,
                                      ))),
                            ),
                          ),
                          Expanded(
                              flex: 1,
                              child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(" dni",
                                      style: TextStyle(
                                        fontSize: 20,
                                        color: Colors.black54,
                                      )))),
                        ],
                      )),
                  SizedBox(
                    height: 20,
                  ),
                  Text(
                    "Dla mało pilnych:",
                    style: TextStyle(
                      fontSize: 25,
                      color: Colors.blue,
                    ),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Container(
                      margin: EdgeInsets.only(right: 10, left: 10),
                      width: 250,
                      child: Row(
                        children: [
                          Expanded(
                              flex: 2,
                              child: Align(
                                  alignment: Alignment.centerRight,
                                  child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Text(
                                        "Więcej niż: ",
                                        style: TextStyle(
                                          fontSize: 20,
                                          color: Colors.black54,
                                        ),
                                      )))),
                          Expanded(
                            flex: 2,
                            child: TextField(
                              controller: notUrgentController,
                              decoration: InputDecoration(
                                  contentPadding:
                                      EdgeInsets.only(top: 20, bottom: 20),
                                  prefixIcon: Padding(
                                    padding: const EdgeInsets.only(
                                        left: 20, right: 20),
                                    child: Icon(Icons.timer),
                                  ),
                                  filled: true,
                                  fillColor: Colors.grey.withOpacity(0.7),
                                  hintText: preferences[1].toString(),
                                  focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(30),
                                      borderSide: BorderSide(
                                          color: Colors.blueAccent, width: 2)),
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(20),
                                      borderSide: BorderSide(
                                        width: 2,
                                        color: Colors.blueAccent,
                                      ))),
                            ),
                          ),
                          Expanded(
                              flex: 1,
                              child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(" dni",
                                      style: TextStyle(
                                        fontSize: 20,
                                        color: Colors.black54,
                                      )))),
                        ],
                      )),
                  SizedBox(
                    height: 20,
                  ),
                  Text(
                    "Sprawdzaj pocztę co:",
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Container(
                      margin: EdgeInsets.only(right: 10, left: 10),
                      width: 250,
                      child: Row(
                        children: [
                          Expanded(
                              flex: 2,
                              child: Align(
                                  alignment: Alignment.centerRight,
                                  child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: (Text(
                                        "Co: ",
                                        style: TextStyle(
                                          fontSize: 20,
                                          color: Colors.black54,
                                        ),
                                      ))))),
                          Expanded(
                            flex: 2,
                            child: TextField(
                              controller: monitorController,
                              decoration: InputDecoration(
                                  contentPadding:
                                      EdgeInsets.only(top: 20, bottom: 20),
                                  prefixIcon: Padding(
                                    padding: const EdgeInsets.only(
                                        left: 20, right: 20),
                                    child: Icon(Icons.timer),
                                  ),
                                  filled: true,
                                  fillColor: Colors.grey.withOpacity(0.7),
                                  hintText: preferences[2].toString(),
                                  focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(30),
                                      borderSide: BorderSide(
                                          color: Colors.blueAccent, width: 2)),
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(20),
                                      borderSide: BorderSide(
                                        width: 2,
                                        color: Colors.blueAccent,
                                      ))),
                            ),
                          ),
                          Expanded(
                              flex: 1,
                              child: Text(
                                " s",
                                style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.black54,
                                ),
                              )),
                        ],
                      )),
                  SizedBox(
                    height: 20,
                  ),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      "Dzienna liczba przypomnień:",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 30,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Container(
                      margin: EdgeInsets.only(right: 10, left: 10),
                      width: 250,
                      child: Row(
                        children: [
                          Expanded(
                              flex: 2,
                              child: Align(
                                  alignment: Alignment.centerRight,
                                  child: Text(
                                    " Dziennie: ",
                                    style: TextStyle(
                                      fontSize: 20,
                                      color: Colors.black54,
                                    ),
                                  ))),
                          Expanded(
                            flex: 2,
                            child: TextField(
                              controller: remindsController,
                              decoration: InputDecoration(
                                  contentPadding:
                                      EdgeInsets.only(top: 20, bottom: 20),
                                  prefixIcon: Padding(
                                    padding: const EdgeInsets.only(
                                        left: 20, right: 20),
                                    child: Icon(Icons.timer),
                                  ),
                                  filled: true,
                                  fillColor: Colors.grey.withOpacity(0.7),
                                  hintText: preferences[3].toString(),
                                  focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(30),
                                      borderSide: BorderSide(
                                          color: Colors.blueAccent, width: 2)),
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(20),
                                      borderSide: BorderSide(
                                        width: 2,
                                        color: Colors.blueAccent,
                                      ))),
                            ),
                          ),
                          Expanded(
                              flex: 1,
                              child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    " raz/y",
                                    style: TextStyle(
                                      fontSize: 20,
                                      color: Colors.black54,
                                    ),
                                  ))),
                        ],
                      )),
                  SizedBox(
                    height: 35,
                  ),
                  SizedBox(
                    width: 200,
                    height: 80,
                    child: RaisedButton(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18.0),
                          side: BorderSide(color: Colors.blue, width: 5)),
                      onPressed: () {
                        writeData();
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => homePage(DateTime.now())),
                        );
                      },
                      child: Center(
                        child: Text(
                          'Zatwierdź i wróć',
                          maxLines: 2,
                          style: TextStyle(color: Colors.blue, fontSize: 20),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                ]))));
  }

  void setTextsFromDb() {
    urgentController.text = preferences[0].toString();
    notUrgentController.text = preferences[1].toString();
    monitorController.text = preferences[2].toString();
    remindsController.text = preferences[3].toString();
  }

  Future<void> writeData() async {
    DBRef.child('Users')
        .child((await storage.read(key: "username")).toString())
        .child('userPrefs')
        .set({
      "dailyReminds": int.parse(remindsController.text),
      "monitorFreq": int.parse(monitorController.text),
      "notUrgent": int.parse(notUrgentController.text),
      "urgent": int.parse(urgentController.text)
    });
  }
}
