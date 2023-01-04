import 'package:crossword_solver/app.dart';
import 'package:crossword_solver/auth/controllers/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
                        await authNotifier.login(_idController.text);
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
}
