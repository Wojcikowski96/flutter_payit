
import 'package:flutter/material.dart';
import 'package:flutter_payit/IsUserLoggedChecker/MySharedPreferences.dart';
import 'package:flutter_payit/UI/HelperClasses/uiElements.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'homePage.dart';
import 'registerPage.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';


class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class User {
  String login, password;
  List<String> emails = new List();
  User();

  User.construct(String login, String password) {
    this.login = login;
    this.password = password;
  }

  static fromJson(json) {
    User u = new User();
    u.login = json['login'];
    u.password = json['password'];
    return u;
  }
}

class _LoginPageState extends State<LoginPage> {
  final DBRef = FirebaseDatabase.instance.reference();
  final formKey = GlobalKey<FormState>();
  final TextEditingController loginController = new TextEditingController();
  final TextEditingController passwordController = new TextEditingController();

  final storage = FlutterSecureStorage();

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
                    height: 30,
                  ),
                  SizedBox(
                    width: width - 160,
                    height: width - 160,
                    child: Image.asset(
                      "payitlogo.png",
                      fit: BoxFit.fitHeight,
                    ),
                  ),
                  SizedBox(
                    height: 20,
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
                  SizedBox(
                    height: 25,
                  ),
                  Container(
                      margin: EdgeInsets.only(right: 10, left: 10),
                      child: TextField(
                        controller: loginController,
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
                      )),
                  SizedBox(
                    height: 25,
                  ),
                  Container(
                      margin: EdgeInsets.only(right: 10, left: 10),
                      child: TextField(
                        controller: passwordController,
                        decoration: InputDecoration(
                            contentPadding:
                                EdgeInsets.only(top: 20, bottom: 20),
                            prefixIcon: Padding(
                              padding:
                                  const EdgeInsets.only(left: 20, right: 20),
                              child: Icon(Icons.accessibility_outlined),
                            ),
                            filled: true,
                            fillColor: Colors.grey.withOpacity(0.7),
                            hintText: "Hasło",
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
                      )),
                  SizedBox(
                    height: 25,
                  ),
                  SizedBox(
                    child: RaisedButton(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),

                      onPressed: () {

                        getDataFromTextFields();
                        verifyUsername(getDataFromTextFields()[0],getDataFromTextFields()[1]);
                        UiElements().showLoaderDialog(context, "Trwa logowanie, czekaj",true);

                      },

                      child: Text("Zaloguj"),
                      color: Colors.blue,
                      textColor: Colors.white,
                      padding: EdgeInsets.fromLTRB(5, 5, 5, 5),
                      splashColor: Colors.white,
                    ),
                    width: 200,
                    height: 70,
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Text(
                    "Nie masz u nas konta?",
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
                    onPressed: () {
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

  getDataFromTextFields() {
    List<String> fieldData = new List();
    String login = loginController.text;
    String password = passwordController.text;
    fieldData.add(login);
    fieldData.add(password);

    return fieldData;
  }

  bool checkUsername(String username, List<String> usernames) {
    bool userExists;
    for (var u in usernames) {
      if (u == username) {
        userExists = true;
        break;
      } else {
        userExists = false;
      }
    }
    return userExists;
  }

  bool checkPassword(String passwordInput, String password) {
    bool passwordOK;

      if (passwordInput == password) {
        passwordOK = true;
      } else {
        passwordOK = false;
      }

    return passwordOK;
  }


  verifyUsername(String username, String password) {
    List<String> usernames = new List();
    final DBRef = FirebaseDatabase.instance.reference().child("Users");
    DBRef.once().then((DataSnapshot snapshot) {
      Map<dynamic, dynamic> values = snapshot.value;
      values.forEach((key, values) {
        usernames.add(values["login"]);
      });
      if (checkUsername(username,usernames)) {
        verifyPassword(username,password);
      } else {
        Fluttertoast.showToast(
            msg: 'Nieprawidłowy login lub hasło',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIos: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white
        );
      }
    });
  }

  verifyPassword(String username, String password) {
    String passwordForSpecifiedUser;
    final DBRef = FirebaseDatabase.instance.reference().child("Users").child(username);
    DBRef.once().then((DataSnapshot snapshot) {
      passwordForSpecifiedUser = snapshot.value["password"];

      if (checkPassword(password,passwordForSpecifiedUser)) {
        MySharedPreferences.instance
            .setBooleanValue("isLoggedIn", true);

        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => homePage(DateTime.now(),new List())),
        );

        storage.write(key: "username", value: username);
        storage.write(key: "password", value: password);

      } else {
        Fluttertoast.showToast(
            msg: 'Nieprawidłowy login lub hasło',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIos: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white
        );
      }
    });
  }

}
