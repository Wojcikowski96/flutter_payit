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

  List<int> urgencyPrefs = [300, 3000];
  List<List<String>> definedInvoicesInfo = new List();
  List<List<String>> undefinedInvoicesInfo = new List();

  static const platform = const MethodChannel("name");
  Timer timer;
  int definedFlex = 4;
  int undefinedFlex = 1;
  int undefinedTextRotated = 1;
  int definedTextRotated = 0;

  Map<DateTime, List> paymentEvents = new Map();

  bool isCalendarVisible = true;

  bool isUndefinedVisible = false;

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

      await downloadAttachmentForAllMailboxes(username, trustedEmails);
      //timer = Timer.periodic(Duration(seconds: 360), (Timer t) => refreshEmails(username));
      //await PdfParser().pdfToString("asd");

      List<FileSystemEntity> invoiceFileList =
          await PdfParser().dirContents(path);

      List<String> matchedCustomNames =
          attachInvoiceCustomNamesToFiles(trustedEmails, invoiceFileList);

      List<String> pdfContentsList =
          await PdfParser().allPdfToString(invoiceFileList);

      List<List<String>> tempInvoicesInfo = new List();

      int i = 0;
      for (String singlePdfContent in pdfContentsList) {
        print(singlePdfContent);
        List<String> singleDetails = new List();
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

      setState(() {
        paymentEvents = generatePaymentEvents(tempInvoicesInfo);
      });

      setState(() {
        undefinedInvoicesInfo = generateUndefinedInvoicesList(tempInvoicesInfo);
      });
    });
  }

  Color setUrgencyColor(List<List<String>> tempInvoicesInfo) {
    Color color = Colors.blue;
    for (List<String> singleInvoice in tempInvoicesInfo) {
      if (-DateTime.parse(singleInvoice[2]).difference(DateTime.now()).inDays <=
          urgencyPrefs[0]) {
        color= Colors.red;
      } else if (-DateTime.parse(singleInvoice[2])
                  .difference(DateTime.now())
                  .inDays >
              urgencyPrefs[0] &&
          -DateTime.parse(singleInvoice[2]).difference(DateTime.now()).inDays <=
              urgencyPrefs[1]) {
        color=  Colors.amber;
      } else if (-DateTime.parse(singleInvoice[2])
                  .difference(DateTime.now())
                  .inDays >
              urgencyPrefs[1] &&
          -DateTime.parse(singleInvoice[2]).difference(DateTime.now()).inDays <=
              44000) {
        color= Colors.green;
      }
      return color;
    }
  }

  String extractDateForParser(String singlePdfContent) {
    final dateRegex = RegExp(
        r'(\d{4}(\/|-|\.)\d{1,2}(\/|-|\.)\d{1,2})|(\d{1,2}(\/|-|\.)\d{1,2}(\/|-|\.)\d{4})',
        multiLine: true);
    List<String> ListOfDates =
        dateRegex.allMatches(singlePdfContent).map((m) => m.group(0)).toList();

    List<DateTime> ListOfCorrectDates = new List<DateTime>();

    for (String date in ListOfDates) {
      if (RegExp(r'(\/|-|\.)\d{4}').hasMatch(date)) {
        String dateWithDashes = date.replaceAll(new RegExp(r'\W+'), "-");
        String dateStandard =
            PdfParser().addedZero(dateWithDashes.split("-")).reversed.join("-");
        ListOfCorrectDates.add(DateTime.parse(dateStandard));
      } else if ((RegExp(r'\d{4}(\/|-|\.)').hasMatch(date))) {
        String dateStandard = date.replaceAll(new RegExp(r'\W+'), '-');
        ListOfCorrectDates.add(DateTime.parse(dateStandard));
      }
    }
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    final String formattedDate = formatter.format(DateTime.parse(
        (PdfParser().findLatestDate(ListOfCorrectDates)).toString()));

    print("Data zapłaty faktury to " + formattedDate);
    return formattedDate;
  }

  String extractPayments(String singlePdfContent) {
    /////////To w metodę
    List<String> listOfCorrectDoubles =
        PdfParser().extractPaymentAmounts(singlePdfContent);
    //print(listOfCorrectDoubles);
    print("Twoja kwota do zapłaty to: " + listOfCorrectDoubles.last);
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
        //body: CalendarWidget(),
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
        body: Column(children: [
          Visibility(
              visible: isCalendarVisible,
              child: CalendarWidget(
                events: paymentEvents,
                notifyParent: generateDefinedPaymentInput,
              )),
          Expanded(
            child: GestureDetector(
              onPanUpdate: (details) {
                setState(() {
                  if (details.delta.dy > 0) {
                    isCalendarVisible = true;
                  } else if (details.delta.dy < 0) {
                    isCalendarVisible = false;
                  }
                });
              },
              child: Row(
                children: [
                  Expanded(
                      flex: definedFlex,
                      child: GestureDetector(
                        onTap: () => setState(() {
                          definedFlex = 4;
                          undefinedFlex = 1;
                          undefinedTextRotated = 1;
                          definedTextRotated = 0;
                          isUndefinedVisible = false;
                        }),
                        child: Container(
                            color: setUrgencyColor(definedInvoicesInfo),
                            child: Column(children: [
                              Center(
                                  child: RotatedBox(
                                      quarterTurns: definedTextRotated,
                                      child: Text(
                                        "Zdefiniowane",
                                        style: TextStyle(
                                            fontSize: 22,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white),
                                      ))),
                              Visibility(
                                  visible: !isUndefinedVisible,
                                  child: Expanded(
                                      child: PaymentPage(
                                          pageController,
                                          definedInvoicesInfo,
                                          setUrgencyColor(definedInvoicesInfo),
                                          "Pilne"))),
                            ])),
                      )),
                  Expanded(
                      flex: undefinedFlex,
                      child: GestureDetector(
                        onTap: () => setState(() {
                          print("Wciskam guzik czerwony");
                          definedFlex = 1;
                          undefinedFlex = 4;
                          undefinedTextRotated = 0;
                          definedTextRotated = 1;
                          isUndefinedVisible = true;
                        }),
                        child: Container(
                            color: Colors.black26,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Center(
                                    child: RotatedBox(
                                        quarterTurns: undefinedTextRotated,
                                        child: Text(
                                          "Niezdefiniowane",
                                          style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white),
                                        ))),
                                Visibility(
                                  visible: !isUndefinedVisible,
                                  child: Container(
                                    width: 30,
                                    height: 30,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.red,
                                    ),
                                    child: Center(
                                      child: Text(
                                        (undefinedInvoicesInfo.length)
                                            .toString(),
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ),
                                Visibility(
                                    visible: isUndefinedVisible,
                                    child: Expanded(
                                        child: PaymentPage(
                                            pageController,
                                            undefinedInvoicesInfo,
                                            Colors.black26,
                                            "Pilne"))),
                              ],
                            )),
                      ))
                ],
              ),
            ),
          )
        ]),
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
        ));
  }

  downloadAttachmentForAllMailboxes(
      String username, List<List<String>> trustedEmails) async {
    List<List<String>> emailSettings =
        await UserOperationsOnEmails().getEmailSettings(username);

    for (var singleEmailSettings in emailSettings) {
      await downloadAttachment(
          singleEmailSettings, getMailSenderAddresses(trustedEmails), path);
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
    for (List<String> record in trustedEmails) {
      senderAddresses.add(record[0]);
    }
    return senderAddresses;
  }

  List<String> attachInvoiceCustomNamesToFiles(
      List<List<String>> trustedEmails, List<FileSystemEntity> files) {
    List<String> namesWithFiles = new List();
    for (List<String> record in trustedEmails) {
      for (FileSystemEntity file in files) {
        if (file.path.contains(record[0])) {
          namesWithFiles.add(record[1]);
        }
      }
    }
    return namesWithFiles;
  }

  Map<DateTime, List> generatePaymentEvents(List<List<String>> invoicesInfo) {
    Map<DateTime, List> paymentEvents = new Map();
    for (List<String> singleInvoiceInfo in invoicesInfo) {
      paymentEvents[DateTime.parse(singleInvoiceInfo[2])] = [
        'Opłata dla|' +
            singleInvoiceInfo[0] +
            "|" +
            singleInvoiceInfo[1] +
            "|" +
            singleInvoiceInfo[3] +
            "|" +
            setUrgencyColorBasedOnDate(DateTime.parse(singleInvoiceInfo[2]))
                .toString()
      ];
    }
    print("Mapa " + paymentEvents.toString());
    return paymentEvents;
  }

  void generateDefinedPaymentInput(DateTime date, String event) {
    List<List<String>> tempDefinedInvoicesInfo = new List();
    List<String> singleInvoiceInfo = new List();

    singleInvoiceInfo.add(event.split("|")[1]);
    singleInvoiceInfo.add(event.split("|")[2]);
    singleInvoiceInfo.add(DateFormat('yyyy-MM-dd').format(date).toString());
    singleInvoiceInfo.add(event.split("|")[3]);
    tempDefinedInvoicesInfo.add(singleInvoiceInfo);

    setState(() {
      definedInvoicesInfo = tempDefinedInvoicesInfo;
    });
  }

  Color setUrgencyColorBasedOnDate(DateTime date) {
    Color color = Colors.blue;
    if (-date.difference(DateTime.now()).inDays <= urgencyPrefs[0]) {
      color= Colors.red;
    } else if (-date.difference(DateTime.now()).inDays > urgencyPrefs[0] &&
        -date.difference(DateTime.now()).inDays <= urgencyPrefs[1]) {
      color= Colors.amber;
    } else if (-date.difference(DateTime.now()).inDays > urgencyPrefs[1] &&
        -date.difference(DateTime.now()).inDays <= 44000) {
      color= Colors.green;
    }
    return color;
  }

  List<List<String>> generateUndefinedInvoicesList(List<List<String>> tempInvoicesInfo) {
    List<List<String>> undefinedInvoices = new List();
    for (List<String> singleInvoice in tempInvoicesInfo) {
       if (-DateTime.parse(singleInvoice[2])
          .difference(DateTime.now())
          .inDays > 44000) {
         undefinedInvoices.add(singleInvoice);
      }
    }
    return undefinedInvoices;
  }
}
