import 'dart:convert';
import 'dart:io';

import 'package:crossword_solver/util/http_util.dart';
import 'package:crossword_solver/util/prefs_util.dart';
import 'package:crossword_solver/view/logging_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

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
          testButton(),
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
      margin: const EdgeInsets.only(top: 10, left: 20, right: 20),
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

  // TODO testButton and its test function only for testing purposes
  Container testButton() {
    return Container(
      margin: const EdgeInsets.only(top: 80, left: 20, right: 20),
      child: Builder(builder: (context) => ElevatedButton(
        style: buttonStyle,
        onPressed: () async {
          test();
        },
        child: const Text(
          'Testuj',
          style: TextStyle(fontSize: 15),
        ),
      ),),
    );
  }

  Future<void> test() async {
    var userId = await PrefsUtil.getUserId();

    final byteData = await rootBundle.load('assets/images/crossword.jpg');

    var imageFile = File('${(await getTemporaryDirectory()).path}/crossword.jpg');
    imageFile = await imageFile.writeAsBytes(byteData.buffer
        .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));

    var imagePath = imageFile.path;

    var sendCrosswordResponse = await HttpUtil.sendCrossword(userId, imagePath);

    var crosswordId = jsonDecode(sendCrosswordResponse.body)['id'];

    for (int i = 0; i < 10; i++) {
      await Future.delayed(const Duration(seconds: 3));

      var getCrosswordStatusResponse = await HttpUtil.getCrosswordStatus(
          userId,
          crosswordId.toString()
      );

      var body = jsonDecode(getCrosswordStatusResponse.body);

      print(body);
    }

    var getSolvedCrosswordResponse = await HttpUtil.getSolvedCrossword(
        userId,
        crosswordId.toString()
    );

    Directory documentDirectory = await getApplicationDocumentsDirectory();
    File solvedImageFile = File(join(documentDirectory.path, '${jsonDecode(sendCrosswordResponse.body)['crossword_name']}.png'));
    solvedImageFile.writeAsBytesSync(getSolvedCrosswordResponse.bodyBytes);

    print(getSolvedCrosswordResponse);
    print(getSolvedCrosswordResponse.body);
    print(getSolvedCrosswordResponse.bodyBytes);
    print(solvedImageFile.path);

    // saveImage();
  }

  // void saveImage(int id, String path, String crosswordName, String userId) async {
  //   CrosswordInfoRepository crosswordInfoRepository = CrosswordInfoRepository();
  //   CrosswordInfo crosswordInfo = CrosswordInfo(
  //       id: id,
  //       path: path,
  //       crosswordName: crosswordName,
  //       timestamp: DateTime.now(),
  //       userId: userId,
  //       status: "new"
  //   );
  //   crosswordInfoRepository.insertCrosswordInfo(crosswordInfo);
  // }
}
