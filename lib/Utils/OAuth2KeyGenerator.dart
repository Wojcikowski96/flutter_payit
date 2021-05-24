import 'dart:io';
import 'package:oauth2/oauth2.dart' as oauth2;
class OAuth2KeyGenerator{

  final String client_id = "134130269608-orkfln10pvuof63jf6qcllu8u3o91q4c.apps.googleusercontent.com";
  final String redirect_uri = "urn:ietf:wg:oauth:2.0:oob";
  final String scope = "https://mail.google.com/";

  String constructAuthorizationURL(){
    String URL = "https://accounts.google.com/o/oauth2/v2/auth?scope=$scope&access_type=offline&include_granted_scopes=true&response_type=code&state=state_parameter_passthrough_value&redirect_uri=$redirect_uri&client_id=$client_id";
    print("Wygenerowany URL");
    print(URL);
    return URL;
  }

}