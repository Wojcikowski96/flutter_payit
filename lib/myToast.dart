
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'homePage.dart';

class ToastExample extends StatefulWidget {
  @override
  _ToastExampleState createState() {
    return _ToastExampleState();
  }
}

class _ToastExampleState extends State {
  int i = 0;
  final TextEditingController emailController = new TextEditingController();
  static void showToast() {
    Fluttertoast.showToast(
        msg: 'Zły format adresu e-mail',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIos: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white
    );
  }
  final DBRef = FirebaseDatabase.instance.reference();
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            child: Container(
              width: width,
              child: Column(children: <Widget>[
                SizedBox(
                  height: height * 0.08,

                ),
                Center(
                  child: Text('Podaj swój adres e-mail, na który przychodzić będą faktury. Podczas działania aplikacji możliwe będzie dodawanie kolejnych adresów.',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey,
                    ),

                  ),
                ),
                SizedBox(
                  height: 10,
                ),
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
                          hintText: "Twój adres e-mail",
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
                  height: 30,
                ),
                RaisedButton(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  onPressed: (){
                    if((emailController.text).contains('@')) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => homePage()),
                      );
                      i=i+1;
                      updateUserData(1,i);
                    }else{

                      _ToastExampleState.showToast();
                    }
                  },
                  child: Text("Zarejestruj"),
                  color: Colors.blue,
                  textColor: Colors.white,
                  padding: EdgeInsets.fromLTRB(5, 5, 5, 5),
                  splashColor: Colors.white,

                ),
              ]),
            ),
          ),
        )
    );
  }
  void updateUserData(int userID, int emailNum){
    String email = emailController.text;


    DBRef.child(userID.toString()).update({
      'email'+emailNum.toString(): email,
    });

  }
}