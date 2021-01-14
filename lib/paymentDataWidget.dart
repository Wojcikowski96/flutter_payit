
import 'package:flutter/material.dart';
import 'package:flutter_payit/pdfView.dart';

class PaymentWidget {
  static Padding paymentCard(
      String name, String amount, String date, String path, Color color, BuildContext context) {

    return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          decoration: BoxDecoration(
              border: Border.all(
                color: color,
                width: 4,
              ),
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(20))),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Center(
                  child: Text(
                    name,
                    style: TextStyle(
                      fontSize: 45,
                      color: color,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
                Text(
                  amount + " PLN",
                  style: TextStyle(fontSize: 35, color: color),
                ),
                SizedBox(
                  height: 5,
                ),
                Text(
                  'Termin zapłaty: ',
                  style: TextStyle(fontSize: 25, color: color),
                ),
                Text(
                  date,
                  style: TextStyle(fontSize: 20, color: color),
                ),
                SizedBox(
                  height: 5,
                ),
                Row(children: [
                  Expanded(
                    child: RaisedButton(
                      color: Colors.white,
                      onPressed: () {},
                      child: Text(
                        'Płacę',
                        style: TextStyle(color: color),
                      ),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18.0),
                          side: BorderSide(color: color)),
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Expanded(
                      child: RaisedButton(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.0),
                        side: BorderSide(color: color)),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => PdfView(path)),
                      );
                    },
                    child: Text(
                      'Podgląd faktury',
                      style: TextStyle(color: color),
                    ),
                  ))
                ])
              ],
            ),
          ),
        ));
  }

  static Padding paymentCardWarning(String name, String path, Color color, BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          decoration: BoxDecoration(
              border: Border.all(
                color: color,
                width: 4,
              ),
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(20))),
          child: Column(
            children: [
              Center(
                child: Text(
                  name,
                  style: TextStyle(
                    fontSize: 45,
                    color: color,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(
                height: 5,
              ),
              Text(
                "Nie udało się pobrać prawidłowych danych z faktury",
                style: TextStyle(
                  fontSize: 35,
                  color: color,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(
                width: 10,
              ),
              RaisedButton(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18.0),
                    side: BorderSide(color: color)),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => PdfView(path)),
                  );
                },
                child: Text(
                  'Podgląd faktury',
                  style: TextStyle(color: color),
                ),
              )
            ],
          ),
        ));
  }

  static Widget invokePdfView(String path) {
    return PdfView(path);
  }
}
