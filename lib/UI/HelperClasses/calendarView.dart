import 'dart:core';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:payit/Database/databaseOperations.dart';
import 'package:payit/LifeCycleHandler/lifeCycle.dart';
import 'package:payit/Objects/notificationItem.dart';
import 'package:payit/PdfParser/pdfParser.dart';
import 'package:payit/UI/HelperClasses/userEmailsStatusPanel.dart';
import 'package:payit/UI/Screens/PaymentPage.dart';
import 'package:payit/Utils/userOperationsOnEmails.dart';
import 'package:payit/Utils/utils.dart';
import 'package:payit/UI/HelperClasses/calendarWidget.dart';
import 'package:payit/Objects/invoice.dart';
import 'package:intl/intl.dart';

class CalendarView extends StatefulWidget {
  Color definedColor = Colors.blue;

  Map<DateTime, List> paymentEvents;
  String username;

  int definedFlex;
  int undefinedFlex;
  int undefinedTextRotated;
  int definedTextRotated;

  String definedText;
  String undefinedText;

  List<Invoice> definedInvoicesInfo;
  List<Invoice> undefinedInvoicesInfo;
  List<NotificationItem> notificationItems;

  bool isListOfEmailsVisible;
  bool isPlaceholderTextVisible;
  bool isUndefinedVisible;
  bool isDefinedVisible = false;
  bool isTipTextVisible;

  double fontSizeOfDefAndUndef;
  List<List<dynamic>> emailSettings;

  DateTime selectedDate;
  bool isInvoiceVisible = true;

  _CalendarViewState createState() => _CalendarViewState();
  CalendarView(this.definedInvoicesInfo,
      this.undefinedInvoicesInfo,
      this.notificationItems,
      this.paymentEvents,
      this.username,
      this.isListOfEmailsVisible,
      this.isPlaceholderTextVisible,
      this.isUndefinedVisible,
      this.isTipTextVisible,
      this.isInvoiceVisible,
      this.definedFlex,
      this.undefinedFlex,
      this.definedTextRotated,
      this.undefinedTextRotated,
      this.definedText,
      this.undefinedText,
      this.fontSizeOfDefAndUndef,
      this.emailSettings);
}

class _CalendarViewState extends State<CalendarView>
    with TickerProviderStateMixin {
  AnimationController _animationControllerForInvoices;
  Animation _animationForInvoices;

  AnimationController _animationControllerForEmails;
  Animation _animationForEmails;

  List<int> userPreferences;

  @override
  void initState() {
    super.initState();
    print("Robię init state calendara");
    setAnimationParameters();
    Future.delayed(Duration.zero, () async {
      userPreferences =
          await DatabaseOperations().getUserPrefsFromDB(widget.username);
    });
  }

  @override
  Widget build(BuildContext context) {
    print("Robię build kalendarza");
    PageController pageController = PageController(initialPage: 0);
    return Column(children: [
      LifecycleWatcher(),
      CalendarWidget(
        selectedDay: widget.selectedDate,
        events: widget.paymentEvents,
        notifyParent: generateDefinedPaymentInput,
      ),
      Visibility(
        visible: widget.isInvoiceVisible,
        child: Expanded(
          child: Row(
            children: [
              definedColumn(pageController),
              undefinedColumn(pageController)
            ],
          ),
        ),
      ),
      //bottomUserEmailPanel(context),
    ]);
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

    widget.definedFlex = _animationForInvoices.value;
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
        widget.isPlaceholderTextVisible = true;
        widget.isDefinedVisible = false;
        widget.definedColor = Colors.blue;
        if(_animationForInvoices.value==10){
          widget.isPlaceholderTextVisible = false;
        }

      });
    } else {
      setState(() {
        widget.definedInvoicesInfo = tempDefinedInvoicesInfo;
        widget.definedColor = Utils()
            .setUrgencyColor(widget.definedInvoicesInfo, userPreferences);
        widget.isPlaceholderTextVisible = false;
        widget.isDefinedVisible = true;
        if(_animationForInvoices.value==10){
          widget.isDefinedVisible = false;
          widget.isPlaceholderTextVisible = false;
        }
      });
    }
  }

  Expanded undefinedColumn(PageController pageController) {
    return Expanded(
        flex: 30,
        child: GestureDetector(
          onTap: () => setState(() {
            widget.definedFlex = 1;
            widget.undefinedFlex = 4;
            widget.isDefinedVisible = false;
            widget.isPlaceholderTextVisible = false;
            widget.isListOfEmailsVisible = false;
            widget.fontSizeOfDefAndUndef = 16;
            widget.definedText = "Zdefiniowane";
            widget.undefinedText = "Niezdefiniowane";
            if (_animationControllerForInvoices.value == 0.0) {
              _animationControllerForInvoices.forward();
            } else {
              _animationControllerForInvoices.reverse();
            }
            if (_animationForInvoices.value == 10) {
              widget.isDefinedVisible = true;
              widget.definedTextRotated = 0;
              widget.undefinedTextRotated = 1;
              widget.isTipTextVisible = false;
              widget.isUndefinedVisible = false;
              widget.fontSizeOfDefAndUndef = 16;

            } else {
              widget.isUndefinedVisible = true;
              widget.isDefinedVisible = false;
              widget.undefinedTextRotated = 0;
              widget.definedTextRotated = 1;
              widget.isTipTextVisible = true;
              widget.isPlaceholderTextVisible = false;
            }

            if (_animationForEmails.value == 10) {
              widget.definedText = "Zde...";
              widget.undefinedText = "Nie...";
            }
            if (widget.definedTextRotated == 1) {
              widget.fontSizeOfDefAndUndef = 16;
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
                        quarterTurns: widget.undefinedTextRotated,
                        child: RichText(
                          text: TextSpan(
                            text: widget.undefinedText + " ",
                            style: TextStyle(
                                fontSize: widget.fontSizeOfDefAndUndef),
                            children: <TextSpan>[
                              TextSpan(
                                  text: (widget.undefinedInvoicesInfo.length)
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
                      visible: widget.isTipTextVisible,
                      child: Center(
                        child: AnimatedOpacity(
                            opacity: widget.isTipTextVisible ? 1.0 : 0.0,
                            duration: Duration(seconds: 3),
                            child: Container(
                                child: Text(
                              "Stuknij aby ukryć",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 10),
                            ))),
                      )),
                  Visibility(
                      visible: widget.isUndefinedVisible,
                      child: Expanded(
                          child: PaymentPage(
                              pageController,
                              widget.undefinedInvoicesInfo,
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
          child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white60, width: 2),
                color: widget.definedColor,
              ),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    RotatedBox(
                        quarterTurns: widget.definedTextRotated,
                        child: RichText(
                          text: TextSpan(
                            text: widget.definedText + " ",
                            style: TextStyle(
                                fontSize: widget.fontSizeOfDefAndUndef),
                            children: <TextSpan>[
                              TextSpan(
                                  text: (widget.definedInvoicesInfo.length)
                                      .toString(),
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: widget.definedColor,
                                      backgroundColor: Colors.white,
                                      fontSize: 20)),
                            ],
                          ),
                        )),
                    Visibility(
                        visible: widget.isDefinedVisible,
                        child: Expanded(
                          child: PaymentPage(
                              pageController,
                              widget.definedInvoicesInfo,
                              widget.definedColor,
                              "Pilne"),
                        )),
                    Visibility(
                        visible: widget.isPlaceholderTextVisible,
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


}
