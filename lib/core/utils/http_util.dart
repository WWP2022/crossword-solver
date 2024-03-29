import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:async/async.dart';
import 'package:crossword_solver/auth/utils/date_time_converter.dart';
import 'package:crossword_solver/core/config/config.dart';
import 'package:crossword_solver/model/crossword_clue.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';

class HttpUtil {
  static String baseUrl = Config.getBaseUrl();

  static Future<http.Response> sendCrossword(
      String userId, String imagePath) async {
    var url = Config.makeUriQuery(baseUrl, '/api/solver');
    log("url:$url");
    var request = http.MultipartRequest('POST', url);

    // final byteData = await rootBundle.load('assets/images/39.png');
    // var imageFile =
    //     File('${(await getTemporaryDirectory()).path}/crossword.jpg');
    // imageFile = await imageFile.writeAsBytes(byteData.buffer
    //     .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));

    var imageFile = File(imagePath);
    var stream = http.ByteStream(DelegatingStream(imageFile.openRead()));
    var length = await imageFile.length();
    var image = http.MultipartFile('image', stream, length,
        filename: basename(imagePath));

    var date = const DateTimeConverter().toJson(DateTime.now())!;

    request.files.add(image);
    request.fields['user_id'] = userId;
    request.fields['timestamp'] = date;

    var myRequest = await request.send();

    var response = await http.Response.fromStream(myRequest);
    return response;
  }

  static Future<http.Response> getCrosswordStatus(
      String userId, String crosswordId) async {
    var args = {'user_id': userId, 'crossword_id': crosswordId};

    var url = Config.makeUriQuery(baseUrl, "/api/crossword/status",
        queryParameters: args);
    var headers = {HttpHeaders.contentTypeHeader: 'application/json'};

    var response = await http.get(
      url,
      headers: headers,
    );
    return response;
  }

  static Future<http.Response> getSolvedCrossword(
      String userId, String crosswordId) async {
    var args = {'user_id': userId, 'crossword_id': crosswordId};
    var url =
        Config.makeUriQuery(baseUrl, '/api/crossword', queryParameters: args);
    var headers = {HttpHeaders.contentTypeHeader: 'application/json'};

    var response = await http.get(
      url,
      headers: headers,
    );
    return response;
  }

  static Future<http.Response> getAllCrosswordsInfo(String userId) async {
    final args = {'user_id': userId};
    var url = Config.makeUriQuery(baseUrl, "api/crossword/all",
        queryParameters: args);
    var headers = {HttpHeaders.contentTypeHeader: 'application/json'};

    var response = await http.get(url, headers: headers);
    return response;
  }

  static Future<http.Response> updateCrossword(
      String userId, String crosswordId,
      {bool? isAccepted, String? crosswordName}) async {
    var url = Config.makeUriQuery(baseUrl, '/api/crossword');
    var body = {
      'user_id': userId,
      'crossword_id': crosswordId,
      'crossword_name': crosswordName,
      'is_accepted': isAccepted
    };
    print(body);
    var headers = {HttpHeaders.contentTypeHeader: 'application/json'};

    var response =
        await http.patch(url, headers: headers, body: jsonEncode(body));
    return response;
  }

  static Future<http.Response> postCrosswordClue(
      CrosswordClue crosswordClue) async {
    final args = {'user_id': crosswordClue.user_id};
    var url = Config.makeUriQuery(baseUrl, '/api/crossword-clue',
        queryParameters: args);
    var headers = {HttpHeaders.contentTypeHeader: 'application/json'};

    var response =
        await http.put(url, body: jsonEncode(crosswordClue), headers: headers);
    return response;
  }

  static Future<http.Response> getAllCrosswordCluesByUserId(
      String userId) async {
    final args = {'user_id': userId};
    var url = Config.makeUriQuery(baseUrl, '/api/crossword-clue',
        queryParameters: args);
    var headers = {HttpHeaders.contentTypeHeader: 'application/json'};

    var response = await http.get(url, headers: headers);
    return response;
  }

  static Future<http.Response> deleteCrosswordClue(
      String userId, String question) async {
    final args = {'user_id': userId, 'question': question};
    var url = Config.makeUriQuery(baseUrl, '/api/crossword-clue',
        queryParameters: args);
    var headers = {HttpHeaders.contentTypeHeader: 'application/json'};
    var response = await http.delete(url, headers: headers);
    return response;
  }

  static Future<http.Response> deleteCrossword(
      String userId, String crosswordId) async {
    final args = {'user_id': userId, 'crossword_id': crosswordId};
    var url =
        Config.makeUriQuery(baseUrl, "/api/crossword", queryParameters: args);
    var headers = {HttpHeaders.contentTypeHeader: 'application/json'};

    var response = await http.delete(url, headers: headers);
    return response;
  }
}
