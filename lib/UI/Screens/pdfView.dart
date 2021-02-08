import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_payit/UI/HelperClasses/uiElements.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import 'package:flutter_payit/Database/databaseOperations.dart';
import 'homePage.dart';
import 'package:flutter_payit/Objects/invoice.dart';

class PdfView extends StatefulWidget {
  Invoice invoice;
  List<Invoice> invoices;
  DateTime jumpToDate = DateTime.now();
  var storage = FlutterSecureStorage();

  PdfView(this.invoices, this.invoice);
  @override
  _PdfViewState createState() => _PdfViewState();
}

class _PdfViewState extends State<PdfView> {
  int invoiceFieldsFlex = 1;
  String username;
  TextEditingController invoicePaymentDateController =
      new TextEditingController();
  TextEditingController invoicePaymentAmountController =
      new TextEditingController();
  TextEditingController invoiceAccountNumController =
      new TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () async {
      invoicePaymentAmountController.text =
          widget.invoice.paymentAmount.toString();
      invoicePaymentDateController.text = widget.invoice.paymentDate;
      invoiceAccountNumController.text =
          widget.invoice.accountForTransfer.toString();
      username = (await widget.storage.read(key: "username")).toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    File file = new File(widget.invoice.downloadPath);
    print("path w ekranie z pdf");
    print(widget.invoice.downloadPath);
    return Scaffold(
        body: Column(children: [
      Expanded(
        flex: 1,
        child: Container(child: SfPdfViewer.file(file)),
      ),
      Expanded(
        flex: invoiceFieldsFlex,
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Container(
            color: Colors.grey,
            child: Column(
              children: [
                Text(
                  "Edycja i podgląd danych",
                  style: TextStyle(fontSize: 35, color: Colors.white),
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  "E-mail nadawcy:",
                  style: TextStyle(fontSize: 15, color: Colors.white),
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  widget.invoice.senderMail,
                  style: TextStyle(fontSize: 20, color: Colors.white),
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  "Kategoria rachunku:",
                  style: TextStyle(fontSize: 15, color: Colors.white),
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  widget.invoice.categoryName,
                  style: TextStyle(fontSize: 25, color: Colors.white),
                ),
                SizedBox(
                  height: 25,
                ),
                Text(
                  "Do zapłaty:",
                  style: TextStyle(fontSize: 15, color: Colors.white),
                ),
                UiElements().myCustomTextfield(invoicePaymentAmountController,
                    "", Colors.white, Icons.money_sharp),
                SizedBox(
                  height: 10,
                ),
                Text(
                  "Termin zapłaty:",
                  style: TextStyle(fontSize: 15, color: Colors.white),
                ),
                UiElements().myCustomTextfield(invoicePaymentDateController, "",
                    Colors.white, Icons.calendar_today),
                SizedBox(
                  height: 10,
                ),
                Text(
                  "Numer konta do przelewu:",
                  style: TextStyle(fontSize: 15, color: Colors.white),
                ),
                UiElements().myCustomTextfield(invoiceAccountNumController, "",
                    Colors.white, Icons.calendar_view_day),
                SizedBox(
                  height: 25,
                ),
                Row(
                  children: [
                    Expanded(
                        flex: 1,
                        child: Icon(
                          Icons.done,
                          color: Colors.green,
                          size: 50,
                        )),
                    Expanded(
                        flex: 1,
                        child: Icon(
                          Icons.delete_forever,
                          color: Colors.red,
                          size: 50,
                        ))
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                        flex: 4,
                        child: UiElements().drawButton(
                            200,
                            80,
                            "Zatwierdź i dodaj do zdefiniowanych",
                            Colors.grey,
                            Colors.white,
                            Colors.white,
                            context,
                            null,
                            [widget.invoice],
                            editInvoice)),
                    Expanded(flex: 1, child: SizedBox(width: 5)),
                    Expanded(
                        flex: 4,
                        child: UiElements().drawButton(
                            200,
                            80,
                            "Zignoruj fakturę i usuń z listy",
                            Colors.grey,
                            Colors.white,
                            Colors.white,
                            context,
                            homePage(DateTime.now(),new List()),
                            null,
                            null)),
                  ],
                )
              ],
            ),
          ),
        ),
      )
    ]));
  }

  Future<void> editInvoice(List<dynamic> args) async {
    Invoice invoice = args[0];

    invoice.paymentAmount = double.parse(invoicePaymentAmountController.text);
    invoice.paymentDate = invoicePaymentDateController.text;
    invoice.accountForTransfer = invoiceAccountNumController.text;

    await changeModifyStatus(invoice);

    DatabaseOperations().addInvoiceToDatabase(
        invoice.paymentDate,
        invoice.paymentAmount.toString(),
        invoice.categoryName,
        invoice.userMail,
        invoice.senderMail,
        invoice.accountForTransfer.toString(),
        invoice.downloadPath,
        username);

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => homePage(DateTime.parse(invoice.paymentDate),widget.invoices)),
    );

  }

  Future<void> changeModifyStatus(Invoice invoice) async {
    File file = new File(invoice.downloadPath);
    if (!invoice.downloadPath.endsWith("M")) {
      await file.rename(invoice.downloadPath + "M");
      invoice.downloadPath = invoice.downloadPath + "M";
    }
  }
}
