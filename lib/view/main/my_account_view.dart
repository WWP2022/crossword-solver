import 'dart:convert';

import 'package:crossword_solver/util/prefs_util.dart';
import 'package:crossword_solver/view/logging_view.dart';
import 'package:flutter/material.dart';
import 'package:random_avatar/random_avatar.dart';

import '../../util/http_util.dart';
import '../../util/loading_page_util.dart';

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

  Future<Map<String, dynamic>> fetchUserInfo() async {
    var response = await HttpUtil.getUserInfo(await userId);
    if (response.statusCode == 200) {
        return json.decode(response.body);
    } else {
      throw Exception('Failed to load user data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const SizedBox(height: 50),
          avatar(),
          userInfo(),
          logoutButton(),
        ],
      ),
    );
  }

  Container logoutButton() {
    return Container(
      margin: const EdgeInsets.only(top: 50, left: 20, right: 20),
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

  FutureBuilder avatar() {
    return FutureBuilder(
      future: userId,
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data!.isNotEmpty) {
          return Center(
            child: Container(
              width: 175,
              height: 175,
              decoration: BoxDecoration(
                border: Border.all(
                    width: 4,
                    color: Theme.of(context).scaffoldBackgroundColor),
                boxShadow: [
                  BoxShadow(
                      spreadRadius: 2,
                      blurRadius: 10,
                      color: Colors.black.withOpacity(0.1),
                      offset: Offset(0, 10))
                ],
                shape: BoxShape.circle,
              ),
              child: randomAvatar(
                snapshot.data!,
                height: 200,
                width: 200,
              ),
            ),
          );
        } else {
          return LoadingPageUtil.buildLoadingPage();
        }
      },
    );
  }

  FutureBuilder userInfo() {
    TextStyle infoStyle = const TextStyle(fontSize: 18);
    TextStyle userInfoStyle = const TextStyle(fontWeight: FontWeight.bold, fontSize: 18);
    return FutureBuilder(
      future: fetchUserInfo(),
      builder: (context, info) {
        if (info.hasData && info.data!.isNotEmpty) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 48.0),
              Text('Id: ', style: infoStyle),
              Text(info.data!['user_id'], style: userInfoStyle),
              const SizedBox(height: 12.0),
              Text('Użytkownik od: ', style: infoStyle),
              Text(info.data!['created'], style: userInfoStyle),
              const SizedBox(height: 12.0),
              Text('Ilość wysłanych krzyżówek ', style: infoStyle),
              Text(info.data!['all_crosswords_number'], style: userInfoStyle),
            ],
          );
        } else {
          return LoadingPageUtil.buildLoadingPage();
        }
      },
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
