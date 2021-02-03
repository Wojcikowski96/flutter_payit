

import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_payit/UI/Screens/loginScreen.dart';

void main() {
  //WidgetsFlutterBinding.ensureInitialized();
  initializeDateFormatting().then((_) => runApp(MyApp()));
}

class MyApp extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PayIt',
      theme: ThemeData(
        primarySwatch: Colors.lightBlue,
      ),
      home: new Scaffold(body: new LoginPage()),
    );
  }
}
