import 'package:flutter/material.dart';

class PaymentWidget  {

    static Padding paymentCard(String name, String amount, String date){

      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(

              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Text(
                      name,
                      style: TextStyle(fontSize: 45),
                    ),
                    SizedBox(height: 5,),
                    Text(
                      amount,
                      style: TextStyle(
                          fontSize: 35
                      ),
                    ),
                    SizedBox(height:5,),
                    Text('Termin zapłaty: ',
                      style: TextStyle(
                          fontSize: 25
                      ),
                    ),
                    Text(date,
                      style: TextStyle(
                          fontSize: 20
                      ),
                    ),
                    SizedBox(height: 5,),
                    Row(children: [
                      Expanded(
                        child: RaisedButton(
                          onPressed: () {},
                          child: Text('Płacę'),
                        ),
                      ),
                      SizedBox(width: 10,),
                      Expanded(
                          child: RaisedButton(
                            onPressed: () {},
                            child: Text('Podgląd faktury'),
                          ))
                    ])
                  ],
                ),
              ),
              color: Colors.white,
            ),
      );

    }
  }

