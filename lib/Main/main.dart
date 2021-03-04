import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_payit/IsUserLoggedChecker/MySharedPreferences.dart';
import 'package:flutter_payit/UI/Screens/homePage.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_payit/UI/Screens/loginScreen.dart';
import 'package:bringtoforeground/bringtoforeground.dart';

String selectedNotificationPayload;

Future<void> main() async {
  launchApp(DateTime.now());
}

void launchApp(DateTime date) {
  WidgetsFlutterBinding.ensureInitialized();
  initializeDateFormatting().then((_) => runApp(MyApp(date)));
}

class MyApp extends StatefulWidget {
  final DateTime date;
  MyApp(this.date);

  @override
  State<StatefulWidget> createState() {
    return _MyAppState();
  }
}

class _MyAppState extends State<MyApp> {
  static const platform = const MethodChannel("com.example.flutter_payit");
  bool isLoggedIn = false;

  @override
  void initState() {
    platform.invokeMethod("stopService");
    super.initState();
  }

  _MyAppState() {
    MySharedPreferences.instance
        .getBooleanValue("isLoggedIn")
        .then((value) => setState(() {
              isLoggedIn = value;
            }));
  }

  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'PayIt',
        theme: ThemeData(
          primarySwatch: Colors.lightBlue,
        ),
        home: isLoggedIn ? homePage(DateTime.now(),new List()) : LoginPage());
  }
}
