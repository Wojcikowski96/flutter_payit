import 'dart:ui';
import 'package:flutter/material.dart';

class Utils{
  Color setUrgencyColorBasedOnDate(DateTime date, List<int> preferences) {
    Color color = Colors.blue;
    if ((date.difference(DateTime.now()).inDays).abs() <= preferences[0]) {
      color = Colors.red;
    } else if ((date.difference(DateTime.now()).inDays).abs() > preferences[0] &&
        (date.difference(DateTime.now()).inDays).abs() <= preferences[1]) {
      color = Colors.amber;
    } else if ((date.difference(DateTime.now()).inDays).abs() > preferences[1] &&
        (date.difference(DateTime.now()).inDays).abs() <= 44000) {
      color = Colors.green;
    }
    return color;
  }

  Color colorFromName(String name) {
    if (name == "MaterialColor(primary value: Color(0xfff44336))") {
      return Colors.red;
    } else if (name == "MaterialColor(primary value: Color(0xffffc107))") {
      return Colors.amber;
    } else {
      return Colors.green;
    }
  }


}