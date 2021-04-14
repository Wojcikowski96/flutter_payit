import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_payit/IsUserLoggedChecker/MySharedPreferences.dart';
import 'package:flutter_payit/Main/main.dart';
import 'package:flutter_payit/Objects/invoice.dart';
import 'package:flutter_payit/Objects/warningNotification.dart';
import 'package:flutter_payit/UI/Screens/ConfigScreens/emailBoxesPanel.dart';
import 'package:flutter_payit/UI/Screens/ConfigScreens/timeInterval.dart';
import 'package:flutter_payit/UI/Screens/ConfigScreens/trustedList.dart';

import 'consolidedEventsView.dart';

class UiElements {
  SizedBox drawButton(
      double width,
      double height,
      String text,
      Color Fillcolor,
      Color borderColor,
      Color textColor,
      BuildContext context,
      Widget onPressedRoute,
      List<dynamic> args,
      Function method) {
    return SizedBox(
      width: width,
      height: height,
      child: RaisedButton(
        color: Fillcolor,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18.0),
            side: BorderSide(color: borderColor, width: 5)),
        onPressed: () async {
          if (method != null) {
            method(args);
          }
          if (onPressedRoute != null) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => onPressedRoute),
            );
          }
        },
        child: Center(
          child: Text(
            text,
            maxLines: 3,
            style: TextStyle(color: textColor, fontSize: 20),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  showLoaderDialog(BuildContext context, String message, bool isVisible) {
    AlertDialog alert = AlertDialog(
      content: Visibility(
        visible: isVisible,
        child: new Row(
          children: [
            CircularProgressIndicator(),
            Container(
                margin: EdgeInsets.only(left: 7), child: Text(message + "...")),
          ],
        ),
      ),
    );
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }


  TextField myCustomTextfield(TextEditingController controller, String hintText,
      Color fillColor, IconData icon) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
          contentPadding: EdgeInsets.only(top: 20, bottom: 20),
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 20, right: 20),
            child: Icon(icon),
          ),
          filled: true,
          fillColor: fillColor,
          hintText: hintText,
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide(color: Colors.grey, width: 2)),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide(
                width: 2,
                color: Colors.grey,
              ))),
    );
  }

  Drawer homePageDrawerMenu(BuildContext context, MethodChannel methodChannel,
      String username, DropdownButton<String> selectEmailAddress) {
    return Drawer(
      // Add a ListView to the drawer. This ensures the user can scroll
      // through the options in the drawer if there isn't enough vertical
      // space to fit everything.
      child: ListView(
        // Important: Remove any padding from the ListView.
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            child: Column(
              children: [
                Text(
                  username,
                  style: TextStyle(fontSize: 50, color: Colors.white),
                ),
                Container(child: selectEmailAddress, width: 300)
              ],
            ),
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
          ),
          ListTile(
            title: Text('Zarządzaj adresami e-mail'),
            onTap: () {
              methodChannel.invokeMethod("stopThreadsAndTimers");
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => EmailBoxesPanel()),
              );
            },
          ),
          ListTile(
            title: Text('Edytuj zaufaną listę nadawców faktur'),
            onTap: () {
              methodChannel.invokeMethod("stopThreadsAndTimers");
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => TrustedListPanel()),
              );
            },
          ),
          ListTile(
            title: Text('Ustawienia'),
            onTap: () {
              methodChannel.invokeMethod("stopThreadsAndTimers");
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => TimeInterval()));
            },
          ),
          ListTile(
            title: Text('Przełącz użytkownika'),
            onTap: () {
              methodChannel.invokeMethod("stopThreadsAndTimers");
              MySharedPreferences.instance.setBooleanValue("isLoggedIn", false);
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => MyApp(DateTime.now())));
            },
          ),
        ],
      ),
    );
  }

  ListView consolidedInvoicesView(List<String> urgencyNames, List<Color> colors,
      List<List<Widget>> invoicesTilesForConsolided) {
    return ListView.builder(
      itemBuilder: (BuildContext context, int index) {
        return ExpandableListViewItem(
            title: urgencyNames[index],
            color: colors[index],
            invoices: invoicesTilesForConsolided[index]);
      },
      itemCount: 5,
    );
  }

  Icon listIcon() {
    return Icon(
      Icons.view_list,
      color: Colors.white,
    );
  }

  Icon calendarIcon() {
    return Icon(
      Icons.table_chart,
      color: Colors.white,
    );
  }

  Opacity notificationsNumIcon(int notificationsLength) {
    if (notificationsLength != 0) {
      return Opacity(
          opacity: 1.0,
          child: Container(
            height: 25,
            width: 25,
            decoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.blue)),
            child: Center(
                child: Text(
              notificationsLength.toString(),
              style: TextStyle(
                  fontSize: 15,
                  color: Colors.blue,
                  fontWeight: FontWeight.bold),
            )),
          ));
    } else {
      return Opacity(
          opacity: 0.0,
          child: Container(
            height: 18,
            width: 18,
            decoration:
                BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            child: Center(
                child: Text(
              notificationsLength.toString(),
              style: TextStyle(fontSize: 15, color: Colors.blue),
            )),
          ));
    }
  }
  //
}
