import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class UiElements {
  SizedBox drawButton(
      double width,
      double height,
      String text,
      BuildContext context,
      Widget onPressedRoute,
      List<dynamic> args,
      Function method) {
    return SizedBox(
      width: width,
      height: height,
      child: RaisedButton(
        color: Colors.white,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18.0),
            side: BorderSide(color: Colors.blue, width: 5)),
        onPressed: () {
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
            maxLines: 1,
            style: TextStyle(color: Colors.blue, fontSize: 20),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  showLoaderDialog(BuildContext context, String message) {
    AlertDialog alert = AlertDialog(
      content: new Row(
        children: [
          CircularProgressIndicator(),
          Container(
              margin: EdgeInsets.only(left: 7), child: Text(message + "...")),
        ],
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

  SnackBar myShowSnackBar(String text) {
    return SnackBar(
        content: Row(children: [
      Text("Synchronizuję ..."),
      CircularProgressIndicator(),
    ]));
  }
  //
}
