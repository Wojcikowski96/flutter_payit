import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_payit/paymentDataWidget.dart';

class urgentPay extends StatelessWidget {
  final PageController pageController;
  List<Widget> invoices = new List();

  urgentPay({Key key, this.pageController}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    invoices.add(PaymentWidget.paymentCard(
        'Orange S.A', '50 PLN', '01-01.2021'));
    invoices.add(PaymentWidget.paymentCard(
        'Netia S.A', '80 PLN', '11-11.2021'));
    invoices.add(PaymentWidget.paymentCard(
        'T-Mobile S.A', '15 PLN', '06-06.2021'));

    return Scaffold(
      backgroundColor: Colors.red,
      appBar: AppBar(
          backgroundColor: Color.fromRGBO(255, 150, 150, 1),
          // leading: IconButton(icon: Icon(Icons.menu), onPressed: (){
          //
          // }),
          title: Text("Pilne"),
          actions: <Widget>[
          ]
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: GridView.count(
          crossAxisCount: 1,
          childAspectRatio: (height)/(width + 23),
    children: List.generate(invoices.length,
    (index2) => invoices[index2]),
    ),
    ),

    );
  }

}