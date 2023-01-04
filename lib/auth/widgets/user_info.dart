import 'package:crossword_solver/auth/controllers/providers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class UserInfo extends StatelessWidget {
  const UserInfo({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final manageUserState = ref.watch(manageUserNotifierProvider);

        return Padding(
          padding: const EdgeInsets.only(top: 48.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Id: ',
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
              Text(
                manageUserState?.userId ?? "---",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 12.0),
              const Padding(
                padding: EdgeInsets.only(top: 12.0),
                child: Text(
                  'Użytkownik od: ',
                  style: TextStyle(
                    fontSize: 18,
                  ),
                ),
              ),
              Text(
                (manageUserState != null)
                    ? DateFormat("yyyy-MM-dd").format(manageUserState.createdAt)
                    : "---",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(top: 12.0),
                child: Text('Ilość wysłanych krzyżówek ',
                    style: TextStyle(fontSize: 18)),
              ),
              Text(
                "${manageUserState?.sentCrosswords ?? "---"}",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
