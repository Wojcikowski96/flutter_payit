import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_payit/uiElements.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import 'homePage.dart';

class PdfView extends StatefulWidget {
  final String path, paymentDate, paymentAmount, paymentAccount;

  PdfView(this.path, this.paymentDate, this.paymentAmount, this.paymentAccount);
  @override
  _PdfViewState createState() => _PdfViewState();
}

class _PdfViewState extends State<PdfView> {
  int invoiceFieldsFlex = 1;
  TextEditingController invoicePaymentDateController = new TextEditingController();
  TextEditingController invoicePaymentAmountController = new TextEditingController();
  TextEditingController invoiceAccountNumController = new TextEditingController();


  @override
  void initState() {
    super.initState();
    setState(() {
      invoicePaymentAmountController.text = widget.paymentAmount;
      invoicePaymentDateController.text = widget.paymentDate;
      invoiceAccountNumController.text = widget.paymentAccount;
    });
    Future.delayed(Duration.zero, () async {

    });
  }

  @override
  Widget build(BuildContext context) {

    File file = new File(widget.path);


    return Scaffold(
      body: Column(
        children: [
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
                      Text("Dane z faktury: ", style: TextStyle(fontSize: 25, color: Colors.white),),
                      SizedBox(height: 10,),
                      Text("E-mail nadawcy:", style: TextStyle(fontSize: 15, color: Colors.white),),
                      SizedBox(height: 10,),
                      Text("asdas@gfd.com", style: TextStyle(fontSize: 20, color: Colors.white),),
                      SizedBox(height: 10,),
                      Text("Do zapłaty:", style: TextStyle(fontSize: 15, color: Colors.white),),
                      UiElements().myCustomTextfield(invoicePaymentAmountController, "", Colors.white, Icons.money_sharp),
                      SizedBox(height: 10,),
                      Text("Termin zapłaty:", style: TextStyle(fontSize: 15, color: Colors.white),),
                      UiElements().myCustomTextfield(invoicePaymentDateController, "", Colors.white, Icons.calendar_today),
                      SizedBox(height: 10,),
                      Text("Numer konta do przelewu:", style: TextStyle(fontSize: 15, color: Colors.white),),
                      UiElements().myCustomTextfield(invoiceAccountNumController, "", Colors.white, Icons.calendar_view_day),
                      SizedBox(height: 25,),
                      Row(

                        children: [
                          Expanded(flex: 1, child: Icon(Icons.done, color: Colors.green, size: 50,)),
                          Expanded(flex: 1, child: Icon(Icons.delete_forever, color: Colors.red, size: 50,))
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(flex: 4, child: UiElements().drawButton(200, 80, "Zatwierdź i dodaj do zdefiniowanych", Colors.grey, Colors.white, Colors.white, context, homePage(), null, null)),
                          Expanded(flex: 1, child: SizedBox(width: 5)),
                          Expanded(flex: 4, child: UiElements().drawButton(200, 80, "Zignoruj fakturę i usuń z listy", Colors.grey, Colors.white, Colors.white, context, homePage(), null, null)),
                        ],
                      )
                    ],
                  ),
                ),
              ),

          )])



    );}
}
