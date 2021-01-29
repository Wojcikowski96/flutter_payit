import 'dart:async';
import 'dart:core';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_payit/timeInterval.dart';
import 'package:flutter_payit/trustedList.dart';
import 'package:flutter_payit/PaymentPage.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/services.dart';
import 'package:path_provider_ex/path_provider_ex.dart';
import 'calendarWidget.dart';
import 'databaseOperations.dart';
import 'emailBoxesPanel.dart';
import 'userOperationsOnEmails.dart';
import 'pdfParser.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:watcher/watcher.dart';

Timer oldTimer;

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

  List<int> preferences;
  List<List<String>> definedInvoicesInfo = new List();
  List<List<String>> undefinedInvoicesInfo = new List();
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

  Color definedColor = Colors.blue;

  static String username = "<Username>";

  List<String> userEmailsNames = new List();

  List<List<String>> invoicesInfo = new List();

  String selectedEmailAddress;

  Timer timer;

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

      List<List<String>> trustedEmails =
          await UserOperationsOnEmails().getInvoiceSenders(username);

      List<List<dynamic>> emailSettings =
          await UserOperationsOnEmails().getEmailSettings(username);

      downloadAttachmentForAllMailboxes(emailSettings, trustedEmails, 0)
          .then((value) => {startCheckingLatest(emailSettings, trustedEmails)});

      List<FileSystemEntity> invoiceFileList =
          await PdfParser().dirContents(path);

      for (FileSystemEntity file in invoiceFileList)
        await setFileForDrawing(trustedEmails, file.path);

      var watcher = DirectoryWatcher(path);
      watcher.events.listen((event) async {
        String eventString = event.toString().split(" ")[0];
        String eventPath = event.path;

        if (eventString == "add") {
          await setFileForDrawing(trustedEmails, eventPath);
        }
      });
    });
  }

  startCheckingLatest(
      List<List> emailSettings, List<List<String>> trustedEmails) {
    int counter=0;
    oldTimer?.cancel();
    timer = Timer.periodic(
        Duration(seconds: preferences[2]),
        (Timer t) async => {
              print("Timer " + timer.hashCode.toString()),
              counter=counter+1,
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

    print(singlePdfContent);
    List<String> singleDetails = new List();
    paymentAmount = extractPayments(singlePdfContent);
    paymentDate = extractDateForParser(singlePdfContent);
    invoiceSender = getInvoiceSenderName(trustedEmails, path);
    singleDetails.add(invoiceSender);
    singleDetails.add(paymentAmount);
    singleDetails.add(paymentDate);
    singleDetails.add(path);
    singleDetails.add(basename(path).split(";")[0]);
    invoicesInfo.add(singleDetails);

    setState(() {
      paymentEvents = generatePaymentEvents(invoicesInfo);
    });

    setState(() {
      undefinedInvoicesInfo = generateUndefinedInvoicesList(invoicesInfo);
    });
  }

  Color setUrgencyColor(List<List<String>> tempInvoicesInfo) {
    Color color = Colors.blue;
    for (List<String> singleInvoice in tempInvoicesInfo) {
      if (-DateTime.parse(singleInvoice[2]).difference(DateTime.now()).inDays <=
          preferences[0]) {
        color = Colors.red;
      } else if (-DateTime.parse(singleInvoice[2])
                  .difference(DateTime.now())
                  .inDays >
              preferences[0] &&
          -DateTime.parse(singleInvoice[2]).difference(DateTime.now()).inDays <=
              preferences[1]) {
        color = Colors.amber;
      } else if (-DateTime.parse(singleInvoice[2])
                  .difference(DateTime.now())
                  .inDays >
              preferences[1] &&
          -DateTime.parse(singleInvoice[2]).difference(DateTime.now()).inDays <=
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
    List<String> ListOfDates =
        dateRegex.allMatches(singlePdfContent).map((m) => m.group(0)).toList();

    List<DateTime> ListOfCorrectDates = new List<DateTime>();

    for (String date in ListOfDates) {
      if (RegExp(r'(\/|-|\.)\d{4}').hasMatch(date)) {
        String dateWithDashes = date.replaceAll(new RegExp(r'\W+'), "-");
        String dateStandard =
            PdfParser().addedZero(dateWithDashes.split("-")).reversed.join("-");
        if (DateTime.parse(dateStandard).difference(DateTime.now()).inDays <=
            365) {
          ListOfCorrectDates.add(DateTime.parse(dateStandard));
        }
      } else if ((RegExp(r'\d{4}(\/|-|\.)').hasMatch(date))) {
        String dateStandard = PdfParser()
            .addedZero(date.replaceAll(new RegExp(r'\W+'), '-').split("-"))
            .join("-");
        if (DateTime.parse(dateStandard).difference(DateTime.now()).inDays <=
            365) {
          ListOfCorrectDates.add(DateTime.parse(dateStandard));
        }
      }
    }
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    final String formattedDate = formatter.format(DateTime.parse(
        (PdfParser().findLatestDate(ListOfCorrectDates)).toString()));

    print("Data zapłaty faktury to " + formattedDate);
    return formattedDate;
  }

  String extractPayments(String singlePdfContent) {
    List<String> listOfCorrectDoubles =
        PdfParser().extractPaymentAmounts(singlePdfContent);

    if (listOfCorrectDoubles.length == 0) {
      print("Twoja kwota do zapłaty to: 0");
      return "0";
    } else {
      print("Twoja kwota do zapłaty to: " + listOfCorrectDoubles.last);
      return listOfCorrectDoubles.last;
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

    return Scaffold(
        body: Column(children: [
          CalendarWidget(
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
                                                text:
                                                    (definedInvoicesInfo.length)
                                                        .toString(),
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
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
      List<List<String>> trustedEmails, int counter) async {
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
      downloadAttachment(downloadAttachmentArgs);
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

  Map<DateTime, List> generatePaymentEvents(List<List<String>> invoicesInfo) {
    Map<DateTime, List> paymentEvents = new Map();

    for (List<String> singleInvoiceInfo in invoicesInfo) {
      DateTime date = DateTime.parse(singleInvoiceInfo[2]);

      String paymentEventValue = 'Opłata dla|' +
          singleInvoiceInfo[0] +
          "|" +
          singleInvoiceInfo[1] +
          "|" +
          singleInvoiceInfo[3] +
          "|" +
          setUrgencyColorBasedOnDate(date).toString();

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
    List<List<String>> tempDefinedInvoicesInfo = new List();

    for (String singleEventInfo in events) {
      List<String> singleInvoiceInfo = new List();

      singleInvoiceInfo.add(singleEventInfo.split("|")[1]);
      singleInvoiceInfo.add(singleEventInfo.split("|")[2]);
      singleInvoiceInfo.add(DateFormat('yyyy-MM-dd').format(date).toString());
      singleInvoiceInfo.add(singleEventInfo.split("|")[3]);
      tempDefinedInvoicesInfo.add(singleInvoiceInfo);
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
    if (-date.difference(DateTime.now()).inDays <= preferences[0]) {
      color = Colors.red;
    } else if (-date.difference(DateTime.now()).inDays > preferences[0] &&
        -date.difference(DateTime.now()).inDays <= preferences[1]) {
      color = Colors.amber;
    } else if (-date.difference(DateTime.now()).inDays > preferences[1] &&
        -date.difference(DateTime.now()).inDays <= 44000) {
      color = Colors.green;
    }
    return color;
  }

  List<List<String>> generateUndefinedInvoicesList(
      List<List<String>> tempInvoicesInfo) {
    List<List<String>> undefinedInvoices = new List();
    for (List<String> singleInvoice in tempInvoicesInfo) {
      if (-DateTime.parse(singleInvoice[2]).difference(DateTime.now()).inDays >
              44000 ||
          singleInvoice[1] == "0") {
        undefinedInvoices.add(singleInvoice);
      }
    }
    return undefinedInvoices;
  }

  void filterByUserMailbox(String selectedEmailAddress) {
    List<List<String>> tempInvoicesInfo = new List();

    tempInvoicesInfo.addAll(invoicesInfo);

    print(
        "Długość niezmienionej listy faktur " + invoicesInfo.length.toString());

    List<int> doUsuniecia = new List();

    for (int i = 0; i < tempInvoicesInfo.length; i++) {
      if (tempInvoicesInfo[i][4] != selectedEmailAddress) {
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
}

downloadAttachment(List<dynamic> args) async {
  //WidgetsFlutterBinding.ensureInitialized();
  args[3].invokeMethod("downloadAttachment", {
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
