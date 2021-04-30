import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:payit/Objects/warningNotification.dart';
import 'package:payit/UI/Screens/ConfigScreens/emailBoxesPanel.dart';
import 'package:payit/UI/Screens/ConfigScreens/trustedList.dart';

class FrostedContainer extends StatefulWidget {
  BuildContext context;
  List<WarningNotification> warnings;
  bool isThisVisible;
  bool isTrustedEmailsEmpty;
  bool isUserEmailsEmpty;

  FrostedContainer(this.context, this.warnings, this.isThisVisible,
      this.isTrustedEmailsEmpty, this.isUserEmailsEmpty);
  @override
  _FrostedContainerState createState() => _FrostedContainerState();
}

class _FrostedContainerState extends State<FrostedContainer> {
  @override
  void initState() {
    super.initState();
//      if(widget.isTrustedEmailsEmpty){
//        setState(() {
//          widget.warnings.add(new WarningNotification(
//              "Brak zaufanych adresów", TrustedListPanel()));
//        });
//      }
//      if(widget.isUserEmailsEmpty){
//        setState(() {
//          widget.warnings.add(new WarningNotification("Brak skrzynek e-mail", EmailBoxesPanel()));
//        });
//      }

  }
  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: widget.isThisVisible,
      child: ClipRect(
        // <-- clips to the 200x200 [Container] below
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: 4.0,
              sigmaY: 4.0,
            ),
            child: Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.25),
                border: Border.all(
                    color: Colors.grey.shade100.withOpacity(1), width: 3),
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
              width: MediaQuery.of(context).size.width / 1.3,
              height: MediaQuery.of(context).size.height / 2.2,
              child: Column(
                children: [
                  Expanded(
                      flex: 1,
                      child: Container(
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.25),
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                          ),
                          width: MediaQuery.of(context).size.width / 1.3,
                          child: Center(
                              child: Text(
                                "Ostrzeżenia",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 40,
                                    fontWeight: FontWeight.bold),
                              )))),
                  Visibility(
                    visible: widget.warnings.length != 0 ? true : false,
                    child: Expanded(
                      flex: 5,
                      child: Container(
                        alignment: Alignment.topCenter,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ListView(
                            children: List.generate(
                                widget.warnings.length, (index2) => widget.warnings[index2]),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Visibility(
                      visible: widget.warnings.length == 0 ? true : false,
                      child: Expanded(
                          flex: 5,
                          child: Center(
                            child: Text(
                              "<Nic do pokazania>",
                              style: TextStyle(color: Colors.grey, fontSize: 16),
                            ),
                          ))),
                ],
              ),
            ),
          )),
    );

  }
}
