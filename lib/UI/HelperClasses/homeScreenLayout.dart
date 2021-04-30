import 'dart:core';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:payit/Objects/invoice.dart';
import 'package:payit/Objects/notificationItem.dart';
import 'package:payit/Objects/warningNotification.dart';
import 'package:payit/UI/HelperClasses/frostedEmailPanel.dart';
import 'package:payit/UI/HelperClasses/mainUI.dart';
import 'package:payit/UI/HelperClasses/uiElements.dart';
import 'package:payit/UI/Screens/ConfigScreens/emailBoxesPanel.dart';
import 'package:payit/UI/Screens/ConfigScreens/trustedList.dart';

import 'calendarView.dart';
import 'consolidedInvoicesView.dart';
import 'frostedContainer.dart';

class HomeScreenLayout extends StatefulWidget {
  BuildContext context;
  GlobalKey<ScaffoldState> scaffoldKey;
  bool isCalendarViewEnabled;
  Column calendarView;
  AppBar homePageAppBar;
  MethodChannel methodChannel;
  String username;
  DropdownButton<String> selectEmailAddress;
  DropdownButton <String> selectCategoryName;
  bool isNotificationsClicked;
  List<Invoice> undefinedInvoicesInfo;
  List<Invoice> definedInvoicesInfo;
  List<NotificationItem> notificationItem;

  List<List<dynamic>> emailSettings;

  Map<DateTime, List> paymentEvents;

  bool isProgressOfInsertingVisible;

  bool isWaringIconVisible = false;
  bool isTrustedEmailsEmpty;
  bool isUserEmailsEmpty;
  bool isListOfEmailsVisible;
  bool isPlaceholderTextVisible;
  bool isUndefinedVisible;
  bool isDefinedVisible;
  bool isTipTextVisible;
  bool isInvoiceVisible;

  int definedFlex;
  int undefinedFlex;
  int undefinedTextRotated;
  int definedTextRotated;

  String definedText;
  String undefinedText;

  double fontSizeOfDefAndUndef;

  HomeScreenLayout(
      this.context,
      this.scaffoldKey,
      this.isCalendarViewEnabled,
      this.methodChannel,
      this.username,
      this.selectEmailAddress,
      this.selectCategoryName,
      this.undefinedInvoicesInfo,
      this.definedInvoicesInfo,
      this.notificationItem,
      this.isTrustedEmailsEmpty,
      this.isUserEmailsEmpty,
      this.paymentEvents,
      this.isProgressOfInsertingVisible,
      this.isListOfEmailsVisible,
      this.isPlaceholderTextVisible,
      this.isUndefinedVisible,
      this.isDefinedVisible,
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

  @override
  _HomeScreenLayoutState createState() => _HomeScreenLayoutState();
}

class _HomeScreenLayoutState extends State<HomeScreenLayout> {
  String selectedEmailAddress;
  List<WarningNotification> warnings = new List();
  bool isContainerWithNotificationsVisible = false;
 @override
 void initState() {
    // TODO: implement initState
    super.initState();
    if(widget.isTrustedEmailsEmpty){
      setState(() {
        warnings.add(new WarningNotification(
            "Brak zaufanych adresów", TrustedListPanel()));
      });
    }
    if(widget.isUserEmailsEmpty){
      setState(() {
        warnings.add(new WarningNotification("Brak skrzynek e-mail", EmailBoxesPanel()));
      });
    }
    if (widget.isTrustedEmailsEmpty || widget.isUserEmailsEmpty) {
      isContainerWithNotificationsVisible = true;
      widget.isWaringIconVisible = true;
    }
  }
  @override
  Widget build(BuildContext context) {
    print("Czy kontener z notyfikacjami widoczny w homescreen layout");
    print(isContainerWithNotificationsVisible);
    return Scaffold(
        key: widget.scaffoldKey,
        body: widget.isCalendarViewEnabled
            ? Stack(
                alignment: Alignment.topRight,
                children: [
                  //widget.calendarView,
                  CalendarView(
                      widget.definedInvoicesInfo,
                      widget.undefinedInvoicesInfo,
                      widget.notificationItem,
                      widget.paymentEvents,
                      widget.username,
                      widget.isListOfEmailsVisible,
                      widget.isPlaceholderTextVisible,
                      widget.isUndefinedVisible,
                      widget.isTipTextVisible,
                      widget.isInvoiceVisible,
                      widget.definedFlex,
                      widget.undefinedFlex,
                      widget.definedTextRotated,
                      widget.undefinedTextRotated,
                      widget.definedText,
                      widget.undefinedText,
                      widget.fontSizeOfDefAndUndef,
                      widget.emailSettings),
                      FrostedEmailPanel(widget.emailSettings, true),
                  AnimatedOpacity(
                      opacity: isContainerWithNotificationsVisible
                          ? 1.0
                          : 0.0,
                      duration: Duration(milliseconds: 500),
                      child: new FrostedContainer(
                          context,
                          warnings,
                          isContainerWithNotificationsVisible,
                          widget.isTrustedEmailsEmpty,
                          widget.isUserEmailsEmpty))
                ],
              )
            : new ConsolidedInvoicesView(
                widget.username,
                widget.undefinedInvoicesInfo,
                widget.definedInvoicesInfo,
                widget.notificationItem),
        appBar: homePageAppBar(context, widget.selectCategoryName),
        drawer: UiElements().homePageDrawerMenu(context, widget.methodChannel,
            widget.username, widget.selectEmailAddress));
  }

  AppBar homePageAppBar(BuildContext context, DropdownButton <String> selectCategoryName) {
    return AppBar(
      title: Text(
        "PayIT",
        style: TextStyle(fontSize: 25, color: Colors.white),
      ),

      iconTheme: IconThemeData(color: Colors.white), //add this line here
      actions: <Widget>[
        Row(
          children: [
            Center(child: Container(width: MediaQuery.of(context).size.width/1.7, height: 50, child: selectCategoryName)),
            IconButton(
              icon: widget.isCalendarViewEnabled
                  ? UiElements().listIcon()
                  : UiElements().calendarIcon(),
              onPressed: () {
                setState(() {
                  widget.isCalendarViewEnabled = !widget.isCalendarViewEnabled;
                });
              },
            ),
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                IconButton(
                  icon: widget.isWaringIconVisible
                      ? Icon(
                    Icons.warning_amber_outlined,
                    color: Colors.red,
                  )
                      : Icon(
                    Icons.notifications,
                    color: Colors.white,
                  ),
                  iconSize: widget.isWaringIconVisible ? 40 : 25,
                  onPressed: () {
                    setState(() {
                      print("czy kontener z notyf widoczny?");
                      print(isContainerWithNotificationsVisible);
                      isContainerWithNotificationsVisible =
                      !isContainerWithNotificationsVisible;
                    });
                  },
                ),
                UiElements().notificationsNumIcon(warnings.length),
              ],
            ),
          ],
        ),


      ],
    );
  }
}
