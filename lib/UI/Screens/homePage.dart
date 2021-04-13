import 'dart:async';
import 'dart:core';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_payit/JavaDownloaderInvoke/downloader.dart';
import 'package:flutter_payit/Objects/notificationItem.dart';
import 'package:flutter_payit/Objects/warningNotification.dart';
import 'package:flutter_payit/UI/HelperClasses/homeScreenLayout.dart';
import 'package:flutter_payit/UI/HelperClasses/mainUI.dart';
import 'package:flutter_payit/UI/HelperClasses/uiElements.dart';
import 'package:flutter_payit/Utils/utils.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/services.dart';
import 'package:path_provider_ex/path_provider_ex.dart';
import 'package:flutter_payit/CalendarUtils/calendarUtils.dart';
import 'package:flutter_payit/Database/databaseOperations.dart';
import 'package:flutter_payit/Objects/invoice.dart';
import 'package:flutter_payit/Utils/userOperationsOnEmails.dart';
import 'package:flutter_payit/PdfParser/pdfParser.dart';
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
  String pathForStoringAttachments;
  String paymentDate;
  double paymentAmount;
  String categoryName;

  String syncedEmailBoxName = "...";
  static const methodChannel = const MethodChannel("com.example.flutter_payit");

  Map<DateTime, List> paymentEvents = new Map();

  bool isProgressOfInsertingVisible = false;
  bool isContainerWithNotificationsVisible = false;
  bool isTrustedEmailsEmpty = false;
  bool isUserEmailsEmpty = false;
  bool isListOfEmailsVisible = true;
  bool isPlaceholderTextVisible = true;
  bool isUndefinedVisible = false;
  bool isDefinedVisible = true;
  bool isTipTextVisible = false;
  bool isInvoiceVisible = true;

  int definedFlex = 4;
  int undefinedFlex = 1;
  int undefinedTextRotated = 1;
  int definedTextRotated = 0;

  String definedText = "Zdefiniowane";
  String undefinedText = "Niezdefiniowane";

  double fontSizeOfDefAndUndef = 12;

  List<String> userEmailsNames = new List();
  List<WarningNotification> warnings = new List();
  List<Invoice> definedInvoicesInfo = new List();
  List<Invoice> undefinedInvoicesInfo = new List();
  List<String> matchedCustomNames = new List();
  List<int> preferences;
  List<NotificationItem> notificationItems = new List();
  List<List<dynamic>> emailSettings = new List();
  List<List<String>> trustedEmails = new List();

  String selectedEmailAddress;
  static String username = "<Username>";

  Color definedColor = Colors.blue;
  String endMessage;

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  final SnackBar snackBarProgressIndicator =
      UiElements().myShowSnackBar("Synchronizuję ...");
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();

    if (widget.definedInvoicesInfo.isNotEmpty) {
      definedColor = widget.definedInvoicesInfo.last.color;
    }

    userEmailsNames.add("Wszystkie adresy");
    Future.delayed(Duration.zero, () async {
      username = await getUsernameFromFlutterStorage();
      pathForStoringAttachments = await generatePathForStoringAttachments();
      preferences = await DatabaseOperations().getUserPrefsFromDB(username);
      generateDirectory();
      emailSettings = await UserOperationsOnEmails().getEmailSettings(username);
      notificationItems = populateNotificationItemsList(emailSettings);
      //methodChannel.setMethodCallHandler(javaMethod);
      trustedEmails =
          await UserOperationsOnEmails().getInvoiceSenders(username);

      if (emailSettings.isNotEmpty) {
        trustedEmails.isNotEmpty
            ? downloadAttachmentForAllMailboxes(emailSettings, trustedEmails)
            : print("Nothing to do");

        trustedEmails.isNotEmpty
            ? await watchForNewFiles(trustedEmails)
            : print("Nothing to do");
      } else {
        setState(() {
          isUserEmailsEmpty = true;
        });
      }
      if (trustedEmails.isEmpty) {
        setState(() {
          isTrustedEmailsEmpty = true;
        });
      }

      print("Dlugosc warningów");
      print(warnings.length);

      List<FileSystemEntity> invoiceFileList =
          await PdfParser().dirContents(pathForStoringAttachments);

      setState(() {
        isProgressOfInsertingVisible = true;
      });

      for (FileSystemEntity file in invoiceFileList)
        trustedEmails.isNotEmpty
            ? await setFileForDrawing(trustedEmails, file.path)
            : print("Nothing to do");

      await setModifiedInvoicesForDrawing();

      setState(() {
        isProgressOfInsertingVisible = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isProgressOfInsertingVisible) {
      return MainUI().placeholderCalendarView();
    } else {
      return HomeScreenLayout(
          context,
          scaffoldKey,
          widget.isCalendarViewEnabled,
          methodChannel,
          username,
          buildDropdownButton(),
          warnings,
          undefinedInvoicesInfo,
          definedInvoicesInfo,
          notificationItems,
          isTrustedEmailsEmpty,
          isUserEmailsEmpty,
          paymentEvents,
          isProgressOfInsertingVisible,
          isContainerWithNotificationsVisible,
          isListOfEmailsVisible,
          isPlaceholderTextVisible,
          isUndefinedVisible,
          isDefinedVisible,
          isTipTextVisible,
          isInvoiceVisible,
          definedFlex,
          undefinedFlex,
          definedTextRotated,
          undefinedTextRotated,
          definedText,
          undefinedText,
          fontSizeOfDefAndUndef,
      emailSettings);
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

  void generateDirectory() {
    Directory invoicesDir = new Directory(pathForStoringAttachments);
    invoicesDir.create(recursive: true);
  }

  Future<String> getUsernameFromFlutterStorage() async =>
      (await storage.read(key: "username")).toString();

  Future<String> generatePathForStoringAttachments() async {
    return (await PathProviderEx.getStorageInfo())[0].appFilesDir +
        '/' +
        username +
        '/invoicesPDF';
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
        definedInvoicesInfo.add(invoice);
      else
        undefinedInvoicesInfo.add(invoice);
    }

    setState(() {
      paymentEvents = CalendarUtils()
          .generatePaymentEvents(definedInvoicesInfo, preferences);
    });
  }

  Future watchForNewFiles(List<List<String>> trustedEmails) async {
    var watcher = DirectoryWatcher(pathForStoringAttachments);
    watcher.events.listen((event) async {
      String eventString = event.toString().split(" ")[0];
      String eventPath = event.path;

      if (eventString == "add") {
        setState(() {
          isProgressOfInsertingVisible = true;
        });
        print("Nowy plik " + eventPath);
        await setFileForDrawing(trustedEmails, eventPath);
        setState(() {
          isProgressOfInsertingVisible = false;
        });
      }
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

      Invoice invoice = constructInvoiceByAttachment(
          userMailName, senderMailName, account, isInvoiceDefined, path);
      print("Nowa faktura " + invoice.toString());
      startReminder(invoice);

      if (invoice.isDefined)
        definedInvoicesInfo.add(invoice);
      else
        undefinedInvoicesInfo.add(invoice);

      if (mounted)
        setState(() {
          paymentEvents = CalendarUtils()
              .generatePaymentEvents(definedInvoicesInfo, preferences);
          //undefinedInvoicesInfo = generateUndefinedInvoicesList(invoicesInfo);
        });
    }
  }

  Invoice constructInvoiceByAttachment(
      String userMailName,
      String senderMailName,
      String account,
      bool isInvoiceDefined,
      String path) {
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
        pathForStoringAttachments,
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

  void filterByUserMailbox(String selectedEmailAddress) {
    List<Invoice> tempInvoicesInfo = new List();

    tempInvoicesInfo.addAll(definedInvoicesInfo);

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
      tempInvoicesInfo = definedInvoicesInfo;
    }

    setState(() {
      paymentEvents =
          CalendarUtils().generatePaymentEvents(tempInvoicesInfo, preferences);
    });
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
