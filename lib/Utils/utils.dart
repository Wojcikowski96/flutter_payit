import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:payit/Objects/invoice.dart';

class Utils{
  Color setUrgencyColorBasedOnDate(DateTime date, List<int> preferences) {
    Color color = Colors.blue;
    if ((date.difference(DateTime.now()).inDays).abs() <= preferences[3]) {
      color = Colors.red;
    } else if ((date.difference(DateTime.now()).inDays).abs() > preferences[3] &&
        (date.difference(DateTime.now()).inDays).abs() <= preferences[2]) {
      color = Colors.amber;
    } else if ((date.difference(DateTime.now()).inDays).abs() > preferences[2] &&
        (date.difference(DateTime.now()).inDays).abs() <= 44000) {
      color = Colors.green;
    }else{
      color = Colors.black26;
    }
    return color;
  }
  Color setUrgencyColor(List<Invoice> tempInvoicesInfo, List<int> preferences) {
    Color color = Colors.blue;
    for (Invoice singleInvoice in tempInvoicesInfo) {
      if ((DateTime.parse(singleInvoice.paymentDate)
          .difference(DateTime.now())
          .inDays)
          .abs() <=
          preferences[3]) {
        color = Colors.red;
      } else if ((DateTime.parse(singleInvoice.paymentDate)
          .difference(DateTime.now())
          .inDays)
          .abs() >
          preferences[3] &&
          (DateTime.parse(singleInvoice.paymentDate)
              .difference(DateTime.now())
              .inDays)
              .abs() <=
              preferences[2]) {
        color = Colors.amber;
      } else if ((DateTime.parse(singleInvoice.paymentDate)
          .difference(DateTime.now())
          .inDays)
          .abs() >
          preferences[2] &&
          (DateTime.parse(singleInvoice.paymentDate)
              .difference(DateTime.now())
              .inDays)
              .abs() <=
              44000) {
        color = Colors.green;
      }
      return color;
    }
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

  String getInvoiceSenderCustomName(List<List<String>> trustedEmails, String path) {
    String nameWithFile = "lol";
    for (List<String> trustedEmail in trustedEmails) {
      if (path.contains(trustedEmail[0])) {
        nameWithFile = trustedEmail[1];
      }
    }

    print("Path " +
        path +
        " nazwa " +
        nameWithFile +
        " trusted emails " +
        trustedEmails.toString());

    return nameWithFile;
  }

  bool checkIsAccountControlNumValid(String accountNumber){

    accountNumber="PL"+accountNumber;

    bool isNumberCorrect = false;
    String first4;
    String last22;

    first4 = accountNumber.substring(0, 4);

    last22 = accountNumber.substring(4, accountNumber.length );

    String changedAccountNum = (last22 + first4).replaceAll("PL","2521");

    BigInt divR = BigInt.parse(changedAccountNum) % BigInt.from(97);

    if(divR == BigInt.from(1)){
      isNumberCorrect = true;
    }

    return isNumberCorrect;

  }

//  dismissNotification(List <Container> notificationItems, String userEmail, List<Notification> notifications){
//    for()
//
//  }


}