import 'package:flutter/material.dart';
import 'package:payit/constrants.dart';

class MyDialog extends StatefulWidget {
  final String title, descriptions, text, img;

  const MyDialog( {Key key, this.title, this.descriptions, this.text, this.img}) : super(key: key);

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
          padding: const EdgeInsets.all(0.0),
          child: Container(
            height: 500,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.blue,
                        width: 4,
                      ),
                      color: Colors.blue,
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                  child: Text(
                    widget.title,
                    style: TextStyle(fontSize: 30, color: Colors.white),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                SizedBox(
                    height: 50,
                    child: Image.asset(widget.img)),
                SizedBox(height: 20,),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(widget.descriptions, style: TextStyle(fontSize: 20,),
                      textAlign: TextAlign.center
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(50, 0, 50, 0),
                  child: RaisedButton(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    color: Colors.blue,
                    onPressed: () => Navigator.pop(context, false), // passing false
                    child: Text(widget.text, style: TextStyle(color: Colors.white),),
                  ),
                )
              ],
            ),
          ),
        ));
  }
}
