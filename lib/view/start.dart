import 'package:crossword_solver/util/prefs_util.dart';
import 'package:crossword_solver/view/app.dart';
import 'package:crossword_solver/view/logging_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import '../util/loading_page_util.dart';

class StartApp extends StatefulWidget {
  const StartApp({super.key});

  @override
  StartAppState createState() => StartAppState();
}

class StartAppState extends State<StartApp>{
  late Future<String> userId;

  @override
  initState() {
    super.initState();
    userId = PrefsUtil.getUserId();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: userId,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data!.isNotEmpty) {
            return const App();
          } else {
            return const LoggingView();
          }
        } else {
          return LoadingPageUtil.buildLoadingPage();
        }
      },
    );
  }
}