import 'package:crossword_solver/util/prefs_util.dart';
import 'package:crossword_solver/view/logging_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../util/loading_page_util.dart';

class MyAccount extends StatefulWidget {
  const MyAccount({super.key});

  @override
  MyAccountState createState() => MyAccountState();
}

class MyAccountState extends State<MyAccount> {
  static const TextStyle optionStyle =
      TextStyle(fontSize: 30, fontWeight: FontWeight.bold);

  static ButtonStyle buttonStyle = ElevatedButton.styleFrom(
    minimumSize: const Size.fromHeight(40),
    textStyle: const TextStyle(color: Colors.white),
  );

  late Future<String> userId;

  @override
  initState() {
    super.initState();
    userId = PrefsUtil.getUserId();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          FutureBuilder(
            future: userId,
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                return userIdText(snapshot.data!);
              } else {
                return LoadingPageUtil.buildLoadingPage();
              }
            },
          ),
          logoutButton(),
        ],
      ),
    );
  }

  Container userIdText(String userId) {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      child: Text(userId, style: optionStyle),
    );
  }

  Container logoutButton() {
    return Container(
      margin: const EdgeInsets.only(top: 400, left: 20, right: 20),
      child: Builder(
        builder: (context) => ElevatedButton(
          style: buttonStyle,
          onPressed: () => logout(context),
          child: const Text(
            'Wyloguj się',
            style: TextStyle(fontSize: 15),
          ),
        ),
      ),
    );
  }

  Future<void> logout(BuildContext context) async {
    await PrefsUtil.removeUserId();
    navigateToApp(context);
  }

  void navigateToApp(context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoggingView()),
      (Route<dynamic> route) => false,
    );
  }
}
