import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:rxdart/subjects.dart';

final BehaviorSubject<ReminderNotification> didReceiveLocalNotificationSubject =
BehaviorSubject<ReminderNotification>();

final BehaviorSubject<String> selectNotificationSubject =
BehaviorSubject<String>();

Future<void> initNotifications(
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin) async {
  var initializationSettingsAndroid = AndroidInitializationSettings('app_icon');
  var initializationSettingsIOS = IOSInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
      onDidReceiveLocalNotification:
          (int id, String title, String body, String payload) async {
        didReceiveLocalNotificationSubject.add(ReminderNotification(
            id: id, title: title, body: body, payload: payload));
      });
  var initializationSettings = InitializationSettings(
      initializationSettingsAndroid, initializationSettingsIOS);
  await flutterLocalNotificationsPlugin.initialize(initializationSettings,
      onSelectNotification: (String payload) async {
        if (payload != null) {
          debugPrint('notification payload: ' + payload);
        }
        selectNotificationSubject.add(payload);
      });
}

class ReminderNotification {
  ReminderNotification({
    @required this.id,
    @required this.title,
    @required this.body,
    @required this.payload,
  });

  final int id;
  final String title;
  final String body;
  final String payload;
}

Future<void> showNotificationOnEndSync(FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin,) async {
  const AndroidNotificationDetails androidPlatformChannelSpecifics =
  AndroidNotificationDetails(
      'your channel id', 'your channel name', 'your channel description',
      ticker: 'ticker');
  const NotificationDetails platformChannelSpecifics =
  NotificationDetails(androidPlatformChannelSpecifics,null);
  await flutterLocalNotificationsPlugin.show(
      0, 'Synchronizacja zakończona', 'Przejdź do aplikacji', platformChannelSpecifics,
      payload: 'item x');
}