import 'dart:async';


import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_payit/Utils/userOperationsOnEmails.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:flutter_payit/UI/HelperClasses/dialog.dart';
import 'loginScreen.dart';


class registerPage extends StatelessWidget {

  final TextEditingController loginController = new TextEditingController();
  final TextEditingController password1Controller = new TextEditingController();
  final TextEditingController password2Controller = new TextEditingController();
  final TextEditingController emailController = new TextEditingController();
  final TextEditingController emailPasswordController = new TextEditingController();
  int i = 0;
  final DBRef = FirebaseDatabase.instance.reference();



  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Scaffold(
        body: SingleChildScrollView(
            child: Container(
                width: width,
                child: Column(children: <Widget>[
                  SizedBox(
                    height: height * 0.08,

                  ),
                  SizedBox(
                    width: width,
                    height: width-330,
                    child: Image.asset(
                      "payitlogohorizontal.png",
                      fit: BoxFit.fitHeight,
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),

                  Text(
                    "Zarejestruj się:",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 26,
                      color: Color.fromRGBO(27, 27, 27, 1),
                    ),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Text("Dane do rejestracji:",
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                          color: Colors.black)),

                  SizedBox(height: 25,),
                  Container(
                      margin: EdgeInsets.only(right: 10, left: 10),
                      child: TextField(
                        controller: loginController,
                        decoration: InputDecoration(
                            contentPadding: EdgeInsets.only(top: 20, bottom: 20),
                            prefixIcon: Padding(
                              padding: const EdgeInsets.only(left: 20, right: 20),
                              child: Icon(Icons.person_outline),
                            ),
                            filled: true,
                            fillColor: Colors.grey.withOpacity(0.7),
                            hintText: "Login",
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
                  SizedBox(height: 25,),
                  Container(
                      margin: EdgeInsets.only(right: 10, left: 10),
                      child: TextField(
                        controller: password1Controller,
                        decoration: InputDecoration(
                            contentPadding: EdgeInsets.only(top: 20, bottom: 20),
                            prefixIcon: Padding(
                              padding: const EdgeInsets.only(left: 20, right: 20),
                              child: Icon(Icons.accessibility_outlined),
                            ),
                            filled: true,
                            fillColor: Colors.grey.withOpacity(0.7),
                            hintText: "Hasło",
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
                  SizedBox(height: 25,),
                  Container(
                      margin: EdgeInsets.only(right: 10, left: 10),
                      child: TextField(
                        controller: password2Controller,
                        decoration: InputDecoration(
                            contentPadding: EdgeInsets.only(top: 20, bottom: 20),
                            prefixIcon: Padding(
                              padding: const EdgeInsets.only(left: 20, right: 20),
                              child: Icon(Icons.accessibility_outlined),
                            ),
                            filled: true,
                            fillColor: Colors.grey.withOpacity(0.7),
                            hintText: "Powtórz Hasło",
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
                  SizedBox(height: 25,),
                  Text("Dane do konta mailowego:",
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                          color: Colors.black)),
                  SizedBox(height: 10,),
                  Container(
                      margin: EdgeInsets.only(right: 10, left: 10),
                      child: TextField(
                        controller: emailController,
                        decoration: InputDecoration(
                            contentPadding: EdgeInsets.only(top: 20, bottom: 20),
                            prefixIcon: Padding(
                              padding: const EdgeInsets.only(left: 20, right: 20),
                              child: Icon(Icons.person_outline),
                            ),
                            filled: true,
                            fillColor: Colors.grey.withOpacity(0.7),
                            hintText: "Podaj swój pierwszy adres e-mail",
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

                  SizedBox(height: 25,),
                  Container(
                      margin: EdgeInsets.only(right: 10, left: 10),
                      child: TextField(
                        controller: emailPasswordController,
                        decoration: InputDecoration(
                            contentPadding: EdgeInsets.only(top: 20, bottom: 20),
                            prefixIcon: Padding(
                              padding: const EdgeInsets.only(left: 20, right: 20),
                              child: Icon(Icons.person_outline),
                            ),
                            filled: true,
                            fillColor: Colors.grey.withOpacity(0.7),
                            hintText: "Podaj hasło do poczty",
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
                  SizedBox(height: 25,),
                  SizedBox(
                    child: RaisedButton(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),

                      onPressed: (){
                        register(context);
                      },
                      child: Text("Zarejestruj"),
                      color: Colors.blueAccent,
                      textColor: Colors.white,
                      padding: EdgeInsets.fromLTRB(5, 5, 5, 5),
                      splashColor: Colors.white,
                    ),
                    width: 200,
                    height: 70,
                  ),
                  SizedBox(height: 5,),
                  Text("Masz już konto?",
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey,
                    ),

                  ),
                  RaisedButton(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    onPressed: (){
                      Navigator.pop(context);
                    },
                    child: Text("Zaloguj"),
                    color: Colors.deepOrange,
                    textColor: Colors.white,
                    padding: EdgeInsets.fromLTRB(5, 5, 5, 5),
                    splashColor: Colors.white,

                  ),

                ]))));
  }
  Future<void> writeData(BuildContext context) async {
    String login = loginController.text;
    String password = password1Controller.text;
    String email = emailController.text;
    String emailPassword = emailPasswordController.text;

    DBRef.child('Users').child(login).set({
      'login': login,
      'password': password,
      'myEmails' :null,
      'invoiceEmails' :null,
      'userPrefs' : {
        'urgent' : 7,
        'notUrgent' : 14,
        'monitorFreq' : 60,
        'dailyReminds' : 1
      }
    });

    String emailKey = email.replaceAll(new RegExp(r'\.'),'');
    //Todo przeniesc moze wyzej
    List <String> emailConfig = await UserOperationsOnEmails().discoverSettings(email, emailPassword);

    if (UserOperationsOnEmails().checkIfInteria(emailConfig[2])) {
      showDialog(context: context,
          builder: (BuildContext context){
            return MyDialog(
              title: "Jeśli używasz poczty Interia",
              descriptions: "Zaznacz powyższe w ustawieniach swojej poczty aby można było pobierać z niej faktury. Z powodu błędu w Javamail, bez zmiany tego ustawienia aplikacja się zawiesi.",
              img: "interia_settings.png",
              text: 'Rozumiem',
            );
          }
      );
    }

    DBRef.child('Users').child(login).child('myEmails').child(emailKey).set({
      "username": email,
      "password": emailPassword,
      "hostname": emailConfig[2],
      "port": emailConfig[3],
      "protocol": emailConfig[4],
      "lastUID" : 0
    });

    DBRef.child('Users').child(login).child('invoiceEmails').set({
    });

  }

  void register(BuildContext context) async {
    String email = emailController.text;
    String emailPassword = emailPasswordController.text;

    if((password1Controller.text == password2Controller.text) && emailController.text.contains('@')){
      writeData(context);

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );

    }else{
      Fluttertoast.showToast(
          msg: 'Nieprawidłowy format e-mail lub niezgodne hasła',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIos: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white
      );
    }
  }
}
