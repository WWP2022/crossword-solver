import 'dart:async';
import 'dart:developer';

import 'package:crossword_solver/app.dart';
import 'package:crossword_solver/auth/controllers/providers.dart';
import 'package:crossword_solver/auth/pages/auth_page.dart';
import 'package:crossword_solver/core/utils/loading_page_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TopAppFrame extends ConsumerStatefulWidget {
  const TopAppFrame({super.key});

  @override
  TopAppFrameState createState() => TopAppFrameState();
}

class TopAppFrameState extends ConsumerState<TopAppFrame> {
  late Future<bool> future;

  @override
  initState() {
    super.initState();
    future = initialize(ref);
  }

  Future<bool> initialize(WidgetRef ref) async {
    log('[TopAppFrame] initialize call@@@');
    final response = await ref.read(authNotifierProvider.notifier).init();
    return response;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: FutureBuilder(
        future: future,
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data != null) {
            if (snapshot.data == true) {
              return const App();
            } else {
              return const AuthPage();
            }
          } else {
            log("[TopAppFrame] snapshot.data: ${snapshot.data}");
            return LoadingPageUtil.buildLoadingPage();
          }
        },
      ),
    );
  }
}
