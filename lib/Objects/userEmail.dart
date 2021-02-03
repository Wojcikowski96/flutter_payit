class UserEmail {
  String emailAddress;
  String password;
  String hostName;
  String port;
  String protocol;
  int lastUID;
  String emailKey;

  UserEmail(this.emailAddress, this.password, this.hostName, this.port,
      this.protocol, this.lastUID, this.emailKey);

  @override
  String toString() {
    // TODO: implement toString
    print("emaillAddress");
    print(emailAddress);
    return "Email usera: " +
        emailAddress.toString() +
        " Hasło do skrzynki: " +
        password.toString() +
        " Nazwa hosta: " +
        hostName.toString() +
        " Numer portu : " +
        port.toString() +
        " Protokół: " +
        protocol.toString() +
        " Zapamiętany UID: " +
        lastUID.toString() +
        " Klucz maila: " +
        emailKey +
        '\n';
  }
}
