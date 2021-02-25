class Downloader{
  Future<void> downloadAttachment(List<dynamic> args) async {
    //WidgetsFlutterBinding.ensureInitialized();
    await args[3].invokeMethod("downloadAttachment", {
      "emailAddress": args[0][0],
      "password": args[0][1],
      "host": args[0][2],
      "port": args[0][3],
      "protocol": args[0][4],
      "newUID": args[0][5],
      "trustedEmails": args[1],
      "path": args[2],
      "username": args[4],
      "frequency": args[5]
    });
  }
}