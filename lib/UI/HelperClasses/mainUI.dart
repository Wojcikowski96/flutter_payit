import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_payit/UI/HelperClasses/uiElements.dart';
import 'file:///C:/Users/wojci/AndroidStudioProjects/flutter_payit/lib/UI/Screens/ConfigScreens/emailBoxesPanel.dart';
import 'package:flutter_payit/UI/Screens/ConfigScreens/trustedList.dart';

class MainUI{

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
                      style: TextStyle(fontSize: 45, color: Colors.blue),
                    )),
                SizedBox(
                  height: 25,
                ),
                UiElements().drawButton(200, 80, "Przejdź do ustawień", Colors.white, Colors.blue, Colors.blue, context,
                    EmailBoxesPanel(), null, null),
                SizedBox(
                  height: 10,
                ),
              ],
            )));
  }

  Scaffold homeScreenLayout(PageController pageController, BuildContext context,
       GlobalKey<ScaffoldState> scaffoldKey, bool isCalendarViewEnnabled, Column calendarView, AppBar homePageAppBar, List<String> urgencyNames, List<Color> colors, List<List<Widget>> invoicesTilesForConsolided, MethodChannel methodChannel, String username,  DropdownButton<String> selectEmailAddress) {
    return Scaffold(
        key: scaffoldKey,
        body: isCalendarViewEnnabled
            ? calendarView
            : UiElements().consolidedInvoicesView(urgencyNames, colors, invoicesTilesForConsolided),
        appBar: homePageAppBar,
        drawer: UiElements().homePageDrawerMenu(context, methodChannel, username, selectEmailAddress));
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
                      style: TextStyle(fontSize: 45, color: Colors.blue),
                    )),
                SizedBox(
                  height: 25,
                ),
                UiElements().drawButton(200, 80, "Edytuj zaufanych nadawców", Colors.white, Colors.blue, Colors.blue, context,
                    TrustedListPanel(), null, null),
                SizedBox(
                  height: 10,
                ),
              ],
            )));
  }



}