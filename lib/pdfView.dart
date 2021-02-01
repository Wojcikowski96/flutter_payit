import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_payit/uiElements.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class PdfView extends StatefulWidget {
  final String path;

  PdfView(this.path);
  @override
  _PdfViewState createState() => _PdfViewState();
}

class _PdfViewState extends State<PdfView> {
  int invoiceFieldsFlex = 1;
  TextEditingController invoicePaymentDateController;
  TextEditingController invoicePaymentAmountController;

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
              child: Container(
                color: Colors.grey,
                child: Column(
                  children: [
                    Text("Dane z faktury: ", style: TextStyle(fontSize: 25, color: Colors.white),),
                    SizedBox(height: 10,),
                    Text("E-mail nadawcy:", style: TextStyle(fontSize: 25, color: Colors.white),),
                    SizedBox(height: 10,),
                    Text("asdas@gfd.com", style: TextStyle(fontSize: 25, color: Colors.white),),
                    SizedBox(height: 10,),
                    UiElements().myCustomTextfield(invoicePaymentAmountController, "", Colors.white, Icons.money),
                    SizedBox(height: 10,),
                    UiElements().myCustomTextfield(invoicePaymentAmountController, "", Colors.white, Icons.calendar_view_day),
                    SizedBox(height: 10,),
                    UiElements().myCustomTextfield(invoicePaymentAmountController, "", Colors.white, Icons.calendar_view_day)
                  ],
                ),
              ),

          )])



    );}
}
