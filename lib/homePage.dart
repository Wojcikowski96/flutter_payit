import 'dart:async';
import 'dart:core';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_payit/timeInterval.dart';
import 'package:flutter_payit/trustedList.dart';
import 'package:flutter_payit/PaymentPage.dart';
import 'package:flutter_payit/uiElements.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/services.dart';
import 'package:path_provider_ex/path_provider_ex.dart';
import 'calendarWidget.dart';
import 'databaseOperations.dart';
import 'emailBoxesPanel.dart';
import 'invoice.dart';
import 'userOperationsOnEmails.dart';
import 'pdfParser.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:watcher/watcher.dart';

Timer oldTimer;

class homePage extends StatefulWidget {
  DateTime selectedDate;
  @override
  _homePageState createState() => _homePageState();
  homePage(this.selectedDate);

}

class _homePageState extends State<homePage> {
  var storage = FlutterSecureStorage();
  String path;
  String paymentDate;
  double paymentAmount;
  String categoryName;

  List<int> preferences;
  List<Invoice> definedInvoicesInfo = new List();
  List<Invoice> undefinedInvoicesInfo = new List();
  List<String> matchedCustomNames = new List();

  static const platform = const MethodChannel("name");

  int definedFlex = 4;
  int undefinedFlex = 1;
  int undefinedTextRotated = 1;
  int definedTextRotated = 0;

  Map<DateTime, List> paymentEvents = new Map();

  bool isCalendarVisible = true;

  bool isUndefinedVisible = false;

  bool isDefinedVisible = true;

  bool isPlaceholderTextVisible = true;

  bool isProgressBarVisible = false;

  Color definedColor = Colors.blue;

  static String username = "<Username>";

  List<String> userEmailsNames = new List();

  List<Invoice> invoicesInfo = new List();

  String selectedEmailAddress;

  Timer timer;

  List<List<dynamic>> emailSettings = new List();

  final SnackBar snackBarProgressIndicator =
      UiElements().myShowSnackBar("Synchronizuję ...");
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    userEmailsNames.add("Wszystkie adresy");
    Future.delayed(Duration.zero, () async {
      username = (await storage.read(key: "username")).toString();

      path = (await PathProviderEx.getStorageInfo())[0].appFilesDir +
          '/' +
          username +
          '/invoicesPDF';
      preferences = await DatabaseOperations().getUserPrefsFromDB(username);
      print("Urgency prefs z bazy :");
      print(preferences);
      Directory invoicesDir = new Directory(path);
      invoicesDir.create(recursive: true);

      emailSettings = await UserOperationsOnEmails().getEmailSettings(username);

      List<List<String>> trustedEmails =
          await UserOperationsOnEmails().getInvoiceSenders(username);

      if (emailSettings.isNotEmpty) {
        setState(() {
          isProgressBarVisible = true;
        });

        downloadAttachmentForAllMailboxes(emailSettings, trustedEmails, 0)
            .then((value) => {
                  setState(() {
                    isProgressBarVisible = false;
                  }),
                  print('Czy progress widoczny'),
                  print(isProgressBarVisible),
                  startCheckingLatest(emailSettings, trustedEmails)
                });

        await watchForNewFiles(trustedEmails);
      }

      List<FileSystemEntity> invoiceFileList =
          await PdfParser().dirContents(path);

      for (FileSystemEntity file in invoiceFileList)
        await setFileForDrawing(trustedEmails, file.path);

      await setModifiedInvoicesForDrawing();

    });
  }

  Future setModifiedInvoicesForDrawing() async {

    List<Invoice> modifiedInvoices = await DatabaseOperations().getModifiedInvoices(username);

    for (Invoice invoice in modifiedInvoices)
      invoicesInfo.add(invoice);

    setState(() {
      paymentEvents = generatePaymentEvents(invoicesInfo);
      undefinedInvoicesInfo = generateUndefinedInvoicesList(invoicesInfo);
    });
  }

  Future watchForNewFiles(List<List<String>> trustedEmails) async {
    var watcher = DirectoryWatcher(path);
    watcher.events.listen((event) async {
      String eventString = event.toString().split(" ")[0];
      String eventPath = event.path;

      if (eventString == "add") {
        print("Robię add");
        await setFileForDrawing(trustedEmails, eventPath);
      }
    });
  }

  startCheckingLatest(
      List<List> emailSettings, List<List<String>> trustedEmails) {
    int counter = 0;
    oldTimer?.cancel();
    timer = Timer.periodic(
        Duration(seconds: preferences[2]),
        (Timer t) async => {
              print("Timer " + timer.hashCode.toString()),
              counter = counter + 1,
              emailSettings =
                  await UserOperationsOnEmails().getEmailSettings(username),
              await downloadAttachmentForAllMailboxes(
                  emailSettings, trustedEmails, counter)
            });
    oldTimer = timer;
  }

  Future setFileForDrawing(
      List<List<String>> trustedEmails, String path) async {
    String singlePdfContent = await compute(pdfToString, path);

    if(!path.endsWith("M")) {
      print("Single pdfContent w if M");
      print(singlePdfContent);

      paymentAmount = extractPayments(singlePdfContent);
      paymentDate = extractDateForParser(singlePdfContent);
      categoryName = getInvoiceSenderName(trustedEmails, path);
      String userMailName = basename(path).split(";")[0];
      String senderMailName = basename(path).split(";")[1];
      int account = extractAccount(singlePdfContent);

      //DatabaseOperations().addInvoiceToDatabase(paymentDate, paymentAmount.toString(), categoryName, userMailName, senderMailName, account.toString(), username, path);

      Invoice invoice = new Invoice(categoryName, userMailName, senderMailName,
          paymentAmount, paymentDate, account, true, path, Colors.blue);

      invoicesInfo.add(invoice);

      setState(() {
        paymentEvents = generatePaymentEvents(invoicesInfo);
      });

      setState(() {
        undefinedInvoicesInfo = generateUndefinedInvoicesList(invoicesInfo);
      });
    }
  }

  Color setUrgencyColor(List<Invoice> tempInvoicesInfo) {
    Color color = Colors.blue;
    for (Invoice singleInvoice in tempInvoicesInfo) {
      if ((DateTime.parse(singleInvoice.paymentDate)
          .difference(DateTime.now())
          .inDays).abs() <=
          preferences[0]) {
        color = Colors.red;
      } else if ((DateTime.parse(singleInvoice.paymentDate)
          .difference(DateTime.now())
          .inDays).abs() >
              preferences[0] &&
          (DateTime.parse(singleInvoice.paymentDate)
              .difference(DateTime.now())
              .inDays).abs() <=
              preferences[1]) {
        color = Colors.amber;
      } else if ((DateTime.parse(singleInvoice.paymentDate)
          .difference(DateTime.now())
          .inDays).abs() >
              preferences[1] &&
          (DateTime.parse(singleInvoice.paymentDate)
              .difference(DateTime.now())
              .inDays).abs() <=
              44000) {
        color = Colors.green;
      }
      return color;
    }
  }

  String extractDateForParser(String singlePdfContent) {
    final dateRegex = RegExp(
        r'(\d{4}(\/|-|\.)\d{1,2}(\/|-|\.)(0[1-9]|1[0-9]|2[0-9]|3[0-1]))|((0[1-9]|1[0-9]|2[0-9]|3[0-1])(\/|-|\.)\d{1,2}(\/|-|\.)\d{4})',
        multiLine: true);
    List<String> listOfDates =
        dateRegex.allMatches(singlePdfContent).map((m) => m.group(0)).toList();

    List<DateTime> listOfCorrectDates = new List<DateTime>();

    for (String date in listOfDates) {
      if (RegExp(r'(\/|-|\.)\d{4}').hasMatch(date)) {
        String dateWithDashes = date.replaceAll(new RegExp(r'\W+'), "-");
        String dateStandard =
            PdfParser().addedZero(dateWithDashes.split("-")).reversed.join("-");
        if (DateTime.parse(dateStandard).difference(DateTime.now()).inDays <=
            365) {
          listOfCorrectDates.add(DateTime.parse(dateStandard));
        }
      } else if ((RegExp(r'\d{4}(\/|-|\.)').hasMatch(date))) {
        String dateStandard = PdfParser()
            .addedZero(date.replaceAll(new RegExp(r'\W+'), '-').split("-"))
            .join("-");
        if (DateTime.parse(dateStandard).difference(DateTime.now()).inDays <=
            365) {
          listOfCorrectDates.add(DateTime.parse(dateStandard));
        }
      }
    }
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    final String formattedDate = formatter.format(DateTime.parse(
        (PdfParser().findLatestDate(listOfCorrectDates)).toString()));

    print("Data zapłaty faktury to " + formattedDate);
    return formattedDate;
  }

  double extractPayments(String singlePdfContent) {
    List<String> listOfCorrectDoubles =
        PdfParser().extractAllDoublesFromPdf(singlePdfContent);

    if (listOfCorrectDoubles.length == 0) {
      print("Twoja kwota do zapłaty to: 0");
      return 0;
    } else {
      print("Twoja kwota do zapłaty to: " + listOfCorrectDoubles.last);
      return double.parse(listOfCorrectDoubles.last.replaceAll(",", "."));
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
    print("robie Dispose");
  }

  @override
  Widget build(BuildContext context) {
    PageController pageController = PageController(initialPage: 0);
    if (emailSettings.isEmpty) {
      return Scaffold(
          body: Container(
              child: Column(
        children: [
          SizedBox(
            height: 50,
          ),
          SizedBox(height: 150, child: Image.asset("warning.PNG")),
          SizedBox(
            height: 25,
          ),
          Center(
              child: Text(
            "Nie masz zdefiniowanych żadnych własnych skrzynek e-mail!",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 45, color: Colors.blue),
          )),
          SizedBox(
            height: 25,
          ),
          UiElements().drawButton(200, 80, "Przejdź do ustawień", Colors.white, Colors.blue, Colors.blue, context,
              EmailBoxesPanel(), null, null),
          SizedBox(
            height: 10,
          ),
        ],
      )));
    } else {
      return Scaffold(
          key: scaffoldKey,
          body: Column(children: [
            CalendarWidget(
              selectedDay: widget.selectedDate,
              events: paymentEvents,
              notifyParent: generateDefinedPaymentInput,
            ),
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
                            definedInvoicesInfo.length == 0
                                ? isDefinedVisible = false
                                : isDefinedVisible = true;
                            definedInvoicesInfo.length == 0
                                ? isPlaceholderTextVisible = true
                                : isPlaceholderTextVisible = false;
                          }),
                          child: Container(
                              color: definedColor,
                              child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    RotatedBox(
                                        quarterTurns: definedTextRotated,
                                        child: RichText(
                                          text: TextSpan(
                                            text: 'Zdefiniowane ',
                                            style: TextStyle(fontSize: 16),
                                            children: <TextSpan>[
                                              TextSpan(
                                                  text: (definedInvoicesInfo
                                                          .length)
                                                      .toString(),
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: definedColor,
                                                      backgroundColor:
                                                          Colors.white,
                                                      fontSize: 20)),
                                            ],
                                          ),
                                        )),
                                    Visibility(
                                        visible: isDefinedVisible,
                                        child: Expanded(
                                          child: PaymentPage(
                                              pageController,
                                              definedInvoicesInfo,
                                              definedColor,
                                              "Pilne"),
                                        )),
                                    Visibility(
                                        visible: isPlaceholderTextVisible,
                                        child: Expanded(
                                          child: Center(
                                            child: Text(
                                              "< Nic do pokazania >",
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ),
                                        )),
                                  ])),
                        )),
                    Expanded(
                        flex: undefinedFlex,
                        child: GestureDetector(
                          onTap: () => setState(() {
                            definedFlex = 1;
                            undefinedFlex = 4;
                            undefinedTextRotated = 0;
                            definedTextRotated = 1;
                            isUndefinedVisible = true;
                            isDefinedVisible = false;
                            isPlaceholderTextVisible = false;
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
                                          child: RichText(
                                            text: TextSpan(
                                              text: 'Niezdefiniowane ',
                                              style: TextStyle(fontSize: 16),
                                              children: <TextSpan>[
                                                TextSpan(
                                                    text: (undefinedInvoicesInfo
                                                            .length)
                                                        .toString(),
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.white,
                                                        backgroundColor:
                                                            Colors.red,
                                                        fontSize: 20)),
                                              ],
                                            ),
                                          ))),
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
            ),
            Visibility(
              visible: isProgressBarVisible,
              child: Row(
                children: [
                  Text("Synchronizuję ..."),
                  CircularProgressIndicator(),
                ],
              ),
            )
          ]),
          appBar: AppBar(
            // leading: IconButton(icon: Icon(Icons.menu), onPressed: (){
            //
            // })
            title: Text(
              "PayIT",
              style: TextStyle(fontSize: 25, color: Colors.white),
            ),

            iconTheme: IconThemeData(color: Colors.white), //add this line here
          ),
          drawer: Drawer(
            // Add a ListView to the drawer. This ensures the user can scroll
            // through the options in the drawer if there isn't enough vertical
            // space to fit everything.
            child: ListView(
              // Important: Remove any padding from the ListView.
              padding: EdgeInsets.zero,
              children: <Widget>[
                DrawerHeader(
                  child: Column(
                    children: [
                      Text(
                        username,
                        style: TextStyle(fontSize: 50, color: Colors.white),
                      ),
                      Container(child: buildDropdownButton(), width: 300)
                    ],
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                  ),
                ),
                ListTile(
                  title: Text('Zarządzaj adresami e-mail'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => EmailBoxesPanel()),
                    );
                  },
                ),
                ListTile(
                  title: Text('Edytuj zaufaną listę nadawców faktur'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => TrustedListPanel()),
                    );
                  },
                ),
                ListTile(
                  title: Text('Ustawienia'),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => TimeInterval()));
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
  }

  DropdownButton<String> buildDropdownButton() {
    return new DropdownButton<String>(
      isExpanded: true,
      value: selectedEmailAddress,
      items: userEmailsNames.map((String value) {
        return new DropdownMenuItem<String>(
          value: value,
          child: Container(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: new Text(
                value,
                maxLines: 1,
              ),
            ),
          ),
        );
      }).toList(),
      onChanged: (String val) {
        setState(() {
          selectedEmailAddress = val;
          filterByUserMailbox(selectedEmailAddress);
        });
      },
    );
  }

  Future<void> downloadAttachmentForAllMailboxes(
      List<List<dynamic>> emailSettings,
      List<List<String>> trustedEmails,
      int counter) async {
    print("Zaciągam maile");

    List<String> tempUserEmailsNames = new List();

    for (var singleEmailSettings in emailSettings) {
      tempUserEmailsNames.add(singleEmailSettings[0].toString());
      List<dynamic> downloadAttachmentArgs = [
        singleEmailSettings,
        getMailSenderAddresses(trustedEmails),
        path,
        platform,
        username,
        counter
      ];
      await downloadAttachment(downloadAttachmentArgs);
    }
    tempUserEmailsNames.add("Wszystkie adresy");
    setState(() {
      userEmailsNames = tempUserEmailsNames;
      selectedEmailAddress = userEmailsNames.last;
    });
  }

  List<String> getMailSenderAddresses(List<List<String>> trustedEmails) {
    List<String> senderAddresses = new List();
    for (List<String> record in trustedEmails) {
      senderAddresses.add(record[0]);
    }
    return senderAddresses;
  }

  Map<DateTime, List> generatePaymentEvents(List<Invoice> invoicesInfo) {
    Map<DateTime, List> paymentEvents = new Map();

    for (Invoice singleInvoiceInfo in invoicesInfo) {

      print(singleInvoiceInfo.toString());
      DateTime date = DateTime.parse(singleInvoiceInfo.paymentDate);

      String paymentEventValue = 'Opłata dla|' +
          singleInvoiceInfo.categoryName +
          "|" +
          singleInvoiceInfo.paymentAmount.toString() +
          "|" +
          singleInvoiceInfo.downloadPath.toString() +
          "|" +
          setUrgencyColorBasedOnDate(date).toString() +
          "|" +
          singleInvoiceInfo.accountForTransfer.toString() +
          "|" +
          singleInvoiceInfo.userMail +
          "|" +
          singleInvoiceInfo.senderMail;

      if (paymentEvents.containsKey(date)) {
        paymentEvents[date].add(paymentEventValue);
      } else {
        paymentEvents[date] = [paymentEventValue];
      }
    }

    print("Mapa " + paymentEvents.toString());
    return paymentEvents;
  }

  void generateDefinedPaymentInput(DateTime date, List events) {
    List<Invoice> tempDefinedInvoicesInfo = new List();

    for (String singleEventInfo in events) {
      String categoryName = singleEventInfo.split("|")[1];
      String paymentAmount = singleEventInfo.split("|")[2];
      String path = singleEventInfo.split("|")[3];
      String paymentDate = DateFormat('yyyy-MM-dd').format(date).toString();
      String color = singleEventInfo.split("|")[4];
      String accountForTransfer = singleEventInfo.split("|")[5];
      String userMail = singleEventInfo.split("|")[6];
      String senderMail = singleEventInfo.split("|")[7];

      Invoice singleInvoiceInfoFromCalendar = new Invoice(
          categoryName,
          userMail,
          senderMail,
          double.parse(paymentAmount),
          paymentDate,
          int.parse(accountForTransfer),
          true,
          path,
          colorFromName(color));

      tempDefinedInvoicesInfo.add(singleInvoiceInfoFromCalendar);
    }
    if (events.isEmpty) {
      setState(() {
        definedInvoicesInfo = [];
        isPlaceholderTextVisible = true;
        isDefinedVisible = false;
        definedColor = Colors.blue;
      });
    } else {
      setState(() {
        definedInvoicesInfo = tempDefinedInvoicesInfo;
        definedColor = setUrgencyColor(definedInvoicesInfo);
        isPlaceholderTextVisible = false;
        isDefinedVisible = true;
      });
    }
  }

  Color setUrgencyColorBasedOnDate(DateTime date) {
    Color color = Colors.blue;
    if ((date.difference(DateTime.now()).inDays).abs() <= preferences[0]) {
      color = Colors.red;
    } else if ((date.difference(DateTime.now()).inDays).abs() > preferences[0] &&
        (date.difference(DateTime.now()).inDays).abs() <= preferences[1]) {
      color = Colors.amber;
    } else if ((date.difference(DateTime.now()).inDays).abs() > preferences[1] &&
        (date.difference(DateTime.now()).inDays).abs() <= 44000) {
      color = Colors.green;
    }
    return color;
  }

  List<Invoice> generateUndefinedInvoicesList(List<Invoice> tempInvoicesInfo) {
    List<Invoice> undefinedInvoices = new List();
    for (Invoice singleInvoice in tempInvoicesInfo) {
      if (-DateTime.parse(singleInvoice.paymentDate)
                  .difference(DateTime.now())
                  .inDays >
              44000 ||
          singleInvoice.paymentAmount == 0) {
        undefinedInvoices.add(singleInvoice);
      }
    }
    return undefinedInvoices;
  }

  void filterByUserMailbox(String selectedEmailAddress) {
    List<Invoice> tempInvoicesInfo = new List();

    tempInvoicesInfo.addAll(invoicesInfo);

    List<int> doUsuniecia = new List();

    for (int i = 0; i < tempInvoicesInfo.length; i++) {
      if (tempInvoicesInfo[i].userMail != selectedEmailAddress) {
        doUsuniecia.add(i);
      }
    }

    print("Dousuniecia " + doUsuniecia.toString());

    if (selectedEmailAddress != "Wszystkie adresy") {
      int j = 0;
      for (int i in doUsuniecia) {
        tempInvoicesInfo.removeAt(i - j);
        j++;
      }
    } else {
      tempInvoicesInfo = invoicesInfo;
    }

    setState(() {
      paymentEvents = generatePaymentEvents(tempInvoicesInfo);
    });
  }

  String getInvoiceSenderName(List<List<String>> trustedEmails, String path) {
    String nameWithFile;
    for (List<String> trustedEmail in trustedEmails) {
      if (path.contains(trustedEmail[0])) {
        nameWithFile = trustedEmail[1];
      }
    }
    return nameWithFile;
  }

  int extractAccount(String singlePdfContent) {
    return 0;
  }

  Color colorFromName(String name) {
    if (name == "MaterialColor(primary value: Color(0xfff44336))") {
      return Colors.red;
    } else if (name == "MaterialColor(primary value: Color(0xffffc107))") {
      return Colors.amber;
    } else {
      return Colors.green;
    }
  }
}

Future<void> downloadAttachment(List<dynamic> args) async {
  //WidgetsFlutterBinding.ensureInitialized();
  await args[3].invokeMethod("downloadAttachment", {
    "emailAddress": args[0][0],
    "password": args[0][1],
    "host": args[0][2],
    "port": args[0][3],
    "protocol": args[0][4],
    "newUID": args[0][5],
    "trustedEmails": args[1],
    "path": args[2],
    "username": args[4],
    "counter": args[5]
  });
}
