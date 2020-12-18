import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_payit/paymentDataWidget.dart';

class notUrgentPay extends StatelessWidget{
  final PageController pageController;
  List<Widget> invoices = new List();

  notUrgentPay({Key key, this.pageController}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    double width = MediaQuery
        .of(context)
        .size
        .width;
    double height = MediaQuery
        .of(context)
        .size
        .height;
    invoices.add(PaymentWidget.paymentCard(
        'Warunek', '75 PLN', '02-02.2021', Colors.green));

    return Scaffold(

      appBar: AppBar(
          backgroundColor: Colors.greenAccent,
          // leading: IconButton(icon: Icon(Icons.menu), onPressed: (){
          //
          // }),
          title: Text("Mało pilne",),
          actions: <Widget>[
          ]
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: GridView.count(
          crossAxisCount: 1,
          childAspectRatio: (height) / (width + 35),
          children: List.generate(invoices.length,
                  (index2) => invoices[index2]),
        ),
      ),

    );
  }

}