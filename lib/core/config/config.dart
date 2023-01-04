//const on purpose as 'This constructor is only guaranteed to work when invoked as const'
// ignore_for_file: unnecessary_const

class Config {
  static const String profile = const String.fromEnvironment("PROFILE",
      defaultValue: "SERVER"); //possible options: SERVER EMULATOR PHONE

  //eg use command 'hostname -I | cut -d' ' -f1' to find out what is your ip
  //for EMULATOR it will be probably 10.0.2.2:5326
  static const String ipPort = const String.fromEnvironment("IP_PORT");

  static String getBaseUrl() {
    if (profile == "SERVER") {
      return "crossword-solver.theliver.pl";
    } else {
      return ipPort;
    }
  }

  static makeUriQuery(String baseUrl, String endpoint,
      {Map<String, String> queryParameters = const <String, String>{}}) {
    if (profile != "SERVER") {
      return Uri.http(baseUrl, endpoint, queryParameters);
    }
    return Uri.https(baseUrl, endpoint, queryParameters);
  }
}
