import 'package:crossword_solver/auth/models/user.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ManageUserNotifier extends StateNotifier<User?> {
  ManageUserNotifier() : super(null);

  void logout() {
    state = null;
  }

  void setInitialUser(User user) {
    state = user;
  }

  void incrementSentCrosswords() {
    state = state!.copyWith(
      sentCrosswords: state!.sentCrosswords + 1,
    );
  }
}
