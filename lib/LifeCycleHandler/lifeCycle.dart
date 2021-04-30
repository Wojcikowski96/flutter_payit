import 'dart:core';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LifecycleWatcher extends StatefulWidget {
  static const methodChannel = const MethodChannel("com.example.payit");
  @override
  _LifecycleWatcherState createState() => _LifecycleWatcherState();
}

class _LifecycleWatcherState extends State<LifecycleWatcher>
    with WidgetsBindingObserver {
  AppLifecycleState _lastLifecycleState;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    setState(() {
      _lastLifecycleState = state;
    });
    if (state == AppLifecycleState.paused) {
      startServiceInPlatform();
    }
    else if (state == AppLifecycleState.resumed) {
      stopServiceInPlatform();
    }
  }

  void startServiceInPlatform() async {
    if (Platform.isAndroid) {
      //var methodChannel = MethodChannel("com.example.flutter_payit");
      String data =
          await LifecycleWatcher.methodChannel.invokeMethod("startService");
    }
  }

  void stopServiceInPlatform() async {
    if (Platform.isAndroid) {
      //var methodChannel = MethodChannel("com.example.flutter_payit");
      String data =
      await LifecycleWatcher.methodChannel.invokeMethod("stopService");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 0,
      height: 0,
    );
  }
}
