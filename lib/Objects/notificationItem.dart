import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NotificationItem extends StatefulWidget{
  String userEmail;
  bool isProgressVisible;
  String progressPercentage;

  NotificationItem(
  this.userEmail,
  this.isProgressVisible,
  this.progressPercentage);

  @override
  _NotificationItemState createState() => _NotificationItemState();

}

class _NotificationItemState extends State<NotificationItem>{
  static const methodChannel = const MethodChannel("com.example.flutter_payit");
  @override
  void initState() {
    methodChannel.setMethodCallHandler(javaMethod);
  }

  @override
  Widget build(BuildContext context) {
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
                        widget.userEmail,
                        style: TextStyle(fontSize: 25, color: Colors.blue),
                      ),
                    ),
                  ),
                  Visibility(
                    visible: widget.isProgressVisible,
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
                                  widget.progressPercentage,
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
                    visible: !widget.isProgressVisible,
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
                visible: !widget.isProgressVisible,
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
  Future<void> javaMethod(MethodCall call) async {
    switch (call.method) {
      case 'syncCompleted':
        print("syncCompleted " + call.arguments.toString());

          if (call.arguments.toString().contains(widget.userEmail)) {
            setState(() {
            widget.isProgressVisible = false;
          });
          }
        break;
      case 'syncStarted':
        print("syncStarted " + call.arguments.toString());
        List<String> parts = call.arguments.toString().split(" ");

          if (call.arguments.toString().contains(widget.userEmail)) {
            setState(() {
            widget.isProgressVisible = true;
            widget.progressPercentage = parts[2];
            });
          }


        break;
    }
  }
}
