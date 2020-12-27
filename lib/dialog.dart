import 'package:flutter/material.dart';

import 'constrants.dart';

class MyDialog extends StatefulWidget {
  final String title, descriptions, text, img;

  const MyDialog({Key key, this.title, this.descriptions, this.text, this.img}) : super(key: key);

  @override
  _MyDialogState createState() => _MyDialogState();
}

class _MyDialogState extends State<MyDialog> {

  @override
  Widget build(BuildContext context) {
    return showMyDialog(context);
    throw UnimplementedError();
  }

  Dialog showMyDialog(BuildContext context) {
    return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Constants.padding),
        ),

        elevation: 5,
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            height: 260,
            child: Column(
              children: [
                Text(widget.title, style: TextStyle(fontSize: 24, color: Colors.blue)),
                SizedBox(
                  height: 20,
                ),
                Image.asset(widget.img),
                SizedBox(height: 20,),
                Text(widget.descriptions),
                RaisedButton(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  color: Colors.blue,
                  onPressed: () => Navigator.pop(context, false), // passing false
                  child: Text(widget.text, style: TextStyle(color: Colors.white),),
                )
              ],
            ),
          ),
        ));
  }
}
