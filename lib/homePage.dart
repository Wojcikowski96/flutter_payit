import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_payit/registerPage.dart';
import 'package:flutter_payit/trustedList.dart';
import 'package:flutter_payit/urgentPay.dart';

import 'emailBoxesPanel.dart';
import 'mediumUrgentPay.dart';
import 'notUrgentPay.dart';

class homePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    PageController pageController = PageController(initialPage: 0);

    return Scaffold(
      backgroundColor: Colors.blue,
      body: PageView(
        controller: pageController,
        children: [
          urgentPay(pageController: pageController),
          mediumUrgentPay(pageController: pageController),
          notUrgentPay(pageController: pageController),
        ],
      ),
      drawer: Drawer(
        // Add a ListView to the drawer. This ensures the user can scroll
        // through the options in the drawer if there isn't enough vertical
        // space to fit everything.
        child: ListView(
          // Important: Remove any padding from the ListView.
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              child: Text('Username'),
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
            ),
            ListTile(
              title: Text('Zarządzaj adresami e-mail'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => EmailBoxesPanel()),
                );
              },
            ),

            ListTile(
              title: Text('Edytuj zaufaną listę nadawców faktur'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => TrustedListPanel()),
                );
              },
            ),

            ListTile(
              title: Text('Ustawienia'),
              onTap: () {
                // Update the state of the app
                // ...
                // Then close the drawer
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text('O aplikacji'),
              onTap: () {
                // Update the state of the app
                // ...
                // Then close the drawer
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      appBar: AppBar(
          // leading: IconButton(icon: Icon(Icons.menu), onPressed: (){
          //
          // }),
          title: Text("PayIT"),
          actions: <Widget>[
            IconButton(
                icon: Icon(Icons.people),
                onPressed: () {
                  Scaffold.of(context).showSnackBar(
                      new SnackBar(content: Text('Yay! A SnackBar!')));
                })
          ]),
    );
  }
}
