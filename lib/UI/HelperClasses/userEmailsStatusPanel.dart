import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_payit/Objects/notificationItem.dart';

class UserEmailsStatusPanel extends StatefulWidget {
  List<List<dynamic>> emailSettings;
  Animation _animationForEmails;
  @override
  _UserEmailsPanelStatus createState() => _UserEmailsPanelStatus();
  UserEmailsStatusPanel(this.emailSettings, this._animationForEmails);
}

class _UserEmailsPanelStatus extends State<UserEmailsStatusPanel> {
  static const methodChannel = const MethodChannel("com.example.flutter_payit");
  List<NotificationItem> notificationItems = new List();

  @override
  void initState() {
    notificationItems = populateNotificationItemsList(widget.emailSettings);
    methodChannel.setMethodCallHandler(javaMethod);
  }

  @override
  Widget build(BuildContext context) {
    print("Długość listy notifications w build panelu z mailami" + notificationItems.length.toString());
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
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
                  widget._animationForEmails.value +
              10,
          color: Colors.blue,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: List.generate(
                notificationItems.length, (index) => notificationItems[index].notificationItem()),
          ),
        ),
      ],
    );
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

  Future<void> javaMethod(MethodCall call) async {
    switch (call.method) {
      case 'syncCompleted':
        print("Długość listy notifications w syncCompleted" + notificationItems.length.toString());
        for (NotificationItem notificationItem in notificationItems) {
          if (call.arguments
              .toString()
              .contains(notificationItem.userEmail)) {
            setState(() {
              notificationItem.isProgressVisible = false;
            });
          }
        }
        break;

      case 'syncStarted':
        print("Długość listy notifications w syncStarted" + notificationItems.length.toString());
        List<String> parts = call.arguments.toString().split(" ");

        print("Call przed forem " + call.arguments);

        for (NotificationItem notificationItem in notificationItems) {

          print("Call " + call.arguments + " email w widgecie "+notificationItem.userEmail);

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
