import 'dart:core';
import 'package:flutter/material.dart';
import 'package:flutter_payit/Objects/userEmail.dart';
import 'package:flutter_payit/UI/HelperClasses/uiElements.dart';
import 'package:flutter_payit/Utils/userOperationsOnEmails.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_payit/constrants.dart';
import 'package:flutter_payit/Database/databaseOperations.dart';
import 'package:flutter_payit/UI/HelperClasses/dialog.dart';
import 'package:flutter_payit/UI/Screens/homePage.dart';

class EmailBoxesPanel extends StatefulWidget {
  @override
  _EmailBoxesPanelState createState() => _EmailBoxesPanelState();
}

class _EmailBoxesPanelState extends State<EmailBoxesPanel> {
  final TextEditingController emailController = new TextEditingController();
  final TextEditingController emailPasswordController =
      new TextEditingController();
  final TextEditingController emailHostController = new TextEditingController();
  final TextEditingController emailPortController = new TextEditingController();
  final TextEditingController emailTypeController = new TextEditingController();
  var storage = FlutterSecureStorage();
  String username = "JohnDoe", password = "qwerty";
  List<Padding> emailPanels = new List();
  List<String> userEmails = new List();
  List<String> emailKeys = new List();
  final DBRef = FirebaseDatabase.instance.reference();
  bool isSwitched = false;

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration.zero, () async {
      String tempUsername = (await storage.read(key: "username")).toString();
      String tempPassword = (await storage.read(key: "password")).toString();

      setState(() {
        username = tempUsername;
      });

      List<Padding> tempEmailPanels = await getLoggedUserData(
          await DatabaseOperations().getUserEmailsFromDb(username));

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
    return WillPopScope(
      onWillPop: askForSaving,
      child: Scaffold(
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: MediaQuery.of(context).size.height / 2,
              collapsedHeight: MediaQuery.of(context).size.height / 10,
              shape: ContinuousRectangleBorder(
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30))),
              forceElevated: true,
              title: Center(
                  child: Text(
                "Twoje skrzynki e-mail",
                style: TextStyle(color: Colors.white, fontSize: 30),
              )),
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                background: Image.asset(
                  "mailboxes.png",
                ),
              ),
            ),
            _getSlivers(emailPanels, context),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.blue,
          child: Icon(Icons.add),
          onPressed: () {
            displayDialog(context, "Dodaj swój e-mail");
          },
        ),
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
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    email,
                    style: TextStyle(fontSize: 25, color: Colors.blue),
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: IconButton(
                  color: Colors.blue,
                  icon: Center(child: Icon(Icons.delete, size: 30.0)),
                  onPressed: () {
                    removeUserEmail(emailKey, email);
                  },
                ),
              ),
//              Expanded(
//                flex: 2,
//                child: IconButton(
//                  color: Colors.blue,
//                  icon: Center(child: Icon(Icons.edit, size: 30.0)),
//                  onPressed: () {
//                    displayDialog(context,"Edytuj adres email");
//                  },
//                ),
//              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> askForSaving() {
    return showDialog(
          context: context,
          builder: (context) => new AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(Constants.padding)),
            title: Text('Opuszczasz ekran ustawień'),
            content: Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(20))),
              height: MediaQuery.of(context).size.height / 10.8,
              child: Column(
                children: [
                  new Text('Uwzględnić dodane adresy?'),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: new Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => Navigator.of(context).pop(false),
                            child: Container(
                                decoration: BoxDecoration(
                                    color: Colors.lightBlue,
                                    borderRadius: BorderRadius.all(Radius.circular(20))),
                                child: Center(
                                    child: Text(
                                  "NIE",
                                  style: TextStyle(
                                      fontSize: 24, color: Colors.white),
                                ))),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            width: 20,
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => homePage(
                                      DateTime.now(), new List(), true)),
                            ),
                            child: Container(
                                decoration: BoxDecoration(
                                    color: Colors.lightBlue,
                                    borderRadius: BorderRadius.all(Radius.circular(20))),
                                child: Center(
                                    child: Text("TAK",
                                        style: TextStyle(
                                            fontSize: 24,
                                            color: Colors.white)))),
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ) ??
        false;
  }

  SliverList _getSlivers(List emailPanels, BuildContext context) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (BuildContext context, int index) {
          return emailPanels[index];
        },
        childCount: emailPanels.length,
      ),
    );
  }

  Future<List<Padding>> getLoggedUserData(
      List<UserEmail> userEmailsList) async {
    List<Padding> emailPanels = new List();
    List<String> tempUserEmails = new List();
    List<String> tempEmailKeys = new List();

    for (int i = 0; i < userEmailsList.length; i++) {
      emailPanels.add(emailPanel(
          userEmailsList[i].emailAddress, userEmailsList[i].emailKey));
      tempUserEmails.add(userEmailsList[i].emailAddress);
      tempEmailKeys.add(userEmailsList[i].emailKey);
    }

    setState(() {
      userEmails = tempUserEmails;
      emailKeys = tempEmailKeys;
      print(emailKeys);
    });

    return emailPanels;
  }

  prepareListsForDrawing() async {
    String email = emailController.text;
    String emailPassword = emailPasswordController.text;
    String emailHostName = emailHostController.text;
    String emailPortNumber = emailPortController.text;
    String emailType = emailTypeController.text;

    List<String> tempEmailKeys = emailKeys;
    List<String> tempUserEmails = userEmails;
    String emailKey = email.replaceAll(new RegExp(r'\.'), '');

    List<String> emailConfig = [
      email,
      emailPassword,
      emailHostName,
      emailPortNumber,
      emailType
    ];

    if (emailConfig == null) {
      Fluttertoast.showToast(
          msg: 'Taka domena mailowa nie istnieje',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIos: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white);
    }
    if (UserOperationsOnEmails().checkIfInteria(emailConfig[2])) {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return MyDialog(
              title: "Jeśli używasz poczty Interia",
              descriptions:
                  "Zaznacz powyższe w ustawieniach swojej poczty aby można było pobierać z niej faktury. Z powodu błędu w Javamail, bez zmiany tego ustawienia aplikacja się zawiesi.",
              img: "interia_settings.png",
              text: 'Rozumiem',
            );
          });
    }

    DatabaseOperations().addUserEmailToDatabase(
        emailKey, email, emailPassword, emailConfig, username);

    List<Padding> tempEmailPanels = emailPanels;
    tempEmailPanels.add(emailPanel(email, emailKey));
    tempEmailKeys.add(emailKey);
    tempUserEmails.add(email);

    setState(() {
      emailPanels = tempEmailPanels;
      emailKeys = tempEmailKeys;
      userEmails = tempUserEmails;
      print("EmailKeys:");
      print(emailKeys);
      print("userEmails:");
      print(userEmails);
    });
  }

  removeUserEmail(String emailKey, String email) {
    DBRef.child('Users')
        .child(username)
        .child('myEmails')
        .child(emailKey)
        .remove();

    List<Padding> tempEmailPanels = emailPanels;

    tempEmailPanels.removeAt(emailKeys.indexOf(emailKey));

    emailKeys.remove(emailKey);
    userEmails.remove(email);

    setState(() {
      emailPanels = tempEmailPanels;
    });
  }

  bool checkIfEmailsTheSame(String thisMail) {
    bool emailAlreadyExists = false;
    print(userEmails);
    for (String otherEmail in userEmails) {
      if (otherEmail == thisMail) {
        emailAlreadyExists = true;
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
            title: Container(
              height: 40,
              decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.all(Radius.circular(10))),
              child: Center(
                  child: Text(
                title,
                style: TextStyle(color: Colors.white),
              )),
            ),
            content: Padding(
              padding: const EdgeInsets.all(8.0),
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
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
                    TextField(
                      controller: emailPasswordController,
                      decoration: InputDecoration(
                          contentPadding: EdgeInsets.only(top: 20, bottom: 20),
                          prefixIcon: Padding(
                            padding: const EdgeInsets.only(left: 20, right: 20),
                            child: Icon(Icons.person_outline),
                          ),
                          filled: true,
                          fillColor: Colors.grey.withOpacity(0.7),
                          hintText: "Hasło do maila",
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
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              UiElements().drawButton(
                                  210,
                                  40,
                                  "Odkryj ustawienia",
                                  Colors.white,
                                  Colors.blue,
                                  Colors.blue,
                                  context,
                                  null,
                                  [context],
                                  fillEmailParams),
                              Expanded(
                                flex: 1,
                                child: CircleAvatar(
                                  backgroundColor: Colors.transparent,
                                  child: IconButton(
                                    padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                                    icon: Icon(
                                      Icons.info,
                                      size: 40,
                                    ),
                                    color: Colors.blue,
                                    onPressed: () {
                                      showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return MyDialog(
                                              title: "Info ",
                                              descriptions:
                                                  "Aktywuje automatyczne sprawdzenie poczty. Dla niektórych skrzynek, może spowodować długie odkrywanie parametrów poczty. Funkcja eksperymentalna",
                                              img: "warning.PNG",
                                              text: 'Rozumiem',
                                            );
                                          });
                                    },
                                  ),
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                    Center(
                        child: Text(
                      "Parametry poczty:",
                      style: TextStyle(
                          color: Colors.blue,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    )),
                    SizedBox(height: 25),
                    TextField(
                      controller: emailHostController,
                      decoration: InputDecoration(
                          contentPadding: EdgeInsets.only(top: 20, bottom: 20),
                          prefixIcon: Padding(
                            padding: const EdgeInsets.only(left: 20, right: 20),
                            child: Icon(Icons.person_outline),
                          ),
                          filled: true,
                          fillColor: Colors.grey.withOpacity(0.7),
                          hintText: "Nazwa hosta:",
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
                    TextField(
                      controller: emailPortController,
                      decoration: InputDecoration(
                          contentPadding: EdgeInsets.only(top: 20, bottom: 20),
                          prefixIcon: Padding(
                            padding: const EdgeInsets.only(left: 20, right: 20),
                            child: Icon(Icons.person_outline),
                          ),
                          filled: true,
                          fillColor: Colors.grey.withOpacity(0.7),
                          hintText: "Port poczty przychodzącej:",
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
                    TextField(
                      controller: emailTypeController,
                      decoration: InputDecoration(
                          contentPadding: EdgeInsets.only(top: 20, bottom: 20),
                          prefixIcon: Padding(
                            padding: const EdgeInsets.only(left: 20, right: 20),
                            child: Icon(Icons.person_outline),
                          ),
                          filled: true,
                          fillColor: Colors.grey.withOpacity(0.7),
                          hintText: "Typ serwera:",
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
                        child: Text(
                          'Dodaj',
                          style: TextStyle(color: Colors.white),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        color: Colors.blue,
                        onPressed: () {
                          if (!checkIfEmailsTheSame(emailController.text))
                            addEmail(context);
                          else {
                            Fluttertoast.showToast(
                                msg: 'Taki mail jest już zdefiniowany',
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.CENTER,
                                timeInSecForIos: 1,
                                backgroundColor: Colors.red,
                                textColor: Colors.white);
                          }
                        })
                  ],
                ),
              ),
            )),
      );

  fillEmailParams(List<dynamic> args) async {
    String email = emailController.text;
    String password = emailPasswordController.text;
    BuildContext context = args[0];

    emailHostController.text = "Pobieram ...";
    emailPortController.text = "Pobieram ...";
    emailTypeController.text = "Pobieram ...";

    AlertDialog discoverSettingsDialog = new UiElements()
        .showLoaderDialog(context, "Odkrywam ustawienia...", true);

    List<String> emailParams =
        await UserOperationsOnEmails().discoverSettings(email, password);

    Navigator.pop(context);

    setState(() {
      emailHostController.text = emailParams[2];
      emailPortController.text = emailParams[3];
      emailTypeController.text = emailParams[4];
    });
  }

  void addEmail(BuildContext context) {
    print("Username " + username);
    print(emailController.text);
    print(emailPasswordController.text);

    if (emailController.text == "" ||
        emailPasswordController.text == "" ||
        emailHostController.text == "" ||
        emailPortController.text == "" ||
        emailTypeController.text == "") {
      Fluttertoast.showToast(
          msg: 'Nie wszystkie pola zostały wypełnione',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIos: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white);
    } else {
      Navigator.pop(context, false);
      prepareListsForDrawing();
    }
  }
}
