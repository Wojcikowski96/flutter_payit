import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_payit/Database/databaseOperations.dart';
import 'package:flutter_payit/Objects/invoice.dart';
import 'package:flutter_payit/Objects/notificationItem.dart';
import 'package:flutter_payit/UI/Screens/paymentDataWidget.dart';

import 'consolidedEventsView.dart';

class ConsolidedInvoicesView extends StatefulWidget {
  List<String> urgencyNames = [
    "Pilne",
    "Średnio pilne",
    "Mało pilne",
    "Niezdefiniowane",
    "Twoje skrzynki e-mail"
  ];
  List<Color> colors = [
    Colors.red,
    Colors.amber,
    Colors.green,
    Colors.grey,
    Colors.blue
  ];
  List<Invoice> undefinedInvoicesInfo;
  List<Invoice> definedInvoicesInfo;
  List<List<Widget>> invoicesTilesForConsolided = new List();

  String loggedUserName;
  List<NotificationItem> notificationItems;
  ConsolidedInvoicesView(this.loggedUserName, this.undefinedInvoicesInfo,
      this.definedInvoicesInfo, this.notificationItems);
  @override
  _ConsolidedInvoicesViewState createState() => _ConsolidedInvoicesViewState();
}

class _ConsolidedInvoicesViewState extends State<ConsolidedInvoicesView> {

  @override
  Widget build(BuildContext context) {

    List<List<Widget>> listForExpandables = constructInvoicesWidgets(widget.definedInvoicesInfo, context);
    listForExpandables.add(List.generate(widget.notificationItems.length,
            (index) => widget.notificationItems[index]));
    return ListView.builder(
      itemBuilder: (BuildContext context, int index) {
        return ExpandableListViewItem(
            title: widget.urgencyNames[index],
            color: widget.colors[index],
            invoices: listForExpandables[index]);
      },
      itemCount: 5,
    );
  }

  List<List<Widget>> constructInvoicesWidgets(
      List<Invoice> invoicesInfo, BuildContext context) {
    List<List<Widget>> all = new List();
    List<Widget> urgent = new List();
    List<Widget> mediumUrgent = new List();
    List<Widget> notUrgent = new List();
    List<Widget> undefined = new List();

    for (Invoice i in invoicesInfo) {
      if (i.color == Colors.red) {
        urgent
            .add(PaymentWidget.paymentCard(invoicesInfo, i, i.color, context));
      } else if (i.color == Colors.amber) {
        mediumUrgent
            .add(PaymentWidget.paymentCard(invoicesInfo, i, i.color, context));
      } else if (i.color == Colors.green) {
        notUrgent
            .add(PaymentWidget.paymentCard(invoicesInfo, i, i.color, context));
      }
    }

    for (Invoice u in widget.undefinedInvoicesInfo) {
      undefined.add(PaymentWidget.paymentCard(
          widget.undefinedInvoicesInfo, u, u.color, context));
    }

    all.add(urgent);
    all.add(mediumUrgent);
    all.add(notUrgent);
    all.add(undefined);
    return all;
  }


}
