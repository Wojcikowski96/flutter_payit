import 'dart:ui';

class Invoice {
  String categoryName, userMail, senderMail, downloadPath, paymentDate, accountForTransfer;
  double paymentAmount;
  Color color;

  bool isDefined;
  Invoice(this.categoryName, this.userMail, this.senderMail, this.paymentAmount, this.paymentDate,
      this.accountForTransfer, this.isDefined, this.downloadPath, this.color);

  @override
  String toString() {
    // TODO: implement toString

    return "Nazwa kategorii: " +
        categoryName.toString() +
        " Mail usera: " +
        userMail.toString() +
        " Mail nadawcy: " +
        senderMail.toString() +
        " downloadPath : " +
        downloadPath.toString() +
        " paymentDate " +
        paymentDate.toString() +
        " paymentAmount " +
        paymentAmount.toString() +
        " accountForTransfer: " +
        accountForTransfer.toString() +
        "Kolor: " +
        color.toString() +
        '\n';
  }
}
