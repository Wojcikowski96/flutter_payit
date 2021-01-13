import 'dart:async';
import 'dart:core';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_payit/timeInterval.dart';
import 'package:flutter_payit/trustedList.dart';
import 'package:flutter_payit/PaymentPage.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/services.dart';
import 'package:path_provider_ex/path_provider_ex.dart';
import 'calendarWidget.dart';
import 'emailBoxesPanel.dart';
import 'userOperationsOnEmails.dart';
import 'pdfParser.dart';
import 'package:intl/intl.dart';

class homePage extends StatefulWidget {
  @override
  _homePageState createState() => _homePageState();
}

class _homePageState extends State<homePage> {
  var storage = FlutterSecureStorage();
  String path;
  String paymentDate;
  String paymentAmount;
  String invoiceSender;

  List<int> urgencyPrefs = [300 , 3000];
  List<List<String>> urgentInvoicesInfo = new List();
  List<List<String>> mediumUrgentInvoicesInfo = new List();
  List<List<String>> notUrgentInvoicesInfo = new List();
  List<List<String>> undefinedInvoicesInfo = new List();

  static const platform = const MethodChannel("name");
  Timer timer;
  @override
    void initState() {
    super.initState();

    Future.delayed(Duration.zero, () async {
      path = (await PathProviderEx.getStorageInfo())[0].appFilesDir +
          '/invoicesPDF';

      Directory invoicesDir = new Directory(path);
      invoicesDir.create(recursive: true);

      String username = (await storage.read(key: "username")).toString();

      List<List<String>> trustedEmails =
      await UserOperationsOnEmails().getInvoiceSenders(username);

      await downloadAttachmentForAllMailboxes(username,trustedEmails);
      //timer = Timer.periodic(Duration(seconds: 360), (Timer t) => refreshEmails(username));
      //await PdfParser().pdfToString("asd");

      List<FileSystemEntity> invoiceFileList = await PdfParser().dirContents(path);

      List <String> matchedCustomNames = attachInvoiceCustomNamesToFiles(trustedEmails, invoiceFileList);

      List<String> pdfContentsList = await PdfParser().allPdfToString(invoiceFileList);

      List<List<String>> tempInvoicesInfo = new List();

      int i=0;
      for (String singlePdfContent in pdfContentsList) {
        print(singlePdfContent);
        List <String> singleDetails = new List();
        paymentAmount = extractPayments(singlePdfContent);
        paymentDate = extractDateForParser(singlePdfContent);
        invoiceSender = matchedCustomNames[i];
        singleDetails.add(invoiceSender);
        singleDetails.add(paymentAmount);
        singleDetails.add(paymentDate);
        singleDetails.add(invoiceFileList[i].path);
        tempInvoicesInfo.add(singleDetails);
        i++;
      }
      List <List<String>> tempUrgentInvoices = new List();
      List <List<String>> tempMediumUrgentInvoices = new List();
      List <List<String>> tempNotUrgentInvoices = new List();
      List <List<String>> tempUndefinedUrgentInvoices = new List();

      for(List<String> singleInvoice in tempInvoicesInfo){

        if (-DateTime.parse(singleInvoice[2]).difference(DateTime.now()).inDays<=urgencyPrefs[0]) {
          tempUrgentInvoices.add(singleInvoice);
        } else if (-DateTime.parse(singleInvoice[2]).difference(DateTime.now()).inDays>urgencyPrefs[0]&&-DateTime.parse(singleInvoice[2]).difference(DateTime.now()).inDays<=urgencyPrefs[1]) {
          tempMediumUrgentInvoices.add(singleInvoice);
        } else if (-DateTime.parse(singleInvoice[2]).difference(DateTime.now()).inDays>urgencyPrefs[1]&&-DateTime.parse(singleInvoice[2]).difference(DateTime.now()).inDays<=44000) {
          tempNotUrgentInvoices.add(singleInvoice);
        } else if (-DateTime.parse(singleInvoice[2]).difference(DateTime.now()).inDays>44000) {
          tempUndefinedUrgentInvoices.add(singleInvoice);
        }
      }

      setState(() {
        urgentInvoicesInfo = tempUrgentInvoices;
        mediumUrgentInvoicesInfo = tempMediumUrgentInvoices;
        notUrgentInvoicesInfo = tempNotUrgentInvoices;
        undefinedInvoicesInfo = tempUndefinedUrgentInvoices;
      });

    });
  }

  String extractDateForParser(String singlePdfContent) {
     final dateRegex = RegExp( r'(\d{4}(\/|-|\.)\d{1,2}(\/|-|\.)\d{1,2})|(\d{1,2}(\/|-|\.)\d{1,2}(\/|-|\.)\d{4})',
        multiLine: true);
    List<String> ListOfDates = dateRegex
        .allMatches(singlePdfContent)
        .map((m) => m.group(0))
        .toList();

    List<DateTime> ListOfCorrectDates = new List<DateTime>();

    for (String date in ListOfDates) {
      if (RegExp(r'(\/|-|\.)\d{4}').hasMatch(date)) {
        String dateWithDashes = date.replaceAll(new RegExp(r'\W+'), "-");
        String dateStandard=PdfParser().addedZero(dateWithDashes.split("-")).reversed.join("-");
        ListOfCorrectDates.add(DateTime.parse(dateStandard));
      } else if ((RegExp(r'\d{4}(\/|-|\.)').hasMatch(date))) {
        String dateStandard=date.replaceAll(new RegExp(r'\W+'), '-');
        ListOfCorrectDates.add(DateTime.parse(dateStandard));
      }
    }
          final DateFormat formatter = DateFormat('yyyy-MM-dd');
          final String formattedDate = formatter.format(DateTime.parse((PdfParser().findLatestDate(ListOfCorrectDates)).toString()));

          print("Data zapłaty faktury to "+formattedDate);
          return formattedDate;
  }

  String extractPayments(String singlePdfContent) {
      /////////To w metodę
    List<String> listOfCorrectDoubles = PdfParser().extractPaymentAmounts(singlePdfContent);
    //print(listOfCorrectDoubles);
    print("Twoja kwota do zapłaty to: "+listOfCorrectDoubles.last);
    return listOfCorrectDoubles.last;
    ////////
  }



  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    PageController pageController = PageController(initialPage: 0);

    return Scaffold(
      body: CalendarWidget(),
//      backgroundColor: Colors.blue,
//      body: PageView(
//        controller: pageController,
//        children: [
//          PaymentPage(pageController, urgentInvoicesInfo, Colors.red, "Pilne"),
//          PaymentPage(pageController, mediumUrgentInvoicesInfo, Colors.amber, "Średnio pilne"),
//          PaymentPage(pageController, notUrgentInvoicesInfo, Colors.green, "Mało pilne"),
//          PaymentPage(pageController, undefinedInvoicesInfo, Colors.black26, "Niezdefiniowane"),
//        ],
//      ),
      drawer: Drawer(
        // Add a ListView to the drawer. This ensures the user can scroll
        // through the options in the drawer if there isn't enough vertical
        // space to fit everything.
        child: ListView(
          // Important: Remove any padding from the ListView.
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              child: Text('Username'),
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
            ),
            ListTile(
              title: Text('Zarządzaj adresami e-mail'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => EmailBoxesPanel()),
                );
              },
            ),
            ListTile(
              title: Text('Edytuj zaufaną listę nadawców faktur'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => TrustedListPanel()),
                );
              },
            ),
            ListTile(
              title: Text('Ustawienia'),
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => TimeInterval()));
              },
            ),
            ListTile(
              title: Text('O aplikacji'),
              onTap: () {
                // Update the state of the app
                // ...
                // Then close the drawer
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      appBar: AppBar(
          // leading: IconButton(icon: Icon(Icons.menu), onPressed: (){
          //
          // }),
          title: Text("PayIT"),
          actions: <Widget>[
            IconButton(
                icon: Icon(Icons.people),
                onPressed: () {
                  Scaffold.of(context).showSnackBar(
                      new SnackBar(content: Text('Yay! A SnackBar!')));
                })
          ]),
    );
  }

  downloadAttachmentForAllMailboxes(String username, List<List<String>> trustedEmails) async {
    List<List<String>> emailSettings =
        await UserOperationsOnEmails().getEmailSettings(username);

    for (var singleEmailSettings in emailSettings) {
      await downloadAttachment(singleEmailSettings, getMailSenderAddresses(trustedEmails), path);
    }
  }

//  List <String> getAttachmentsName(){
//    List <String> attachments = new List();
//    for
//
//
//  }

  Future<void> downloadAttachment(List<String> emailSettings,
      List<String> trustedEmails, String path) async {
    await platform.invokeMethod("downloadAttachment", {
      "username": emailSettings[0],
      "password": emailSettings[1],
      "host": emailSettings[2],
      "port": emailSettings[3],
      "protocol": emailSettings[4],
      "trustedEmails": trustedEmails,
      "path": path
    });
  }

  List<String> getMailSenderAddresses(List<List<String>> trustedEmails) {

    List<String> senderAddresses = new List();
    for(List<String> record in trustedEmails){
      senderAddresses.add(record[0]);
    }
    return senderAddresses;
  }

  List<String> attachInvoiceCustomNamesToFiles(List<List<String>> trustedEmails, List<FileSystemEntity> files) {

    List<String> namesWithFiles = new List();
    for(List<String> record in trustedEmails){
      for (FileSystemEntity file in files) {
        if(file.path.contains(record[0])){
          namesWithFiles.add(record[1]);
        }
      }
    }
    return namesWithFiles;
  }
}
