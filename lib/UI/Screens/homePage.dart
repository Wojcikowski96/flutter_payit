import 'dart:async';
import 'dart:core';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_payit/IsUserLoggedChecker/MySharedPreferences.dart';
import 'package:flutter_payit/JavaDownloaderInvoke/downloader.dart';
import 'package:flutter_payit/LifeCycleHandler/lifeCycle.dart';
import 'package:flutter_payit/Main/main.dart';
import 'package:flutter_payit/Objects/appNotification.dart';
import 'package:flutter_payit/Objects/notificationItem.dart';
import 'package:flutter_payit/UI/HelperClasses/consolidedEventsView.dart';
import 'package:flutter_payit/UI/HelperClasses/mainUI.dart';
import 'package:flutter_payit/UI/HelperClasses/uiElements.dart';
import 'package:flutter_payit/UI/Screens/ConfigScreens/timeInterval.dart';
import 'package:flutter_payit/UI/Screens/ConfigScreens/trustedList.dart';
import 'package:flutter_payit/UI/Screens/paymentDataWidget.dart';
import 'package:flutter_payit/Utils/utils.dart';
import 'PaymentPage.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/services.dart';
import 'package:path_provider_ex/path_provider_ex.dart';
import 'package:flutter_payit/CalendarUtils/calendarUtils.dart';
import 'package:flutter_payit/UI/HelperClasses/calendarWidget.dart';
import 'package:flutter_payit/Database/databaseOperations.dart';
import 'ConfigScreens/emailBoxesPanel.dart';
import 'package:flutter_payit/Objects/invoice.dart';
import 'package:flutter_payit/Utils/userOperationsOnEmails.dart';
import 'package:flutter_payit/PdfParser/pdfParser.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:watcher/watcher.dart';

Timer oldTimer;

class homePage extends StatefulWidget {
  DateTime selectedDate;
  bool isCalendarViewEnabled = true;
  List<Invoice> definedInvoicesInfo;
  @override
  _homePageState createState() => _homePageState();
  homePage(
      this.selectedDate, this.definedInvoicesInfo, this.isCalendarViewEnabled);
}

class _homePageState extends State<homePage> with TickerProviderStateMixin {
  var storage = FlutterSecureStorage();
  String path;
  String paymentDate;
  double paymentAmount;
  String categoryName;

  List<String> urgencyNames = [
    "Pilne",
    "Średnio pilne",
    "Mało pilne",
    "Niezdefiniowane",
    "Twoje skrzynki e-mail"
  ];
  List<Color> colors = [Colors.red, Colors.amber, Colors.green, Colors.grey, Colors.blue];
  List<List<Widget>> invoicesTilesForConsolided = new List();

  String syncedEmailBoxName = "...";

  List<int> preferences;
  //List<Invoice> definedInvoicesInfo = new List();
  List<Invoice> undefinedInvoicesInfo = new List();
  List<String> matchedCustomNames = new List();

  static const methodChannel = const MethodChannel("com.example.flutter_payit");

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

  bool isInvoiceVisible = true;

  bool isListOfEmailsVisible = true;

  bool isTipTextVisible = false;

  double fontSizeOfDefAndUndef = 12;

  static String username = "<Username>";

  List<String> userEmailsNames = new List();

  List<Invoice> invoicesInfo = new List();
  List<Invoice> urgent = new List();
  List<Invoice> medium = new List();
  List<Invoice> noturgent = new List();
  List<Invoice> undefined = new List();

  List<AppNotification> appNotifications = new List();

  String selectedEmailAddress;

  String definedText = "Zdefiniowane";

  String undefinedText = "Niezdefiniowane";

  List<NotificationItem> notificationItems = new List();

  Timer timer;

  List<List<dynamic>> emailSettings = new List();

  List<List<String>> trustedEmails = new List();

  Color definedColor = Colors.blue;

  String endMessage;

  AnimationController _animationControllerForInvoices;
  Animation _animationForInvoices;

  AnimationController _animationControllerForEmails;
  Animation _animationForEmails;

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  final SnackBar snackBarProgressIndicator =
      UiElements().myShowSnackBar("Synchronizuję ...");
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    setAnimationParameters();

    if (widget.definedInvoicesInfo.isNotEmpty) {
      definedColor = widget.definedInvoicesInfo.last.color;
      isPlaceholderTextVisible = false;
    }

    userEmailsNames.add("Wszystkie adresy");
    Future.delayed(Duration.zero, () async {
      username = await getUsernameFromFlutterStorage();
      path = await generatePathForStoringAttachments();
      preferences = await DatabaseOperations().getUserPrefsFromDB(username);
      generateDirectory();
      emailSettings = await UserOperationsOnEmails().getEmailSettings(username);
      notificationItems = populateNotificationItemsList(emailSettings);
      methodChannel.setMethodCallHandler(javaMethod);
      trustedEmails = await UserOperationsOnEmails().getInvoiceSenders(username);

      if (emailSettings.isNotEmpty) {
        trustedEmails.isNotEmpty
            ? downloadAttachmentForAllMailboxes(emailSettings, trustedEmails)
            : print("Nothing to do");

        trustedEmails.isNotEmpty
            ? await watchForNewFiles(trustedEmails)
            : print("Nothing to do");
      }

      List<FileSystemEntity> invoiceFileList =
          await PdfParser().dirContents(path);

      for (FileSystemEntity file in invoiceFileList)
        trustedEmails.isNotEmpty
            ? await setFileForDrawing(trustedEmails, file.path)
            : print("Nothing to do");

      await setModifiedInvoicesForDrawing();
    });
  }

  void generateDirectory() {
    Directory invoicesDir = new Directory(path);
    invoicesDir.create(recursive: true);
  }

  Future<String> getUsernameFromFlutterStorage() async => (await storage.read(key: "username")).toString();

  Future<String> generatePathForStoringAttachments() async {
    return (await PathProviderEx.getStorageInfo())[0].appFilesDir +
        '/' +
        username +
        '/invoicesPDF';
  }

  void setAnimationParameters() {
    _animationControllerForInvoices =
        AnimationController(duration: Duration(milliseconds: 600), vsync: this);
    _animationForInvoices =
        IntTween(begin: 100, end: 10).animate(_animationControllerForInvoices);
    _animationForInvoices.addListener(() => setState(() {}));

    _animationControllerForEmails =
        AnimationController(duration: Duration(milliseconds: 600), vsync: this);
    _animationForEmails =
        IntTween(begin: 100, end: 10).animate(_animationControllerForEmails);
    _animationForEmails.addListener(() => setState(() {}));

    definedFlex = _animationForInvoices.value;
  }

  String getEmailFromNotificationWidget(Padding notificationItem) {
    Container temp = notificationItem.child;
    Padding temp2 = temp.child;
    Row temp3 = temp2.child;
    Expanded temp4 = temp3.children[0];
    FittedBox temp5 = temp4.child;
    Text text = temp5.child;
    String email = text.data;
    return email;
  }

  Future setModifiedInvoicesForDrawing() async {
    List<Invoice> modifiedInvoices =
        await DatabaseOperations().getModifiedInvoices(username);

    for (Invoice invoice in modifiedInvoices) {
      startReminder(invoice);
      if (invoice.isDefined)
        invoicesInfo.add(invoice);
      else
        undefinedInvoicesInfo.add(invoice);
    }

    setState(() {
      paymentEvents =
          CalendarUtils().generatePaymentEvents(invoicesInfo, preferences);
    });
  }

  Future watchForNewFiles(List<List<String>> trustedEmails) async {
    var watcher = DirectoryWatcher(path);
    watcher.events.listen((event) async {
      String eventString = event.toString().split(" ")[0];
      String eventPath = event.path;

      if (eventString == "add") {
        print("Nowy plik " + eventPath);
//        setState(() {
//          isProgressBarVisible = false;
//        });
        await setFileForDrawing(trustedEmails, eventPath);
      }
      //else if (eventString == "modify")
//        setState(() {
//          isProgressBarVisible = false;
//        });
    });
  }

  Future setFileForDrawing(
      List<List<String>> trustedEmails, String path) async {
    String singlePdfContent = await compute(pdfToString, path);

    if (!path.endsWith("M")) {
      // print(singlePdfContent);

      paymentAmount = PdfParser().extractPayments(singlePdfContent);
      paymentDate = PdfParser().extractDateForParser(singlePdfContent);
      categoryName = Utils().getInvoiceSenderCustomName(trustedEmails, path);
      String userMailName = basename(path).split(";")[0];
      String senderMailName = basename(path).split(";")[1];
      String account = PdfParser().extractAccount(singlePdfContent);

      //DatabaseOperations().addInvoiceToDatabase(paymentDate, paymentAmount.toString(), categoryName, userMailName, senderMailName, account.toString(), username, path);

      bool isInvoiceDefined =
          checkIfInvoiceIsDefined(paymentAmount, paymentDate, account);

      Invoice invoice = constructInvoiceByAttachment(userMailName, senderMailName, account, isInvoiceDefined, path);
      print("Nowa faktura " + invoice.toString());
      startReminder(invoice);

      if (invoice.isDefined)
        invoicesInfo.add(invoice);
      else
        undefinedInvoicesInfo.add(invoice);

      if (mounted)
        setState(() {
          paymentEvents =
              CalendarUtils().generatePaymentEvents(invoicesInfo, preferences);
          //undefinedInvoicesInfo = generateUndefinedInvoicesList(invoicesInfo);
        });
    }
  }

  Invoice constructInvoiceByAttachment(String userMailName, String senderMailName, String account, bool isInvoiceDefined, String path) {
    return new Invoice(
        categoryName,
        userMailName,
        senderMailName,
        paymentAmount,
        paymentDate,
        account,
        isInvoiceDefined,
        path,
        Utils().setUrgencyColorBasedOnDate(
            DateTime.parse(paymentDate), preferences));
  }

  void startReminder(Invoice invoice) {
    if (invoice.color == Colors.red)
      methodChannel.invokeMethod("startMonitoringUrgentPayment", {
        "paymentDate": invoice.paymentDate,
        "categoryName": invoice.categoryName,
        "senderMail": invoice.senderMail,
        "remindFreq": preferences[1]
      });
  }

  @override
  Widget build(BuildContext context) {
    invoicesTilesForConsolided = sortInvoicesForConsolided(invoicesInfo, context);
    invoicesTilesForConsolided.add(List.generate(notificationItems.length,
            (index) => notificationItems[index].notificationItem()));
    PageController pageController = PageController(initialPage: 0);
    if (emailSettings.isEmpty) {
      return MainUI().warningHomePage(context);
    }
    if (trustedEmails.isEmpty) {
      return MainUI().warningHomePageForTrustedEmpty(context);
    }
    return MainUI().homeScreenLayout(
        pageController, context, scaffoldKey, widget.isCalendarViewEnabled, calendarView(pageController, context), homePageAppBar(), urgencyNames, colors, invoicesTilesForConsolided, methodChannel, username, buildDropdownButton());
  }

  AppBar homePageAppBar() {
    return AppBar(
      // leading: IconButton(icon: Icon(Icons.menu), onPressed: (){
      //
      // })
      title: Text(
        "PayIT",
        style: TextStyle(fontSize: 25, color: Colors.white),
      ),

      iconTheme: IconThemeData(color: Colors.white), //add this line here
      actions: <Widget>[
        IconButton(
          icon: widget.isCalendarViewEnabled
              ? UiElements().listIcon()
              : UiElements().calendarIcon(),
          onPressed: () {
            setState(() {
              widget.isCalendarViewEnabled = !widget.isCalendarViewEnabled;
            });
          },
        )
      ],
    );
  }

  Column calendarView(PageController pageController, BuildContext context) {
    return Column(children: [
      LifecycleWatcher(),
      CalendarWidget(
        selectedDay: widget.selectedDate,
        events: paymentEvents,
        notifyParent: generateDefinedPaymentInput,
      ),
      Visibility(
        visible: isInvoiceVisible,
        child: Expanded(
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
                definedColumn(pageController),
                undefinedColumn(pageController)
              ],
            ),
          ),
        ),
      ),
      bottomUserEmailPanel(context),
    ]);
  }

  Expanded undefinedColumn(PageController pageController) {
    return Expanded(
                  flex: 30,
                  child: GestureDetector(
                    onTap: () => setState(() {
                      print("_animationValue");
                      print(_animationForInvoices.value);
                      definedFlex = 1;
                      undefinedFlex = 4;
                      isDefinedVisible = false;
                      isPlaceholderTextVisible = false;
                      isListOfEmailsVisible = false;
                      fontSizeOfDefAndUndef = 12;
                      definedText = "Zdefiniowane";
                      undefinedText = "Niezdefiniowane";
                      if (_animationControllerForInvoices.value == 0.0) {
                        _animationControllerForInvoices.forward();
                      } else {
                        _animationControllerForInvoices.reverse();
                      }
                      if (_animationForInvoices.value == 10) {
                        isDefinedVisible = true;
                        definedTextRotated = 0;
                        undefinedTextRotated = 1;
                        isTipTextVisible = false;
                        isUndefinedVisible = false;
                      } else {
                        isUndefinedVisible = true;
                        undefinedTextRotated = 0;
                        definedTextRotated = 1;
                        isTipTextVisible = true;
                      }

                      if (_animationForEmails.value == 10) {
                        definedText = "Zde...";
                        undefinedText = "Nie...";
                      }
                      if (definedTextRotated == 1) {
                        fontSizeOfDefAndUndef = 17;
                      }
                    }),
                    child: Container(
                        width: 0.0,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white60, width: 2),
                          color: Colors.black26,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            AnimatedIcon(
                              icon: AnimatedIcons.menu_arrow,
                              progress: _animationControllerForInvoices,
                              color: Colors.white,
                            ),
                            Center(
                              child: RotatedBox(
                                  quarterTurns: undefinedTextRotated,
                                  child: RichText(
                                    text: TextSpan(
                                      text: undefinedText + " ",
                                      style: TextStyle(
                                          fontSize: fontSizeOfDefAndUndef),
                                      children: <TextSpan>[
                                        TextSpan(
                                            text:
                                                (undefinedInvoicesInfo.length)
                                                    .toString(),
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                                backgroundColor: Colors.red,
                                                fontSize: 20)),
                                      ],
                                    ),
                                  )),
                            ),
                            Visibility(
                                visible: isTipTextVisible,
                                child: Center(
                                  child: AnimatedOpacity(
                                      opacity: isTipTextVisible ? 1.0 : 0.0,
                                      duration: Duration(seconds: 3),
                                      child: Container(
                                          child: Text(
                                        "Stuknij aby ukryć",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 10),
                                      ))),
                                )),
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
                  ));
  }

  Expanded definedColumn(PageController pageController) {
    return Expanded(
                  flex: _animationForInvoices.value,
                  child: GestureDetector(
//                            onTap: () => setState(() {
//                              definedFlex = 4;
//                              undefinedFlex = 1;
//                              undefinedTextRotated = 1;
//                              definedTextRotated = 0;
//                              isUndefinedVisible = false;
//                              widget.definedInvoicesInfo.length == 0
//                                  ? isDefinedVisible = false
//                                  : isDefinedVisible = true;
//                              widget.definedInvoicesInfo.length == 0
//                                  ? isPlaceholderTextVisible = true
//                                  : isPlaceholderTextVisible = false;
//                              isListOfEmailsVisible = false;
//                              fontSizeOfDefAndUndef = 16;
//                              definedText = "Zdefiniowane";
//                              undefinedText = "Niezdefiniowane";
//
//                            }),
                    child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white60, width: 2),
                          color: definedColor,
                        ),
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              RotatedBox(
                                  quarterTurns: definedTextRotated,
                                  child: RichText(
                                    text: TextSpan(
                                      text: definedText+ " ",
                                      style: TextStyle(
                                          fontSize: fontSizeOfDefAndUndef),
                                      children: <TextSpan>[
                                        TextSpan(
                                            text: (widget.definedInvoicesInfo
                                                    .length)
                                                .toString(),
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: definedColor,
                                                backgroundColor: Colors.white,
                                                fontSize: 20)),
                                      ],
                                    ),
                                  )),
                              Visibility(
                                  visible: isDefinedVisible,
                                  child: Expanded(
                                    child: PaymentPage(
                                        pageController,
                                        widget.definedInvoicesInfo,
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
                  ));
  }

  GestureDetector bottomUserEmailPanel(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() {
        isListOfEmailsVisible = !isListOfEmailsVisible;
        fontSizeOfDefAndUndef = 12;

        if (isListOfEmailsVisible == false) {
          definedText = "Zdefiniowane";
          undefinedText = "Niezdefiniowane";
        }
        if (_animationControllerForEmails.value == 0.0) {
          _animationControllerForEmails.forward();
          definedText = "Zde...";
          undefinedText = "Nie...";
        } else {
          _animationControllerForEmails.reverse();
        }
        print("animation or email value:");
        print(_animationForEmails.value);
      }),
      child: userEmailTileListWithStats(context),
    );
  }

  Column userEmailTileListWithStats(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
//                    SizedBox(width: MediaQuery.of(context).size.width / 7),
//                    Text("Synchronizuję ... " + syncedEmailBoxName),
//                    CircularProgressIndicator(),
        Container(
            color: Colors.blue,
            height: MediaQuery.of(context).size.height / 20,
            child: Center(
              child: RichText(
                text: TextSpan(
                  text: 'Twoje skrzynki e-mail ',
                  style: TextStyle(fontSize: 12),
                  children: <TextSpan>[
                    TextSpan(
                        text: (notificationItems.length).toString(),
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                            backgroundColor: Colors.white,
                            fontSize: 20)),
                  ],
                ),
              ),
            )),

        Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height /
                  _animationForEmails.value +
              10,
          color: Colors.blue,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: List.generate(notificationItems.length,
                (index) => notificationItems[index].notificationItem()),
          ),
        ),
      ],
    );
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

  downloadAttachmentForAllMailboxes(List<List<dynamic>> emailSettings,
      List<List<String>> trustedEmails) async {
    print("Zaciągam maile");

    List<String> tempUserEmailsNames = new List();
    List<Padding> tempNotificationItems = new List();

    int i = 0;
    for (var singleEmailSettings in emailSettings) {
      //AppNotification appNotification = new AppNotification(singleEmailSettings[0], false);
      print("Zaciągam maile po stronie Dart " + singleEmailSettings.toString());

      tempUserEmailsNames.add(singleEmailSettings[0].toString());
      //appNotifications.add(appNotification);

      //tempNotificationItems.add(UiElements().notificationItem(appNotification, true, false));

      List<dynamic> downloadAttachmentArgs = [
        singleEmailSettings,
        getMailSenderAddresses(trustedEmails),
        path,
        methodChannel,
        username,
        preferences[0]
      ];
      Downloader().downloadAttachment(downloadAttachmentArgs);
    }
    tempUserEmailsNames.add("Wszystkie adresy");
    setState(() {
      userEmailsNames = tempUserEmailsNames;
      selectedEmailAddress = userEmailsNames.last;
      //notificationItems = tempNotificationItems;
    });
  }

  List<String> getMailSenderAddresses(List<List<String>> trustedEmails) {
    List<String> senderAddresses = new List();
    for (List<String> record in trustedEmails) {
      senderAddresses.add(record[0]);
    }
    return senderAddresses;
  }

  void startServiceInPlatform() async {
    if (Platform.isAndroid) {
      //var methodChannel = MethodChannel("com.example.flutter_payit");
      String data = await methodChannel.invokeMethod("startService");
      //print("Serwis odpal się"+ data);
    }
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
          accountForTransfer,
          true,
          path,
          Utils().colorFromName(color));

      tempDefinedInvoicesInfo.add(singleInvoiceInfoFromCalendar);
    }
    if (events.isEmpty) {
      setState(() {
        widget.definedInvoicesInfo = [];
        isPlaceholderTextVisible = true;
        isDefinedVisible = false;
        definedColor = Colors.blue;
      });
    } else {
      setState(() {
        widget.definedInvoicesInfo = tempDefinedInvoicesInfo;
        definedColor = Utils().setUrgencyColor(widget.definedInvoicesInfo, preferences);
        isPlaceholderTextVisible = false;
        isDefinedVisible = true;
      });
    }
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
      paymentEvents =
          CalendarUtils().generatePaymentEvents(tempInvoicesInfo, preferences);
    });
  }



  Future<bool> _onWillPop(BuildContext context) async {
    print("OnWillPop");
    if (Platform.isAndroid) {
      if (Navigator.of(context).canPop()) {
        return Future.value(true);
      } else {
        startServiceInPlatform();
        return Future.value(false);
      }
    } else {
      return Future.value(true);
    }
  }

  Future<void> javaMethod(MethodCall call) async {
    switch (call.method) {
      case 'syncCompleted':
        print("syncCompleted " + call.arguments.toString());
        for (NotificationItem notificationItem in notificationItems) {
          if (call.arguments.toString().contains(notificationItem.userEmail)) {
            setState(() {
              notificationItem.isProgressVisible = false;
            });
          }
        }
        break;

      case 'syncStarted':
        print("syncStarted " + call.arguments.toString());
        List<String> parts = call.arguments.toString().split(" ");

        for (NotificationItem notificationItem in notificationItems) {
          print("Wyciągany progress w for");
          print(parts[2]);
          if (call.arguments.toString().contains(notificationItem.userEmail)) {
            setState(() {
              notificationItem.isProgressVisible = true;
              notificationItem.progressPercentage = parts[2];
            });
          }
        }

        break;
    }
  }

  List<NotificationItem> populateNotificationItemsList(
      List<List<dynamic>> emailSettings) {
    List<NotificationItem> populatedList = new List();

    for (List<dynamic> singleEmailSetting in emailSettings) {
      print("SingleEmailSetting w populacji " + singleEmailSetting[0]);
      populatedList
          .add(new NotificationItem(singleEmailSetting[0], true, "0%"));
    }
    return populatedList;
  }

  List<List<Widget>> sortInvoicesForConsolided(
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

    for (Invoice u in undefinedInvoicesInfo) {
      undefined.add(PaymentWidget.paymentCard(
          undefinedInvoicesInfo, u, u.color, context));
    }

    all.add(urgent);
    all.add(mediumUrgent);
    all.add(notUrgent);
    all.add(undefined);
    return all;
  }

  bool checkIfInvoiceIsDefined(
      double paymentAmount, String paymentDate, String account) {
    bool flag = true;
    if (-DateTime.parse(paymentDate).difference(DateTime.now()).inDays >
            44000 ||
        paymentAmount == 0 ||
        account == "00000000000000000000000000") {
      flag = false;
    }
    return flag;
  }
}
