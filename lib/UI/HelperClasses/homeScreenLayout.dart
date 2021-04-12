import 'dart:core';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_payit/Objects/invoice.dart';
import 'package:flutter_payit/Objects/notificationItem.dart';
import 'package:flutter_payit/Objects/warningNotification.dart';
import 'package:flutter_payit/UI/HelperClasses/mainUI.dart';
import 'package:flutter_payit/UI/HelperClasses/uiElements.dart';

import 'calendarView.dart';
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
  bool isContainerWithNotificationsVisible = false;
      List<Invoice> undefinedInvoicesInfo;
      List<Invoice> definedInvoicesInfo;
      List<NotificationItem> notificationItem;
  Map<DateTime, List> paymentEvents;

  HomeScreenLayout(
      this.pageController,
      this.context,
      this.scaffoldKey,
      this.isCalendarViewEnabled,
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
      this.notificationItem,
      this.paymentEvents
  );

  @override
  _HomeScreenLayoutState createState() => _HomeScreenLayoutState();
}

class _HomeScreenLayoutState extends State<HomeScreenLayout> {
  String selectedEmailAddress;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: widget.scaffoldKey,
        body: widget.isCalendarViewEnabled
            ? Stack(
                alignment: Alignment.topRight,
                children: [
                  //widget.calendarView,
                  new CalendarView(widget.definedInvoicesInfo, widget.undefinedInvoicesInfo, widget.notificationItem, widget.paymentEvents, widget.username),
                  AnimatedOpacity(
                      opacity: widget.isContainerWithNotificationsVisible ? 1.0 : 0.0,
                      duration: Duration(milliseconds: 500),
                      child: new FrostedContainer(
                          context,
                          widget.warnings,
                          widget.isContainerWithNotificationsVisible,
                      widget.isTrustedEmailsEmpty,
                      widget.isUserEmailsEmpty))
                ],
              )
            : new ConsolidedInvoicesView(widget.username, widget.undefinedInvoicesInfo, widget.definedInvoicesInfo, widget.notificationItem),
        appBar: homePageAppBar(context),
        drawer: UiElements().homePageDrawerMenu(context, widget.methodChannel,
            widget.username, widget.selectEmailAddress));
  }

  AppBar homePageAppBar(BuildContext context) {
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
        ),
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            IconButton(
              icon: widget.warnings.length != 0
                  ? Icon(
                Icons.warning_amber_outlined,
                color: Colors.red,
              )
                  : Icon(
                Icons.notifications,
                color: Colors.white,
              ),
              iconSize: widget.warnings.length!=0 ? 40 : 25,
              onPressed: () {
                setState(() {
                  widget.isContainerWithNotificationsVisible =
                  !widget.isContainerWithNotificationsVisible;
                });
              },
            ),
            UiElements().notificationsNumIcon(widget.warnings.length),
          ],
        ),
      ],
    );

  }

}
