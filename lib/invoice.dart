import 'dart:ui';

class Invoice {
  String categoryName, userMail, senderMail, downloadPath, paymentDate;
  double paymentAmount;
  int accountForTransfer;
  Color color;

  bool isTrusted;
  Invoice(this.categoryName, this.userMail, this.senderMail, this.paymentAmount, this.paymentDate,
      this.accountForTransfer, this.isTrusted, this.downloadPath, this.color);

  @override
  String toString() {
    // TODO: implement toString
    print("Invoice");

    return "Nazwa kategorii: " +
        categoryName +
        " Mail usera: " +
        userMail +
        " Mail nadawcy: " +
        senderMail +
        " downloadPath : " +
        downloadPath.toString() +
        " paymentDate " +
        paymentDate +
        " paymentAmount " +
        paymentAmount.toString() +
        " accountForTransfer: " +
        accountForTransfer.toString() +
        "Kolor: " +
        color.toString() +
        '\n';
  }
}
