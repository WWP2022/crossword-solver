import 'package:flutter/material.dart';

class LoggingView extends StatefulWidget {
  const LoggingView({super.key});

  @override
  State<LoggingView> createState() => LoggingViewState();
}

class LoggingViewState extends State<LoggingView> {
  static const TextStyle textStyle =
      TextStyle(fontSize: 20, fontWeight: FontWeight.bold);

  static ButtonStyle buttonStyle = ElevatedButton.styleFrom(
    minimumSize: const Size.fromHeight(40),
    textStyle: const TextStyle(color: Colors.white),
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text("Logowanie"),
        ),
        body: Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            signInText(),
            idInput(),
            loginWithIdButton(),
            orText(),
            generateNewIdButton(),
          ],
        )),
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

  Container idInput() {
    return Container(
      margin: const EdgeInsets.only(top: 10, left: 20, right: 20),
      child: const TextField(
        obscureText: false,
        decoration: InputDecoration(
          border: OutlineInputBorder(),
          labelText: 'UserID',
        ),
      ),
    );
  }

  Container loginWithIdButton() {
    return Container(
      margin: const EdgeInsets.only(top: 10, left: 20, right: 20),
      child: ElevatedButton(
        style: buttonStyle,
        onPressed: () {},
        child: const Text(
          'Zaloguj się',
          // 'Login',
          style: TextStyle(fontSize: 15),
        ),
      ),
    );
  }

  Container generateNewIdButton() {
    return Container(
      margin: const EdgeInsets.only(top: 10, left: 20, right: 20),
      child: ElevatedButton(
        style: buttonStyle,
        onPressed: () {},
        child: const Text(
          'Zarejestruj się',
          // 'Generate new ID',
          style: TextStyle(fontSize: 15),
        ),
      ),
    );
  }
}
