
import 'package:flutter/material.dart';
import 'package:flutter_payit/UI/Screens/pdfView.dart';
import 'package:flutter_payit/Objects/invoice.dart';

class PaymentWidget {
  static Padding paymentCard(Invoice invoice, Color color, BuildContext context) {

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
                    invoice.categoryName,
                    style: TextStyle(
                      fontSize: 35,
                      color: color,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
                Text(
                  "Od nadawcy:",
                  style: TextStyle(fontSize: 25, color: color),
                ),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    invoice.senderMail,
                    style: TextStyle(fontSize: 20, color: color),
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
                Text(
                  invoice.paymentAmount.toString() + " PLN",
                  style: TextStyle(fontSize: 25, color: color),
                ),
                SizedBox(
                  height: 5,
                ),
                Text(
                  'Termin zapłaty: ',
                  style: TextStyle(fontSize: 15, color: color),
                ),
                Text(
                  invoice.paymentDate,
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
                        MaterialPageRoute(builder: (context) => PdfView(invoice)),
                      );
                    },
                    child: Center(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          'Podgląd i edycja',
                          maxLines: 1,
                          style: TextStyle(color: color,),
                        ),
                      ),
                    ),
                  ))
                ])
              ],
            ),
          ),
        ));
  }

}


