import 'package:firebase_database/firebase_database.dart';

class DatabaseOperations{
  final DBRef = FirebaseDatabase.instance.reference();

  Future<List<int>> getUserPrefsFromDB(String username) async {
    List<int> prefs = new List();
    final dbSnapshot =
    await DBRef.child("Users").child(username).child("userPrefs").once();

    Map<dynamic, dynamic> values = dbSnapshot.value;

    print(values);

    if (values != null) {
      values.forEach((key, values) {
        prefs.add(values);
      });
    }
    return prefs;
  }

  void addTrustedEmailsToDatabase(String emailKey, String email, String customName, String username) {
    DBRef.child('Users').child(username).child('invoicesEmails').child(emailKey).set({
      "username": email,
      "customname":customName
    });
  }

  void addUserEmailToDatabase(String emailKey, String email, String emailPassword, List<String> emailConfig, String username) {
    DBRef.child('Users').child(username).child('myEmails').child(emailKey).set({
      "username": email,
      "password": emailPassword,
      "hostname": emailConfig[2],
      "port": emailConfig[3],
      "protocol": emailConfig[4],
      "lastUID": 0
    });
  }

}