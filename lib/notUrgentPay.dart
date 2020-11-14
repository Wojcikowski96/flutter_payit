import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class notUrgentPay extends StatelessWidget{
  final PageController pageController;
  const notUrgentPay({Key key, this.pageController}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
          backgroundColor: Colors.green,
          // leading: IconButton(icon: Icon(Icons.menu), onPressed: (){
          //
          // }),
          title: Text("Mało pilne"),
          actions: <Widget>[


          ]
      ),


    );
  }

}