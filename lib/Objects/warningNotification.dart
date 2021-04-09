import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class WarningNotification extends StatelessWidget{
  String message;
  Widget route;
  WarningNotification(this.message, this.route);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(3.0),
      child: Container(
        child: Row(children: [
          Expanded(child: SizedBox(height: 70, child: Image.asset("warning.PNG"))),
          Expanded(child: Text(message, style: TextStyle(fontSize: 20, color: Colors.red.withOpacity(1)),),),
          Expanded(
            child: Container(
              color: Colors.red,
              alignment: Alignment.center,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text("Przejdź do ustawień", style: TextStyle(color: Colors.white),),
                    IconButton(
                        icon: Icon(
                          Icons.arrow_forward,
                          color: Colors.white,
                          size: 40,
                        ),
                      onPressed: (){
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => route),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
        ),
        decoration: BoxDecoration(
          color: Colors.red.shade100.withOpacity(0.5),
          borderRadius:  BorderRadius.all(Radius.circular(20)),
          border: Border.all(
            color: Colors.white.withOpacity(0.5)
          )
        ),
      ),
    );
  }
}