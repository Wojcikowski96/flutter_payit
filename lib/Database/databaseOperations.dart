import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_payit/Objects/userEmail.dart';
import 'dart:async';
import 'dart:core';
import 'package:path/path.dart';
import 'package:flutter_payit/Objects/invoice.dart';

class DatabaseOperations {
  final DBRef = FirebaseDatabase.instance.reference();

  Future<List<int>> getUserPrefsFromDB(String username) async {
    List<int> prefs = new List();
    final dbSnapshot =
        await DBRef.child("Users").child(username).child("userPrefs").once();

    Map<dynamic, dynamic> values = dbSnapshot.value;

    print(values);

    if (values != null) {
      values.forEach((key, values) {
        prefs.add(values);
      });
    }
    return prefs;
  }

  void addTrustedEmailsToDatabase(
      String emailKey, String email, String customName, String username) {
    DBRef.child('Users')
        .child(username)
        .child('invoicesEmails')
        .child(emailKey)
        .set({"username": email, "customname": customName});
  }

  void addUserEmailToDatabase(String emailKey, String email,
      String emailPassword, List<String> emailConfig, String username) {
    DBRef.child('Users').child(username).child('myEmails').child(emailKey).set({
      "username": email,
      "password": emailPassword,
      "hostname": emailConfig[2],
      "port": emailConfig[3],
      "protocol": emailConfig[4],
      "lastUID": 0
    });
  }

  Future<void> resetUID(String username) async {
    List<String> emailKeys = new List();
    final dbSnapshot = await DBRef.child("Users").child(username).once();

    Map<dynamic, dynamic> values = dbSnapshot.value;

    if (values != null) {
      values.forEach((key, values) {
        emailKeys.add(key);
      });
    }
    print("emailKeys " + emailKeys.toString());
    for (String emailKey in emailKeys) {
      DBRef.child('Users')
          .child(username)
          .child('myEmails')
          .child(emailKey)
          .set({"lastUID": 0});
    }
  }

  Future<List<UserEmail>> getUserEmailsFromDb(String username) async {
    List<UserEmail> allUserEmails = new List();

    final dbSnapshot =
        await DBRef.child("Users").child(username).child("myEmails").once();

    Map<dynamic, dynamic> values = dbSnapshot.value;

    if (values != null) {
      values.forEach((key, values) {
        allUserEmails.add(UserEmail(
            values['username'],
            values['password'],
            values['hostname'],
            values['port'],
            values['protocol'],
            values['lastUID'],
            key));
      });
    }
    print("allUserEmails");
    print(allUserEmails);
    return allUserEmails;
  }

  void addInvoiceToDatabase(
      String paymentDate,
      String paymentAmount,
      String categoryName,
      String userMailName,
      String senderMailName,
      String account,
      String path,
      String username) {
    String editedPath = basename(path).replaceAll(".", "");

    DBRef.child('Users')
        .child(username)
        .child('editedInvoices')
        .child(editedPath)
        .set({
      "categoryName": categoryName,
      "userMail": userMailName,
      "senderMail": senderMailName,
      "paymentAmount": paymentAmount,
      "paymentDate": paymentDate,
      "accountForTransfer": account,
      "pathToAttachment" : path
    });
  }

  Future<List<Invoice>> getModifiedInvoices(String username) async {
    List<Invoice> modifiedInvoices = new List();
    final dbSnapshot = await DBRef.child("Users").child(username).child("editedInvoices").once();
    Map<dynamic, dynamic> values = dbSnapshot.value;
    print("Wartość paymentAmount");
    print(values);
    if (values != null) {
      values.forEach((key, values) {
        Invoice invoice = new Invoice(values["categoryName"], values["userMail"], values["senderMail"],
            double.parse(values["paymentAmount"]), values["paymentDate"], values["accountForTransfer"], true, values["pathToAttachment"], Colors.blue);
        modifiedInvoices.add(invoice);

      });
    }
  return modifiedInvoices;
  }
}
