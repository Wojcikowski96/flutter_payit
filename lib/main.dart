
import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'loginScreen.dart';

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
