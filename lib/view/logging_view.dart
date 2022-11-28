import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../util/prefs_util.dart';
import 'app.dart';

class LoggingView extends StatelessWidget {
  const LoggingView({super.key});

  static const TextStyle textStyle =
    TextStyle(fontSize: 20, fontWeight: FontWeight.bold);

  static ButtonStyle buttonStyle = ElevatedButton.styleFrom(
    minimumSize: const Size.fromHeight(40),
    textStyle: const TextStyle(color: Colors.white),
  );

  static TextEditingController idController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Builder(
        builder: (context) => Scaffold(
          body: Center(child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              signInText(),
              idLoginInput(),
              loginButton(),
              orText(),
              registerButton(),
            ],
          ))
        ),
      ),
    );
  }

  Container signInText() {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      child: const Text('Podaj swój UserID:', style: textStyle),
    );
  }

  Container orText() {
    return Container(
      margin: const EdgeInsets.only(top: 25, bottom: 15),
      child: const Text('LUB', style: textStyle),
    );
  }

  Container idLoginInput() {
    return Container(
      margin: const EdgeInsets.only(top: 10, left: 20, right: 20),
      child: TextField(
        controller: idController,
        obscureText: false,
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          labelText: 'UserID',
          // labelText: userId,
        ),
      ),
    );
  }

  Container loginButton() {
    return Container(
      margin: const EdgeInsets.only(top: 10, left: 20, right: 20),
      child: Builder(builder: (context) => ElevatedButton(
        style: buttonStyle,
        onPressed: () => login(context, idController.text.toString()),
        child: const Text(
          'Zaloguj się',
          style: TextStyle(fontSize: 15),
        ),
      ),),
    );
  }

  Container registerButton() {
    return Container(
      margin: const EdgeInsets.only(top: 10, left: 20, right: 20),
      child: Builder(builder: (context) => ElevatedButton(
        style: buttonStyle,
        onPressed: () => register(context),
        child: const Text(
          'Zarejestruj się',
          style: TextStyle(fontSize: 15),
        ),
      ),),
    );
  }

  Future<void> login(BuildContext context, String userId) async {

    var body = {
      'user_id': userId
    };
    var url = Uri.https(
        'crossword-solver.theliver.pl',
        '/api/login'
    );
    var headers = {HttpHeaders.contentTypeHeader: 'application/json'};

    var response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(body)
    );

    var status = response.statusCode;

    if (status == 200) {
      var jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;

      if (jsonResponse.containsKey('user_id')) {
        PrefsUtil.setUserId(userId);
        navigateToApp(context);
      } else {
        var error = jsonResponse['error'].toString();

        ScaffoldMessenger.of(context)
            .showSnackBar(userNotExistsSnackBar(error));
      }
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(serverErrorSnackBar(status.toString()));
    }
  }

  Future<void> register(context) async {
    var url = Uri.https(
        'crossword-solver.theliver.pl',
        '/api/register',
    );

    var response = await http.get(url);
    var status = response.statusCode;

    if (status == 200) {
      var jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
      var userId = jsonResponse['user_id'];

      PrefsUtil.setUserId(userId);
      navigateToApp(context);
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(serverErrorSnackBar(status.toString()));
    }
  }

  SnackBar userNotExistsSnackBar(String error) {
    return SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.red,
        content: Text(error)
    );
  }

  SnackBar serverErrorSnackBar(String statusCode) {
    return SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.red,
        content: Text("Error! Status code: $statusCode")
    );
  }

  void navigateToApp(context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => App()),
          (Route<dynamic> route) => false,
    );
  }
}
