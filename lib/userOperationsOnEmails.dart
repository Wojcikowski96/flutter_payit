import 'package:enough_mail/discover/discover.dart';
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

  Future <List<String>> discoverSettings(String email, String password) async {
    var config = await Discover.discover(email, isLogEnabled: true);
    List<String> data = new List();
    data.add(email);
    data.add(password);
    if (config == null) {
      print('Unable to discover settings for $email');
      return null;
    } else {
      print('Settings for $email:');
      for (var provider in config.emailProviders) {
        print('provider: ${provider.displayName}');
        data.add((provider.preferredIncomingServer.hostname).toString());
        data.add((provider.preferredIncomingServer.port).toString());
      }
      print("Data for downloader:");
      print(data);
      return data;
    }
  }

}