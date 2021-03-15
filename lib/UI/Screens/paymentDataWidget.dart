
import 'package:flutter/material.dart';
import 'package:flutter_payit/UI/HelperClasses/dialog.dart';
import 'package:flutter_payit/UI/Screens/pdfView.dart';
import 'package:flutter_payit/Objects/invoice.dart';
import 'package:fluttertoast/fluttertoast.dart';

class PaymentWidget {
  static Padding paymentCard(List<Invoice> invoices, Invoice invoice, Color color, BuildContext context) {

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
                  child: FittedBox(
                    fit:BoxFit.scaleDown,
                    child: Text(
                      invoice.categoryName,
                      style: TextStyle(
                        fontSize: 35,
                        color: color,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    "Od nadawcy:",
                    style: TextStyle(fontSize: 25, color: color),
                  ),
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
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    invoice.paymentAmount.toString() + " PLN",
                    style: TextStyle(fontSize: 25, color: color),
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    'Termin zapłaty: ',
                    style: TextStyle(fontSize: 15, color: color),
                  ),
                ),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    invoice.paymentDate,
                    style: TextStyle(fontSize: 20, color: color),
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
                Row(children: [
                  Expanded(
                    child: RaisedButton(
                      color: Colors.white,
                      onPressed: () {
                        if(invoice.accountForTransfer == "00000000000000000000000000"){
                          Fluttertoast.showToast(msg: "Nie udało się pobrać numeru konta do przelewu, musisz zmienić je ręcznie w podglądzie ");
                        }else{
                          //showDialog(context: context,
//                              builder: (BuildContext context){
//                                return MyDialog(
//                                  title: "Uwaga",
//                                  descriptions: "Za chwilę zostaniesz przekierowany do formularza płatsości GooglePay, kontynuować?",
//                                  img: "warning.PNG",
//                                  text: 'Przejdź do płatności',
//                                );
//                              }

                         // );
                        Fluttertoast.showToast(msg: "Płatność będzie wkrótce dodana");

                        }
                      },
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
                        MaterialPageRoute(builder: (context) => PdfView(invoices, invoice)),
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


