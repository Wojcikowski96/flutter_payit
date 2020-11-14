import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class mediumUrgentPay extends StatelessWidget{
  final PageController pageController;
  const mediumUrgentPay({Key key, this.pageController}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
          backgroundColor: Colors.yellow,
          // leading: IconButton(icon: Icon(Icons.menu), onPressed: (){
          //
          // }),
          title: Text("Mniej pilne"),
          actions: <Widget>[


          ]
      ),


    );
  }

}