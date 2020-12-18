import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_payit/paymentDataWidget.dart';

class mediumUrgentPay extends StatelessWidget{
  final PageController pageController;
  List<Widget> invoices = new List();

  mediumUrgentPay({Key key, this.pageController}) : super(key: key);


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
        'Retsat S.A', '75 PLN', '02-02.2021', Colors.amber));
    invoices.add(PaymentWidget.paymentCard(
        'Kominiarz', '80 PLN', '12-12.2021', Colors.amber));
    invoices.add(PaymentWidget.paymentCard(
        'Leopold', '15 PLN', '07-07.2021', Colors.amber));

    return Scaffold(

      appBar: AppBar(
          backgroundColor: Colors.amberAccent,
          // leading: IconButton(icon: Icon(Icons.menu), onPressed: (){
          //
          // }),
          title: Text("Średnio pilne",),
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