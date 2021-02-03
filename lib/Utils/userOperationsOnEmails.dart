import 'package:enough_mail/discover/discover.dart';
import 'package:firebase_database/firebase_database.dart';

class UserOperationsOnEmails {
  Future<List<List<dynamic>>> getEmailSettings(String username) async {
    final DBRef = FirebaseDatabase.instance.reference();

    final dbSnapshot =
        await DBRef.child("Users").child(username).child("myEmails").once();

    Map<dynamic, dynamic> emailSettingsMap = dbSnapshot.value;

    List<List<dynamic>> emailSettings = new List();

    if (emailSettingsMap != null) {
      emailSettingsMap.values.forEach((values) {
        List<dynamic> singleEmailSettings = [
          values['username'].toString(),
          values['password'].toString(),
          values['hostname'].toString(),
          values['port'].toString(),
          values['protocol'].toString(),
          values['lastUID']
        ];
        emailSettings.add(singleEmailSettings);
      });
    }
    print("getEmailSettings:");
    print(emailSettings);
    return emailSettings;
  }


  Future<List<List<String>>> getInvoiceSenders(String username) async {
    final DBRef = FirebaseDatabase.instance.reference();

    final dbSnapshot =
    await DBRef.child("Users").child(username).child("invoicesEmails").once();

    Map<dynamic, dynamic> emailSettingsMap = dbSnapshot.value;
    List <List<String>> trustedEmailsProps = new List();

    if (emailSettingsMap != null) {
      emailSettingsMap.values.forEach((values) {
        List<String> trustedEmailsSingle = new List();
        String trustedEmailName = values['username'].toString();
        String customName = values['customname'];
        trustedEmailsSingle.add(trustedEmailName);
        trustedEmailsSingle.add(customName);
        trustedEmailsProps.add(trustedEmailsSingle);
      });

    }
    print("Nowa lista trusted: ");
    print(trustedEmailsProps);
    return trustedEmailsProps;
  }

  Future<List<String>> discoverSettings(String email, String password) async {
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
        String hostName =
            (provider.preferredIncomingServer.hostname).toString();
        if (hostName == "null")
          data.add(getHostName(email));
        else
          data.add(hostName);
        data.add((provider.preferredIncomingServer.port).toString());
        data.add(provider.preferredIncomingServer.type.toString());
      }
      print("Data for downloader:");
      print(data);
      return data;
    }
  }

  bool ifEmailIsOnet(String email) {
    List<String> onetDomains = [
      'onet.pl',
      'op.pl',
      'poczta.onet.pl',
      'onet.eu',
      'onet.com.pl',
      'vp.pl',
      'spoko.pl',
      'vip.onet.pl',
      'autograf.pl',
      'opoczta.pl',
      'amorki.pl',
      'autograf.pl',
      'buziaczek.pl',
      'adres.pl',
      'cyberia.pl',
      'pseudonim.pl'
    ];
    bool isEmail = false;
    for (var domain in onetDomains) {
      if (email.contains(domain)) {
        isEmail = true;
        break;
      }
    }
    return isEmail;
  }

  bool checkIfInteria(String host){
    bool isInteria = false;
    if(host.contains("interia")){
      isInteria = true;
    }
    return isInteria;
  }

  String getHostName(String email) {
    if (ifEmailIsOnet(email)) {
      print("Adres onet");
      return "imap.poczta.onet.pl";
    } else {
      print("Adres nie onet");
      return null;
    }
  }
}
