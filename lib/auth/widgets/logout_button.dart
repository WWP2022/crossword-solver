import 'package:crossword_solver/auth/controllers/providers.dart';
import 'package:crossword_solver/auth/pages/auth_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LogoutButton extends StatelessWidget {
  const LogoutButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        return Container(
          margin: const EdgeInsets.only(top: 50, left: 20, right: 20),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(40),
              textStyle: const TextStyle(color: Colors.white),
            ),
            onPressed: () async {
              ref.read(authNotifierProvider.notifier).logout();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => const AuthPage(),
                ),
              );
            },
            child: const Text(
              'Wyloguj się',
              style: TextStyle(
                fontSize: 15,
              ),
            ),
          ),
        );
      },
    );
  }
}
