
import 'package:flutter_payit/Objects/invoice.dart';
import 'package:flutter_payit/Utils/utils.dart';

class CalendarUtils{
  Map<DateTime, List> generatePaymentEvents(List<Invoice> invoicesInfo, List<int> preferences) {
    Map<DateTime, List> paymentEvents = new Map();

    for (Invoice singleInvoiceInfo in invoicesInfo) {

      DateTime date = DateTime.parse(singleInvoiceInfo.paymentDate);

      String paymentEventValue = 'Opłata dla|' +
          singleInvoiceInfo.categoryName.toString() +
          "|" +
          singleInvoiceInfo.paymentAmount.toString() +
          "|" +
          singleInvoiceInfo.downloadPath.toString() +
          "|" +
          Utils().setUrgencyColorBasedOnDate(date, preferences).toString() +
          "|" +
          singleInvoiceInfo.accountForTransfer.toString() +
          "|" +
          singleInvoiceInfo.userMail.toString() +
          "|" +
          singleInvoiceInfo.senderMail.toString();

      if (paymentEvents.containsKey(date)) {
        paymentEvents[date].add(paymentEventValue);
      } else {
        paymentEvents[date] = [paymentEventValue];
      }
    }

    return paymentEvents;
  }
}