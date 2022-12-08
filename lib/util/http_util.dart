import 'dart:convert';
import 'dart:io';

import 'package:async/async.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:path/path.dart';

class HttpUtil {
  static const String baseUrl = "crossword-solver.theliver.pl";
  // static const String baseUrl = "10.0.2.2:5326";

  static Future<http.Response> userLogin(String userId) async {
    var url = Uri.http(baseUrl, '/api/login');
    var body = {'user_id': userId};
    var headers = {HttpHeaders.contentTypeHeader: 'application/json'};

    var response =
    await http.post(url, headers: headers, body: jsonEncode(body));

    return response;
  }

  static Future<http.Response> userRegister() async {
    var url = Uri.http(baseUrl, '/api/register');

    var response = await http.post(url);
    return response;
  }

  static Future<http.Response> crosswordSend(
      String userId,
      File imageFile
  ) async {
    var url = Uri.http(baseUrl, '/api/solver');

    var request = http.MultipartRequest('POST', url);

    var stream = http.ByteStream(DelegatingStream(imageFile.openRead()));
    var length = await imageFile.length();
    var image = http.MultipartFile(
        'image',
        stream,
        length,
        filename: basename(imageFile.path)
    );

    request.files.add(image);


    var date = DateFormat("y-MMMM-d H:m:s").format(DateTime.now());
    print(date);
    request.fields['user_id'] = userId;
    request.fields['timestamp'] = date;

    var myRequest = await request.send();
    var response = await http.Response.fromStream(myRequest);

    return response;
  }
}
