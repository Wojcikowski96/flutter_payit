import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class NotificationItem {
  String userEmail;
  bool isProgressVisible = true;
  String progressPercentage;

  NotificationItem(
      String userEmail, bool isProgressVisible, String progressPercentage) {
    this.userEmail = userEmail;
    this.isProgressVisible = isProgressVisible;
    this.progressPercentage = progressPercentage;
  }

  Padding notificationItem() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
            border: Border.all(
              color: Colors.white60,
              width: 0.1,
            ),
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(15))),
        width: 200,
        height: 80,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    flex: 5,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        userEmail,
                        style: TextStyle(fontSize: 25, color: Colors.blue),
                      ),
                    ),
                  ),
                  Visibility(
                    visible: isProgressVisible,
                    child: Expanded(
                      flex: 2,
                      child: Padding(
                        padding: EdgeInsets.all(5),
                        child: Stack(
                          children: [
                            CircularProgressIndicator(),
                            Positioned(
                                child: Padding(
                                  padding: EdgeInsets.all(2),
                                  child: Text(
                                    progressPercentage,
                                    style: TextStyle(color: Colors.blue),
                                  ),
                                ),
                                top: 8,
                            left: 3,)
                          ],
                        ),
                      ),
                    ),
                  ),
                  Visibility(
                    visible: !isProgressVisible,
                    child: Expanded(
                      flex: 4,
                      child: Icon(
                        Icons.done,
                        color: Colors.green,
                        size: 30,
                      ),
                    ),
                  ),
                ],
              ),
              Visibility(
                visible: !isProgressVisible,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text("Pobrano załączniki",
                        style: TextStyle(color: Colors.green))
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
