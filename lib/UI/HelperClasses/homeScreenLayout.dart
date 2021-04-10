import 'dart:core';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_payit/Objects/invoice.dart';
import 'package:flutter_payit/Objects/notificationItem.dart';
import 'package:flutter_payit/Objects/warningNotification.dart';
import 'package:flutter_payit/UI/HelperClasses/mainUI.dart';
import 'package:flutter_payit/UI/HelperClasses/uiElements.dart';

import 'consolidedInvoicesView.dart';
import 'frostedContainer.dart';

class HomeScreenLayout extends StatefulWidget {
  PageController pageController;
  BuildContext context;
  GlobalKey<ScaffoldState> scaffoldKey;
  bool isCalendarViewEnabled;
  Column calendarView;
  AppBar homePageAppBar;
  List<List<Widget>> invoicesTilesForConsolided;
  MethodChannel methodChannel;
  String username;
  DropdownButton<String> selectEmailAddress;
  bool isNotificationsClicked;
  List<WarningNotification> warnings;
  bool isTrustedEmailsEmpty;
  bool isUserEmailsEmpty;
      List<Invoice> undefinedInvoicesInfo;
      List<Invoice> definedInvoicesInfo;
      List<NotificationItem> notificationItem;

  HomeScreenLayout(
      this.pageController,
      this.context,
      this.scaffoldKey,
      this.isCalendarViewEnabled,
      this.calendarView,
      this.homePageAppBar,
      this.invoicesTilesForConsolided,
      this.methodChannel,
      this.username,
      this.selectEmailAddress,
      this.isNotificationsClicked,
      this.warnings,
      this.isTrustedEmailsEmpty,
      this.isUserEmailsEmpty,
      this.undefinedInvoicesInfo,
      this.definedInvoicesInfo,
      this.notificationItem
  );

  @override
  _HomeScreenLayoutState createState() => _HomeScreenLayoutState();
}

class _HomeScreenLayoutState extends State<HomeScreenLayout> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: widget.scaffoldKey,
        body: widget.isCalendarViewEnabled
            ? Stack(
                alignment: Alignment.topRight,
                children: [
                  widget.calendarView,
                  AnimatedOpacity(
                      opacity: widget.isNotificationsClicked ? 1.0 : 0.0,
                      duration: Duration(milliseconds: 500),
                      child: new FrostedContainer(
                          context,
                          widget.warnings,
                          widget.isNotificationsClicked,
                      widget.isTrustedEmailsEmpty,
                      widget.isUserEmailsEmpty))
                ],
              )
            : new ConsolidedInvoicesView(widget.username, widget.undefinedInvoicesInfo, widget.definedInvoicesInfo, widget.notificationItem),
        appBar: widget.homePageAppBar,
        drawer: UiElements().homePageDrawerMenu(context, widget.methodChannel,
            widget.username, widget.selectEmailAddress));
  }
}
