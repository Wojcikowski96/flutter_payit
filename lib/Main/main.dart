import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_payit/IsUserLoggedChecker/MySharedPreferences.dart';
import 'package:flutter_payit/Notifications/notificationHelper.dart';
import 'package:flutter_payit/UI/Screens/homePage.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_payit/UI/Screens/loginScreen.dart';


String selectedNotificationPayload;

Future<void> main() async {

  print("Rozpoczynam maina");

  WidgetsFlutterBinding.ensureInitialized();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  final NotificationAppLaunchDetails notificationAppLaunchDetails =
      await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
  //String initialRoute = HomePage.routeName;
  if (notificationAppLaunchDetails?.didNotificationLaunchApp ?? false) {
    selectedNotificationPayload = notificationAppLaunchDetails.payload;
    //initialRoute = SecondPage.routeName;
  }

  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('app_icon');

  /// Note: permissions aren't requested here just to demonstrate that can be
  /// done later
  final IOSInitializationSettings initializationSettingsIOS =
      IOSInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
          onDidReceiveLocalNotification:
              (int id, String title, String body, String payload) async {
            didReceiveLocalNotificationSubject.add(ReminderNotification(
                id: id, title: title, body: body, payload: payload));
          });

  final InitializationSettings initializationSettings = InitializationSettings(
      initializationSettingsAndroid, initializationSettingsIOS);

  await flutterLocalNotificationsPlugin.initialize(initializationSettings,
      onSelectNotification: (String payload) async {
    if (payload != null) {
      debugPrint('notification payload: $payload');
    }
    selectedNotificationPayload = payload;
    selectNotificationSubject.add(payload);
  });

  print("Notyfikacje zainicjalizowane");

  initializeDateFormatting().then((_) => runApp(MyApp()));

  print("Aplikacja uruchomiona");
}

class MyApp extends StatefulWidget {
  @override


  @override
  State<StatefulWidget> createState() {
    return _MyAppState();
  }
}
class _MyAppState extends State<MyApp>{

  bool isLoggedIn = false;

  _MyAppState() {
    MySharedPreferences.instance
        .getBooleanValue("isLoggedIn")
        .then((value) => setState(() {

      isLoggedIn = value;
      print("isLoggedIn w MyAppState");
      print(isLoggedIn);
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
