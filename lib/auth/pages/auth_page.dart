import 'dart:convert';
import 'dart:io';

import 'package:crossword_solver/app.dart';
import 'package:crossword_solver/auth/controllers/providers.dart';
import 'package:crossword_solver/core/utils/http_util.dart';
import 'package:crossword_solver/database/crossword_info_repository.dart';
import 'package:crossword_solver/model/crossword_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class AuthPage extends ConsumerStatefulWidget {
  const AuthPage({super.key});

  @override
  AuthPageState createState() => AuthPageState();
}

class AuthPageState extends ConsumerState<AuthPage> {
  final TextEditingController _idController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer(
        builder: (context, ref, child) {
          final authNotifier = ref.watch(authNotifierProvider.notifier);
          final authState = ref.watch(authNotifierProvider);
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  margin: const EdgeInsets.only(top: 10),
                  child: const Text(
                    'Podaj swój UserID:',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 10, left: 20, right: 20),
                  child: TextField(
                    controller: _idController,
                    obscureText: false,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'UserID',
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 10, left: 20, right: 20),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(40),
                      textStyle: const TextStyle(color: Colors.white),
                    ),
                    onPressed: () async {
                      if (!authState.isLoading) {
                        if (await authNotifier.login(_idController.text)) {
                          var userId = _idController.text;

                          var response =
                              await HttpUtil.getAllCrosswordsIds(userId);

                          var body = jsonDecode(response.body);
                          var status = response.statusCode;

                          if (status == 200) {
                            Directory documentDirectory =
                                await getApplicationDocumentsDirectory();
                            for (var crosswordInfo in body) {
                              var crosswordId = crosswordInfo['crossword_id'];
                              var crosswordName =
                                  crosswordInfo['crossword_name'];
                              var crosswordStatus =
                                  crosswordInfo['crossword_status'];

                              var getSolvedCrosswordResponse =
                                  await HttpUtil.getSolvedCrossword(
                                      userId, crosswordId.toString());

                              File solvedImageFile = File(join(
                                  documentDirectory.path,
                                  '$crosswordName.png'));
                              solvedImageFile.writeAsBytesSync(
                                  getSolvedCrosswordResponse.bodyBytes);

                              saveImage(crosswordId, solvedImageFile.path,
                                  crosswordName, userId, crosswordStatus);
                            }
                          } else {
                            print(status);
                          }

                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AppView(),
                            ),
                          );
                        }
                      }
                    },
                    child: Builder(
                      builder: (context) {
                        if (authState.isLoading) {
                          return const CircularProgressIndicator(
                            color: Colors.white,
                          );
                        } else {
                          return const Text(
                            'Zaloguj się',
                            style: TextStyle(fontSize: 15),
                          );
                        }
                      },
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 25, bottom: 15),
                  child: const Text(
                    'LUB',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 10, left: 20, right: 20),
                  child: Builder(
                    builder: (context) => ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(40),
                        textStyle: const TextStyle(color: Colors.white),
                      ),
                      onPressed: () async {
                        if (!authState.isLoading) {
                          await ref
                              .read(authNotifierProvider.notifier)
                              .register();
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AppView(),
                            ),
                          );
                        }
                      },
                      child: Builder(builder: (context) {
                        if (authState.isLoading) {
                          return const CircularProgressIndicator(
                            color: Colors.white,
                          );
                        } else {
                          return const Text(
                            'Zarejestruj się',
                            style: TextStyle(fontSize: 15),
                          );
                        }
                      }),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void saveImage(
    int id,
    String path,
    String crosswordName,
    String userId,
    String status,
  ) async {
    CrosswordInfoRepository crosswordInfoRepository = CrosswordInfoRepository();
    CrosswordInfo crosswordInfo = CrosswordInfo(
      id: id,
      path: path,
      crosswordName: crosswordName,
      timestamp: DateTime.now(),
      userId: userId,
      status: status,
    );
    await crosswordInfoRepository.insertCrosswordInfo(crosswordInfo);
  }
}
