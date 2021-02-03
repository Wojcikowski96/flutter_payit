import 'package:flutter_payit/utils.dart';

import 'invoice.dart';

class CalendarUtils{
  Map<DateTime, List> generatePaymentEvents(List<Invoice> invoicesInfo, List<int> preferences) {
    Map<DateTime, List> paymentEvents = new Map();

    for (Invoice singleInvoiceInfo in invoicesInfo) {

      print(singleInvoiceInfo.toString());
      DateTime date = DateTime.parse(singleInvoiceInfo.paymentDate);

      String paymentEventValue = 'Opłata dla|' +
          singleInvoiceInfo.categoryName +
          "|" +
          singleInvoiceInfo.paymentAmount.toString() +
          "|" +
          singleInvoiceInfo.downloadPath.toString() +
          "|" +
          Utils().setUrgencyColorBasedOnDate(date, preferences).toString() +
          "|" +
          singleInvoiceInfo.accountForTransfer.toString() +
          "|" +
          singleInvoiceInfo.userMail +
          "|" +
          singleInvoiceInfo.senderMail;

      if (paymentEvents.containsKey(date)) {
        paymentEvents[date].add(paymentEventValue);
      } else {
        paymentEvents[date] = [paymentEventValue];
      }
    }

    print("Mapa " + paymentEvents.toString());
    return paymentEvents;
  }
}