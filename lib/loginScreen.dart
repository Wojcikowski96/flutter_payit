import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_payit/myToast.dart';
import 'registerPage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';


class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}
class User{
 String login, password;
 List<String>  emails = new List();
 User();

 User.construct(String login, String password){
   this.login = login;
   this.password = password;
 }

 static fromJson(json) {
   User u = new User();
   print(json);
   u.login = json['login'];
   u.password = json['password'];
   return u;
 }

}

class _LoginPageState extends State<LoginPage> {

  bool _isLoading = true;


  final DBRef = FirebaseDatabase.instance.reference();

  final TextEditingController loginController = new TextEditingController();
  final TextEditingController passwordController = new TextEditingController();



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
                    height: 10,
                  ),
                  Text(
                    "Zaloguj się:",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 26,
                      color: Color.fromRGBO(27, 27, 27, 1),
                    ),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Text("Wpisz swoje dane:",
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey)),
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
                                    color: Colors.grey,
                                    width: 2
                                )
                            ),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                                borderSide: BorderSide(
                                  width: 2,
                                  color: Colors.grey,
                                )
                            )
                        ),
                      )
                  ),
                  SizedBox(height: 25,),
                  Container(
                      margin: EdgeInsets.only(right: 10, left: 10),
                      child: TextField(
                        controller: passwordController,
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
                                    color: Colors.grey,
                                    width: 2
                                )
                            ),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                                borderSide: BorderSide(
                                  width: 2,
                                  color: Colors.grey,
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
                      //emailController.text == "" || passwordController.text == "" ? null :
                      onPressed: () {

                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => ToastExample()),
                        );
                        getDataFromTextFields();
                        checkUsername(getDataFromTextFields()[0]);
                        print(checkUsername(getDataFromTextFields()[0]));

                         FutureBuilder<dynamic>(
                             future: checkUsername(getDataFromTextFields()[0]),
                                builder: (context, snapshot) {
                               if (snapshot.hasData) {
                                   print('wywolanie checkusername');
                                 print(checkUsername(getDataFromTextFields()[0]));
                                   } else {
                                      return Text('Użytkownik nie istnieje');
                                    }
                               return Text("Await for data");
                             }
                            //
                            //     },
                            //   ),
                         );},
                      child: Text("Zaloguj"),
                      color: Colors.blue,
                      textColor: Colors.white,
                      padding: EdgeInsets.fromLTRB(5, 5, 5, 5),
                      splashColor: Colors.white,
                    ),
                    width: 200,
                    height: 70,
                  ),
                  SizedBox(height: 5,),
                  Text("Nie masz u nas konta?",
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
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => registerPage()),
                      );
                    },
                    child: Text("Zarejestruj"),
                    color: Colors.blue,
                    textColor: Colors.white,
                    padding: EdgeInsets.fromLTRB(5, 5, 5, 5),
                    splashColor: Colors.white,

                  ),

                ]))));
  }
  void attemptLogIn(){
    List <String> dataFromFields = new List();

    dataFromFields = getDataFromTextFields();
/*
    DBRef.once().then((DataSnapshot dataSnapshot){
      print(dataSnapshot.getChildrenCount());
    });

    DBRef.child("the-bill-collector").child('User'+i).child(dataFromFields[0])
        .once().then((DataSnapshot dataSnapshot){
      print(dataSnapshot.value);
    });
*/
  }

  getDataFromTextFields(){

    List<String> fieldData = new List();
    String login = loginController.text;
    String password = passwordController.text;
    fieldData.add(login);
    fieldData.add(password);

    print('dane z pól:');
    print(login);
    print(password);

    return fieldData;
  }

   Future <int> checkUsername(String username) async{
    List<String> usernames = new List();
    final DBRef = FirebaseDatabase.instance.reference().child("Users");
    var d = await DBRef.once().then((DataSnapshot snapshot){
      Map<dynamic, dynamic> values = snapshot.value;
      values.forEach((key,values) {
        usernames.add(values["login"]);
        print('lista użytkowników');
        print(usernames);
        for(var iterator in usernames){
          if(iterator == username){
            return 1;
          }else{
            return 0;
          }
        }
      });


    });
    print('druk wewnątrz checkUSERnAME');
    print(d.toString());
  }

  checkPassword(String username){
    //var userCount = await DBRef.child('Statistics').child('userCount').once();
  }

  Future<int> getUsersNum() async {

    var userCount = await DBRef.child('Statistics').child('userCount').once();

    if(userCount.value == null){
      return 0;
    }else{
      print(userCount.value);
      return userCount.value;
    }
  }

}
