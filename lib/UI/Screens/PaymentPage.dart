import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_payit/Objects/invoice.dart';
import 'package:flutter_payit/UI/Screens/paymentDataWidget.dart';

class PaymentPage extends StatelessWidget {
  final PageController pageController;
  final List<Widget> invoices = new List();
  final List<Invoice> invoicesInfo;
  final Color color;
  final String title;

  PaymentPage(this.pageController, this.invoicesInfo,
      this.color, this.title);

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    invoices.clear();
    for (Invoice singleInvoice in invoicesInfo) {
      if (color == Colors.black26) {
        print("Dodaję fakturę do niezdefiniowanych");
        invoices.add(PaymentWidget.paymentCard(invoicesInfo, singleInvoice, color, context));
      } else {
        print("Dodaję fakturę do zdefiniowanych");
        invoices.add(PaymentWidget.paymentCard(invoicesInfo, singleInvoice, color, context));
      }
    }
    return Scaffold(
      backgroundColor: Colors.transparent,
//      appBar: AppBar(
//          backgroundColor: color,
//          // leading: IconButton(icon: Icon(Icons.menu), onPressed: (){
//          //
//          // }),
//          title: Text(tittle),
//          actions: <Widget>[]),
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
