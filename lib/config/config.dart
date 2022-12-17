//const on purpose as 'This constructor is only guaranteed to work when invoked as const'
class Config {
  static const String profile = const String.fromEnvironment("PROFILE",
      defaultValue: "SERVER"); //possible options: SERVER EMULATOR PHONE

  //eg use command 'hostname -I | cut -d' ' -f1' to find out what is your ip
  static const String ipPort = const String.fromEnvironment("IP_PORT");

  static String getBaseUrl() {
    switch (profile) {
      case "PHONE":
        {
          return ipPort;
        }
      case "EMULATOR":
        {
          return "10.0.2.2:5326";
        }
      default:
        {
          return "crossword-solver.theliver.pl";
        }
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
