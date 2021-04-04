import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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

  SnackBar myShowSnackBar(String text) {
    return SnackBar(
        content: Row(children: [
      Text("Synchronizuję ..."),
      CircularProgressIndicator(),
    ]));
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
  //
}
