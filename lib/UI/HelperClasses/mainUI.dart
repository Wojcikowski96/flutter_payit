import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_payit/Objects/warningNotification.dart';
import 'package:flutter_payit/UI/HelperClasses/uiElements.dart';
import 'file:///C:/Users/wojci/AndroidStudioProjects/flutter_payit/lib/UI/Screens/ConfigScreens/emailBoxesPanel.dart';
import 'package:flutter_payit/UI/Screens/ConfigScreens/trustedList.dart';
import 'package:shimmer/shimmer.dart';

class MainUI {
  Scaffold warningHomePage(BuildContext context) {
    return Scaffold(
        body: Container(
            child: Column(
      children: [
        SizedBox(
          height: 50,
        ),
        SizedBox(height: 150, child: Image.asset("warning.PNG")),
        SizedBox(
          height: 25,
        ),
        Center(
            child: Text(
          "Nie masz zdefiniowanych żadnych własnych skrzynek e-mail!",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 45, color: Colors.white),
        )),
        SizedBox(
          height: 25,
        ),
        UiElements().drawButton(200, 80, "Przejdź do ustawień", Colors.white,
            Colors.blue, Colors.blue, context, EmailBoxesPanel(), null, null),
        SizedBox(
          height: 10,
        ),
      ],
    )));
  }

  Scaffold homeScreenLayout(
      PageController pageController,
      BuildContext context,
      GlobalKey<ScaffoldState> scaffoldKey,
      bool isCalendarViewEnnabled,
      Column calendarView,
      AppBar homePageAppBar,
      List<String> urgencyNames,
      List<Color> colors,
      List<List<Widget>> invoicesTilesForConsolided,
      MethodChannel methodChannel,
      String username,
      DropdownButton<String> selectEmailAddress,
      bool isNotificationsClicked,
      List<WarningNotification> warnings) {
    return Scaffold(
        key: scaffoldKey,
        body: isCalendarViewEnnabled
            ? Stack(
                alignment: Alignment.topRight,
                children: [
                  calendarView,
                  AnimatedOpacity(
                      opacity: isNotificationsClicked ? 1.0 : 0.0 ,
                      duration: Duration(milliseconds: 500),
                      child: UiElements()
                          .showNotificationsFrostedContainer(context, warnings, isNotificationsClicked))
                ],
              )
            : UiElements().consolidedInvoicesView(
                urgencyNames, colors, invoicesTilesForConsolided),
        appBar: homePageAppBar,
        drawer: UiElements().homePageDrawerMenu(
            context, methodChannel, username, selectEmailAddress));
  }

  Scaffold warningHomePageForTrustedEmpty(BuildContext context) {
    return Scaffold(
        body: Container(
            child: Column(
      children: [
        SizedBox(
          height: 50,
        ),
        SizedBox(height: 150, child: Image.asset("warning.PNG")),
        SizedBox(
          height: 25,
        ),
        Center(
            child: Text(
          "Nie masz zdefiniowanych żadnych nadawców faktur!",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 45, color: Colors.black),
        )),
        SizedBox(
          height: 25,
        ),
        UiElements().drawButton(
            200,
            80,
            "Edytuj zaufanych nadawców",
            Colors.white,
            Colors.blue,
            Colors.blue,
            context,
            TrustedListPanel(),
            null,
            null),
        SizedBox(
          height: 10,
        ),
      ],
    )));
  }

  Scaffold placeholderCalendarView() {
    return Scaffold(
      body: Shimmer.fromColors(
          baseColor: Colors.grey[200],
          highlightColor: Colors.grey[350],
          child: Column(
            children: [
              SizedBox(height: 50),
              Row(
                children: [
                  Expanded(
                      flex: 4,
                      child: Text(
                        "adsf",
                        maxLines: 1,
                        style: TextStyle(backgroundColor: Colors.white),
                      )),
                  Expanded(
                      flex: 4,
                      child: Text(
                        "aasdasdasfggfhfghfgh",
                        maxLines: 1,
                        style: TextStyle(backgroundColor: Colors.white),
                      )),
                  Expanded(
                      flex: 4,
                      child: Align(
                          alignment: Alignment.topRight,
                          child: Text(
                            "ads",
                            maxLines: 1,
                            style: TextStyle(backgroundColor: Colors.white),
                          ))),
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  Expanded(
                      flex: 4,
                      child: Text(
                        "ads",
                        maxLines: 1,
                        style: TextStyle(backgroundColor: Colors.white),
                      )),
                  Expanded(
                      flex: 4,
                      child: Text(
                        "aas",
                        maxLines: 1,
                        style: TextStyle(backgroundColor: Colors.white),
                      )),
                  Expanded(
                      flex: 4,
                      child: Text(
                        "ads",
                        maxLines: 1,
                        style: TextStyle(backgroundColor: Colors.white),
                      )),
                  Expanded(
                      flex: 4,
                      child: Text(
                        "aas",
                        maxLines: 1,
                        style: TextStyle(backgroundColor: Colors.white),
                      )),
                  Expanded(
                      flex: 4,
                      child: Text(
                        "ads",
                        maxLines: 1,
                        style: TextStyle(backgroundColor: Colors.white),
                      )),
                  Expanded(
                      flex: 4,
                      child: Text(
                        "ads",
                        maxLines: 1,
                        style: TextStyle(backgroundColor: Colors.white),
                      )),
                  Expanded(
                      flex: 4,
                      child: Text(
                        "aas",
                        maxLines: 1,
                        style: TextStyle(backgroundColor: Colors.white),
                      )),
                  Expanded(
                      flex: 4,
                      child: Text(
                        "ads",
                        maxLines: 1,
                        style: TextStyle(backgroundColor: Colors.white),
                      ))
                ],
              ),
              SizedBox(height: 10),
              Align(
                alignment: Alignment.center,
                child: Text("aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
                    maxLines: 1,
                    style:
                        TextStyle(backgroundColor: Colors.white, fontSize: 20)),
              ),
              SizedBox(
                height: 8,
              ),
              Align(
                alignment: Alignment.center,
                child: Text("aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
                    maxLines: 1,
                    style:
                        TextStyle(backgroundColor: Colors.white, fontSize: 20)),
              ),
              SizedBox(
                height: 8,
              ),
              Align(
                alignment: Alignment.center,
                child: Text("aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
                    maxLines: 1,
                    style:
                        TextStyle(backgroundColor: Colors.white, fontSize: 20)),
              ),
              SizedBox(
                height: 8,
              ),
              Align(
                alignment: Alignment.center,
                child: Text("aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
                    maxLines: 1,
                    style:
                        TextStyle(backgroundColor: Colors.white, fontSize: 20)),
              ),
              SizedBox(
                height: 8,
              ),
              Align(
                alignment: Alignment.center,
                child: Text("aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
                    maxLines: 1,
                    style:
                        TextStyle(backgroundColor: Colors.white, fontSize: 20)),
              ),
              SizedBox(
                height: 8,
              ),
              Align(
                alignment: Alignment.center,
                child: Text("aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
                    maxLines: 1,
                    style:
                        TextStyle(backgroundColor: Colors.white, fontSize: 20)),
              ),
              SizedBox(
                height: 8,
              ),
              Align(
                alignment: Alignment.center,
                child: Text("aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
                    maxLines: 1,
                    style:
                        TextStyle(backgroundColor: Colors.white, fontSize: 20)),
              ),
              SizedBox(
                height: 8,
              ),
              Align(
                alignment: Alignment.center,
                child: Text("aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
                    maxLines: 1,
                    style:
                        TextStyle(backgroundColor: Colors.white, fontSize: 20)),
              ),
              SizedBox(
                height: 8,
              ),
              Align(
                alignment: Alignment.center,
                child: Text("aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
                    maxLines: 1,
                    style:
                        TextStyle(backgroundColor: Colors.white, fontSize: 20)),
              ),
              SizedBox(
                height: 8,
              ),
              Align(
                alignment: Alignment.center,
                child: Text("aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
                    maxLines: 1,
                    style:
                        TextStyle(backgroundColor: Colors.white, fontSize: 20)),
              ),
              SizedBox(
                height: 8,
              ),
              Align(
                alignment: Alignment.center,
                child: Text("aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
                    maxLines: 1,
                    style:
                        TextStyle(backgroundColor: Colors.white, fontSize: 20)),
              ),
              SizedBox(
                height: 8,
              ),
              Align(
                alignment: Alignment.center,
                child: Text("aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
                    maxLines: 1,
                    style:
                        TextStyle(backgroundColor: Colors.white, fontSize: 20)),
              ),
              SizedBox(height: 2),
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Column(
                      children: [
                        Align(
                          alignment: Alignment.center,
                          child: Text("aaaaaaaa",
                              maxLines: 1,
                              style: TextStyle(
                                  backgroundColor: Colors.white, fontSize: 20)),
                        ),
                        SizedBox(
                          height: 30,
                        ),
                        Align(
                          alignment: Alignment.center,
                          child: Text("aaaaaaaaaaaaaaaaaaaaaaaaaa",
                              maxLines: 1,
                              style: TextStyle(
                                  backgroundColor: Colors.white, fontSize: 20)),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Align(
                          alignment: Alignment.center,
                          child: Text("aaaaaaaaaaaaaaaaaaaaaaaaaa",
                              maxLines: 1,
                              style: TextStyle(
                                  backgroundColor: Colors.white, fontSize: 20)),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Align(
                          alignment: Alignment.center,
                          child: Text("aaaaaaaaaaaaaaaaaaaaaaaaaa",
                              maxLines: 1,
                              style: TextStyle(
                                  backgroundColor: Colors.white, fontSize: 20)),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Column(
                      children: [
                        Align(
                          alignment: Alignment.center,
                          child: Text("aaaa",
                              maxLines: 1,
                              style: TextStyle(
                                  backgroundColor: Colors.white, fontSize: 20)),
                        ),
                        SizedBox(
                          height: 30,
                        ),
                        Align(
                          alignment: Alignment.center,
                          child: Text("aaaaaaaaaaaaaaaaaaaaaaaaaa",
                              maxLines: 1,
                              style: TextStyle(
                                  backgroundColor: Colors.white, fontSize: 20)),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Align(
                          alignment: Alignment.center,
                          child: Text("aaaaaaaaaaaaaaaaaaaaaaaaaa",
                              maxLines: 1,
                              style: TextStyle(
                                  backgroundColor: Colors.white, fontSize: 20)),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Align(
                          alignment: Alignment.center,
                          child: Text("aaaaaaaaaaaaaaaaaaaaaaaaaa",
                              maxLines: 1,
                              style: TextStyle(
                                  backgroundColor: Colors.white, fontSize: 20)),
                        ),
                      ],
                    ),
                  )
                ],
              ),
              Column(
                children: [
                  SizedBox(
                    height: 10,
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: Text("aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
                        maxLines: 1,
                        style: TextStyle(
                            backgroundColor: Colors.white, fontSize: 20)),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: Text("aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
                        maxLines: 1,
                        style: TextStyle(
                            backgroundColor: Colors.white, fontSize: 20)),
                  ),
                ],
              )
            ],
          )),
    );
  }
}
