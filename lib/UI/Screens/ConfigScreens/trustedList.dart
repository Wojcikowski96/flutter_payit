
import 'package:flutter/material.dart';
import 'package:flutter_payit/Database/databaseOperations.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_payit/constrants.dart';
import 'package:flutter_payit/UI/HelperClasses/dialog.dart';
import 'package:flutter_payit/UI/Screens/homePage.dart';

class TrustedListPanel extends StatefulWidget {
  @override
  _TrustedListPanelState createState() => _TrustedListPanelState();
}

class _TrustedListPanelState extends State<TrustedListPanel> {
  final TextEditingController emailController = new TextEditingController();
  final TextEditingController nameController = new TextEditingController();
  bool isSwitched = false;
  var storage = FlutterSecureStorage();
  String username = "JohnDoe", password = "qwerty";
  List<Padding> emailPanels = new List();
  List<String> trustedEmails = new List();
  List<String> customNames = new List();
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
          resizeToAvoidBottomInset: false,
          body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(children: [
            SizedBox(
              height: 40,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "Zaufana lista",
                style: TextStyle(fontSize: 35, color: Colors.blue),
              ),
            ),
            Container(
              child: Image.asset(
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
            SizedBox(
              height: 20
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    "Zresetuj UID:",
                    style: TextStyle(
                        fontSize: 24,
                        color: Colors.blue
                    ),
                  ),

                ),
                Expanded(
                  flex: 1,
                  child: SizedBox(
                    width: 200,
                    height: 50,
                    child: Switch(

                     value: isSwitched,
                     onChanged: (value) {
                        setState(() {
                          if(isSwitched ==false){
                            isSwitched = true;

                          }else{
                            isSwitched = false;
                          }
                        });
                      },
                      activeTrackColor: Colors.blue,
                     activeColor: Colors.blue,
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: CircleAvatar(
                    backgroundColor: Colors.transparent,
                    child: IconButton(
                      padding: EdgeInsets.fromLTRB(20, 0, 0, 0),
                      icon: Icon(Icons.info,size: 40,),
                      color: Colors.blue,
                      onPressed: () {
                        showDialog(context: context,
                            builder: (BuildContext context){
                              return MyDialog(
                                title: "O UID",
                                descriptions: "Aktywowane ustawi wartość UID na 0, czyli aplikacja przejrzy wszystkie skrzynki pocztowe od nowa. Przydatne gdy dodasz nowy mail, a chcesz pobrać z niego starsze faktury. Będzie się to wiązać z wczytywaniem jak przy pierwszym uruchomieniu (kilka minut). Jeśli zależy Ci tylko na fakturach, które dopiero się pojawią, pozostaw wyłączone.",
                                img: "warning.PNG",
                                text: 'Rozumiem',
                              );
                            }
                        );
                      },
                    ),

                  ),

                )
              ],
            ),
            ),

              SizedBox(
                height: 80,
                width: 200,
                child: RaisedButton(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18.0),
                      side: BorderSide(color: Colors.blue, width: 5)),
                  onPressed: () {
                    if(isSwitched){
                      DatabaseOperations().resetUID(username);
                    }
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => homePage(DateTime.now(), new List(), true)),
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
          ]),
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.blue,
          child: Icon(Icons.add),
          onPressed: () {
            displayDialog(context, "Dodaj nadawcę faktur:");
          },
        ),
      );

  }

  Padding emailPanel(String email, String emailKey, String customName) {
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
          padding: const EdgeInsets.all(0.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
                Container(
                  decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.blue,
                        width: 4,
                      ),
                      color: Colors.blue,
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                  child: Text(
                    customName,
                    style: TextStyle(fontSize: 30, color: Colors.white),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 9,
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              email,
                              style: TextStyle(fontSize: 20, color: Colors.blue),
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
                    ],
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
    List<String> tempCustomNames = new List();
    List<Padding> emailPanels = new List();

    final dbSnapshot = await DBRef.child("Users")
        .child(username)
        .child("invoicesEmails")
        .once();

    Map<dynamic, dynamic> values = dbSnapshot.value;

    if (values != null) {
      values.forEach((key, values) {
        tempUserEmails.add(values["username"].toString());
        tempCustomNames.add(values["customname"]);
        tempEmailKeys.add(key.toString());
      });
    }

    for (int i = 0; i < tempUserEmails.length; i++) {
      emailPanels.add(
          emailPanel(tempUserEmails[i], tempEmailKeys[i], tempCustomNames[i]));
    }

    setState(() {
      trustedEmails = tempUserEmails;
      print("User emails w trusted:");
      print(trustedEmails);
      emailKeys = tempEmailKeys;
      customNames = tempCustomNames;
    });

    return emailPanels;
  }

  void addTrustedEmail(BuildContext context)  {

    if(emailController.text=="" || nameController.text==""){

      Fluttertoast.showToast(
          msg: 'Nie wszystkie pola zostały wypełnione',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIos: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white
      );

    }

    else if (!checkIfEmailsTheSame(emailController.text)){
      Navigator.pop(context, false);
      prepareListsForDrawing(
          emailController.text, nameController.text);
    }else{
      Fluttertoast.showToast(
          msg: 'Taki mail jest już zdefiniowany',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIos: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white);
    }
  }

  prepareListsForDrawing(String email, String customName) {
    String emailKey = email.replaceAll(new RegExp(r'\.'), '');
    List<String> tempEmailKeys = emailKeys;
    List<String> tempUserEmails = trustedEmails;

    DatabaseOperations()
        .addTrustedEmailsToDatabase(emailKey, email, customName, username);

    List<Padding> tempEmailPanels = emailPanels;
    tempEmailPanels.add(emailPanel(email, emailKey, customName));
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

  bool checkIfEmailsTheSame(String thisMail) {
    bool emailAlreadyExists = false;
    print(trustedEmails);
    for (String otherEmail in trustedEmails) {
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
            title: Center(
                child: Text(
              title,
              style: TextStyle(color: Colors.blue),
            )),
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
                    Center(
                        child: Text(
                      "Nazwij nadawcę faktur:",
                      style: TextStyle(color: Colors.blue),
                    )),
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
                          child: Text(
                            'Dodaj',
                            style: TextStyle(color: Colors.white),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          color: Colors.blue,
                          onPressed: () {
                            addTrustedEmail(context);
                          }),

                  ],
                ),
              ),
            )),
      );
}
