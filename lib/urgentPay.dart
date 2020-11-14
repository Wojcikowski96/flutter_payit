import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class urgentPay extends StatelessWidget{
  final PageController pageController;
  const urgentPay({Key key, this.pageController}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        backgroundColor: Colors.red,
        // leading: IconButton(icon: Icon(Icons.menu), onPressed: (){
        //
        // }),
          title: Text("Pilne"),
          actions: <Widget>[


          ]
      ),


    );
  }

}