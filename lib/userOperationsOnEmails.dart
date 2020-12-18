import 'package:firebase_database/firebase_database.dart';

 class UserOperationsOnEmails {

  Future<List<String>> getLoggedUserData(String username) async {

    List<String> userEmails = new List();

    final DBRef = FirebaseDatabase.instance.reference();

    final dbSnapshot =
    await DBRef.child("Users").child(username).child("myEmails").once();

    Map<dynamic, dynamic> values = dbSnapshot.value;

    if (values!=null) {
      values.forEach((key, values) {
        userEmails.add(values.toString());
      });
    }

    return userEmails;
  }

}