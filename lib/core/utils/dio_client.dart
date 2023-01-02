import 'package:dio/dio.dart';
import 'package:riverpod/riverpod.dart';

// ignore_for_file: unnecessary_const

final dioClientProvider = Provider<DioClient>(
  (ref) => DioClient(),
);

//const on purpose as 'This constructor is only guaranteed to work when invoked as const'
class DioClient {
  final Dio _dio = Dio();
  static const String profile = const String.fromEnvironment("PROFILE",
      defaultValue: "SERVER"); //possible options: SERVER EMULATOR PHONE

  //eg use command 'hostname -I | cut -d' ' -f1' to find out what is your ip
  //for EMULATOR it will be probably 10.0.2.2:5326
  static const String ipPort = const String.fromEnvironment("IP_PORT");

  static String getBaseUrl() {
    if (profile == "SERVER") {
      return "https://crossword-solver.theliver.pl";
    } else {
      return "http://$ipPort";
    }
  }

  DioClient() {
    _dio.options = BaseOptions(
      baseUrl: "${getBaseUrl()}/api",
    );
  }

  Dio get dio => _dio;
}
