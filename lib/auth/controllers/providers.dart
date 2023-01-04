import 'package:crossword_solver/auth/controllers/auth_notifier/auth_notifier.dart';
import 'package:crossword_solver/auth/controllers/auth_notifier/auth_state.dart';
import 'package:crossword_solver/auth/controllers/manage_user_notifier/manage_user_notifier.dart';
import 'package:crossword_solver/auth/models/user.dart';
import 'package:crossword_solver/auth/services/auth_service.dart';
import 'package:crossword_solver/auth/services/auth_test_service.dart';
import 'package:crossword_solver/core/utils/dio_client.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final _authService = Provider(
  (ref) => AuthService(
    ref.watch(dioClientProvider).dio,
  ),
);

final _authTestService = Provider(
  (ref) => AuthTestService(),
);

final manageUserNotifierProvider =
    StateNotifierProvider<ManageUserNotifier, User?>(
  (ref) => ManageUserNotifier(),
);
final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) => AuthNotifier(
    ref.watch(manageUserNotifierProvider.notifier),
    ref.watch(_authService),
  ),
);
