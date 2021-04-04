import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_payit/Objects/invoice.dart';
import 'package:flutter_payit/UI/Screens/homePage.dart';
import 'package:flutter_payit/UI/Screens/paymentDataWidget.dart';


class ConsolidedView extends StatelessWidget {
  List<String> urgencyNames = ["Pilne", "Średnio pilne", "Mało pilne", "Niezdefiniowane"];
  List <Color> colors = [Colors.red, Colors.amber, Colors.green, Colors.grey];
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      backgroundColor: Colors.grey,
//      appBar: new AppBar(
//        title: new Text("PayIT",style: TextStyle(color: Colors.white, fontSize: 25)),
//        backgroundColor: Colors.blue,
//        actions: <Widget>[
//          IconButton(
//            icon: Icon(
//              Icons.calendar_today,
//              color: Colors.white,
//            ),
//            onPressed: () {
//              Navigator.push(
//                context,
//                MaterialPageRoute(builder: (context) => homePage(DateTime.now(),new List(), true)),
//              );
//            },
//          )
//        ],
//      ),
      body: new ListView.builder(
        itemBuilder: (BuildContext context, int index) {
          return new ExpandableListViewItem(title: urgencyNames[index], color: colors[index]);
        },
        itemCount: 4,
      ),
    );
  }
}

class ExpandableListViewItem extends StatefulWidget {
  final String title;
  final Color color;
  final List<Widget> invoices;

  const ExpandableListViewItem({Key key, this.title, this.color, this.invoices}) : super(key: key);

  @override
  _ExpandableListViewItemState createState() => new _ExpandableListViewItemState();
}

class _ExpandableListViewItemState extends State<ExpandableListViewItem> {
  bool expandFlag = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

  }

  @override
  Widget build(BuildContext context) {
    return new Container(
      margin: new EdgeInsets.symmetric(vertical: 1.0),
      child: new Column(
        children: <Widget>[
          new Container(
            color: widget.color,
            padding: new EdgeInsets.symmetric(horizontal: 5.0),
            child: new Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                new IconButton(
                    icon: new Container(
                      height: 50.0,
                      width: 50.0,
                      decoration: new BoxDecoration(
                        color:widget.color,
                        shape: BoxShape.circle,
                      ),
                      child: new Center(
                        child: new Icon(
                          expandFlag ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                          color: Colors.white,
                          size: 30.0,
                        ),
                      ),
                    ),
                    onPressed: () {
                      setState(() {
                        expandFlag = !expandFlag;
                      });
                    }),
                new Text(
                  widget.title,
                  style: new TextStyle(color: Colors.white,fontSize: 30),
                ),
                Container(color: Colors.white,child: Text((widget.invoices.length).toString(), style: TextStyle(color: widget.color, fontSize: 25),))
              ],
            ),
          ),
          new ExpandableContainer(
              expanded: expandFlag,
              collapsedHeight: widget.invoices.length == 0 ? 0.0 : 100.0 ,
              expandedHeight: widget.invoices.length == 0 ? 0 : 300.0,
              color: widget.color,
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: ListView(
                  children:
                  List.generate(widget.invoices.length, (index2) => widget.invoices[index2]),
                ),
              ),)
        ],
      ),
    );
  }
}

class ExpandableContainer extends StatelessWidget {
  final bool expanded;
  double collapsedHeight;
  double expandedHeight;
  final Widget child;
  final Color color;

  ExpandableContainer({
    @required this.child,
    this.collapsedHeight = 100.0,
    this.expandedHeight = 300.0,
    this.expanded = true,
    this.color
  });


  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return new AnimatedContainer(
      duration: new Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      width: screenWidth,
      height: expanded ? expandedHeight : collapsedHeight,
      child: new Container(
        child: child,
        color: color,
      ),
    );
  }
}