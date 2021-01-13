import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_payit/paymentDataWidget.dart';

class PaymentPage extends StatelessWidget {
  final PageController pageController;
  final List<Widget> invoices = new List();
  final List<List<String>> invoicesInfo;
  final Color color;
  final String tittle;

  PaymentPage(this.pageController, this.invoicesInfo,
      this.color, this.tittle);

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    invoices.clear();
    for (List<String> singleInvoice in invoicesInfo) {
      if (color == Colors.black26) {
        print("Dodaję fakturę do niezdefiniowanych");
        invoices.add(PaymentWidget.paymentCardWarning(singleInvoice[0], singleInvoice[3], color, context));
      } else {
        print("Dodaję fakturę do zdefiniowanych");
        invoices.add(PaymentWidget.paymentCard(
            singleInvoice[0], singleInvoice[1], singleInvoice[2], singleInvoice[3], color, context));
      }
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
          backgroundColor: color,
          // leading: IconButton(icon: Icon(Icons.menu), onPressed: (){
          //
          // }),
          title: Text(tittle),
          actions: <Widget>[]),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: ListView(
          children:
              List.generate(invoices.length, (index2) => invoices[index2]),
        ),
      ),
    );
  }
}
