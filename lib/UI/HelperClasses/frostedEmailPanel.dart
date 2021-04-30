import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:payit/Objects/notificationItem.dart';
import 'package:payit/UI/HelperClasses/userEmailsStatusPanel.dart';

class FrostedEmailPanel extends StatefulWidget {
  List<List<dynamic>> emailSettings;
  bool isThisVisible;

  @override
  _FrostedEmailPanelState createState() => _FrostedEmailPanelState();

  FrostedEmailPanel(this.emailSettings, this.isThisVisible);
}

class _FrostedEmailPanelState extends State<FrostedEmailPanel>
    with TickerProviderStateMixin {
  AnimationController _animationControllerForEmailsPanel;
  Animation _animationForEmails;

  int animatedHeight;

  static const methodChannel = const MethodChannel("com.example.payit");
  List<NotificationItem> notificationItems = new List();

  @override
  void initState() {
    notificationItems = populateNotificationItemsList(widget.emailSettings);
    methodChannel.setMethodCallHandler(javaMethod);
    setAnimationParameters();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () => setState(() {
              if (_animationControllerForEmailsPanel.value == 0.0) {
                _animationControllerForEmailsPanel.forward();
                animatedHeight = _animationForEmails.value;
              } else {
                _animationControllerForEmailsPanel.reverse();
              }
              widget.isThisVisible = !widget.isThisVisible;
            }),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Visibility(
              visible: widget.isThisVisible ? true : false,
                child: Column(
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height/1.419,
                    ),
                    ClipRect(
                      child: BackdropFilter(
                        filter: ImageFilter.blur(
                          sigmaX: 4.0,
                          sigmaY: 4.0,
                        ),
                        child: Container(
                            color: Colors.blue.withOpacity(0.5),
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
                      ),
                    ),
                  ],
                ),
            ),
            Visibility(
              visible: widget.isThisVisible ? false : true,
                child: Column(
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height/1.201,
                    ),
                    ClipRect(
                      child: BackdropFilter(
                        filter: ImageFilter.blur(
                          sigmaX: 4.0,
                          sigmaY: 4.0,
                        ),
                        child: Container(
                            color: Colors.blue.withOpacity(0.5),
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
                      ),
                    ),
                  ],
                ),

            ),
            AnimatedOpacity(
              opacity: widget.isThisVisible ? 1.0 : 0.0,
              duration: Duration(milliseconds: 500),
              child: Visibility(
                visible: widget.isThisVisible,
                child: ClipRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(
                      sigmaX: 4.0,
                      sigmaY: 4.0,
                    ),
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height / 8,
                      color: Colors.blue.withOpacity(0.5),
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: List.generate(
                            notificationItems.length,
                            (index) =>
                                notificationItems[index].notificationItem()),
                      ),
                    ),
                  ),
                ),
              ),
            )
          ],
        ));
  }

  void setAnimationParameters() {
    _animationControllerForEmailsPanel =
        AnimationController(duration: Duration(milliseconds: 600), vsync: this);
    _animationForEmails = IntTween(begin: 100, end: 10)
        .animate(_animationControllerForEmailsPanel);
    _animationForEmails.addListener(() => setState(() {}));

    animatedHeight = _animationForEmails.value;
  }

  List<NotificationItem> populateNotificationItemsList(
      List<List<dynamic>> emailSettings) {
    List<NotificationItem> populatedList = new List();

    for (List<dynamic> singleEmailSetting in emailSettings) {
      print("SingleEmailSetting w populacji " + singleEmailSetting[0]);
      populatedList
          .add(new NotificationItem(singleEmailSetting[0], true, "n/d"));
    }
    return populatedList;
  }

  Future<void> javaMethod(MethodCall call) async {
    switch (call.method) {
      case 'syncCompleted':
        print("Długość listy notifications w syncCompleted" +
            notificationItems.length.toString());
        for (NotificationItem notificationItem in notificationItems) {
          if (call.arguments.toString().contains(notificationItem.userEmail)) {
            setState(() {
              notificationItem.isProgressVisible = false;
            });
          }
        }
        break;

      case 'syncStarted':
        print("Długość listy notifications w syncStarted" +
            notificationItems.length.toString());
        List<String> parts = call.arguments.toString().split(" ");

        print("Call przed forem " + call.arguments);

        for (NotificationItem notificationItem in notificationItems) {
          print("Call " +
              call.arguments +
              " email w widgecie " +
              notificationItem.userEmail);

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
}
