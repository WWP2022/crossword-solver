import 'package:crossword_solver/auth/controllers/auth_notifier/auth_state.dart';
import 'package:crossword_solver/auth/controllers/providers.dart';
import 'package:crossword_solver/auth/pages/auth_page.dart';
import 'package:crossword_solver/auth/widgets/logout_button.dart';
import 'package:crossword_solver/auth/widgets/user_info.dart';
import 'package:crossword_solver/core/utils/loading_page_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:random_avatar/random_avatar.dart';

class UserPage extends StatelessWidget {
  const UserPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer(
        builder: (context, ref, child) {
          final authState = ref.watch(authNotifierProvider);

          if (authState.isLoading) {
            return LoadingPageUtil.buildLoadingPage();
          } else if (authState.isException) {
            return const UserEmptyView();
          } else {
            return const UserView();
          }
        },
      ),
    );
  }
}

class UserView extends StatelessWidget {
  const UserView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, child) {
      final manageUserState = ref.watch(manageUserNotifierProvider);
      return Scaffold(
        body: Column(
          children: [
            const SizedBox(height: 50),
            Center(
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
                        offset: const Offset(0, 10))
                  ],
                  shape: BoxShape.circle,
                ),
                child: Builder(builder: (context) {
                  if (manageUserState?.userId != null) {
                    return randomAvatar(
                      manageUserState!.userId,
                      height: 200,
                      width: 200,
                    );
                  } else {
                    return const SizedBox();
                  }
                }),
              ),
            ),
            const UserInfo(),
            const LogoutButton(),
          ],
        ),
      );
    });
  }
}

class UserEmptyView extends ConsumerWidget {
  const UserEmptyView({super.key});

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Padding(
              padding: EdgeInsets.only(bottom: 8.0),
              child: Text(
                "Coś poszło nie tak i nie udało się wyświetlić danych użytkownika",
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                await ref.read(authNotifierProvider.notifier).logout();

                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => const AuthPage(),
                  ),
                );
              },
              child: const Text("Wróć do strony logowania"),
            ),
          ],
        ),
      ),
    );
  }
}
