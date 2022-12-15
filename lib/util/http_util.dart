import 'dart:convert';
import 'dart:io';

import 'package:async/async.dart';
import 'package:crossword_solver/model/crossword_clue.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:path/path.dart';

class HttpUtil {
  //TODO add profile
  // static const String baseUrl = "crossword-solver.theliver.pl";
  static const String baseUrl = "10.0.2.2:5326";
  // static const String baseUrl = "192.168.23.209:5326";

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
      String userId, File imageFile) async {
    var url = Uri.http(baseUrl, '/api/solver');
    var request = http.MultipartRequest('POST', url);

    var stream = http.ByteStream(DelegatingStream(imageFile.openRead()));
    var length = await imageFile.length();
    var image = http.MultipartFile('image', stream, length,
        filename: basename(imageFile.path));

    var date = DateFormat("y-MMMM-d H:m:s").format(DateTime.now());

    request.files.add(image);
    request.fields['user_id'] = userId;
    request.fields['timestamp'] = date;

    var myRequest = await request.send();
    var response = await http.Response.fromStream(myRequest);

    return response;
  }

  static Future<http.Response> postCrosswordClue(
      CrosswordClue crosswordClue) async {
    final queryParameters = {'user_id': crosswordClue.user_id};
    var url = Uri.http(baseUrl, '/api/crossword-clue', queryParameters);
    var headers = {HttpHeaders.contentTypeHeader: 'application/json'};
    var response = await http.put(url, body: jsonEncode(crosswordClue), headers: headers);
    return response;
  }

  static Future<http.Response> getAllCrosswordCluesByUserId(
      String userId) async {
    final queryParameters = {'user_id': userId};
    var url = Uri.http(baseUrl, '/api/crossword-clue', queryParameters);
    var headers = {HttpHeaders.contentTypeHeader: 'application/json'};
    var response = await http.get(url, headers: headers);
    return response;
  }
}

// TODO
//button + i więcej odp w PUTcie
//profil odpalania apki
//edycja questiona
//usuniecie questiona
//jesli nie ma haseł to komunikat
// zwrócić uwagę na dodawanie dwóch tych samych pytań i dwóch odpowiedzi do jednego pytania
// zmieniać wysokość i szerokość? containera w zależności od ilości odpowiedzi