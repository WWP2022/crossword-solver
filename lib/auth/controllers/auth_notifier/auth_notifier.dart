import 'dart:developer';

import 'package:crossword_solver/auth/controllers/auth_notifier/auth_state.dart';
import 'package:crossword_solver/auth/controllers/manage_user_notifier/manage_user_notifier.dart';
import 'package:crossword_solver/auth/interface/auth_interface.dart';
import 'package:crossword_solver/auth/models/user.dart';
import 'package:crossword_solver/core/utils/either_extension.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const userIdKey = "user_id";

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier(
    this._manageUserNotifier,
    this._authInterface,
  ) : super(AuthState.initial());
  final ManageUserNotifier _manageUserNotifier;
  final AuthInterface _authInterface;

  void reset() {
    state = AuthState.initial();
  }

  Future<bool> init() async {
    log('[AuthNotifier] init() call@@@');

    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    final String? userId = sharedPreferences.getString(userIdKey);
    log('[AuthNotifier] init() userId: $userId');
    if (userId != null && userId.isNotEmpty) {
      return await login(userId);
    } else {
      return false;
    }
  }

  Future<void> register() async {
    log('[AuthNotifier] register()');
    state = state.copyWith(isLoading: true);
    final userResponse = await _authInterface.registerUser();
    final sharedPreferences = await SharedPreferences.getInstance();
    if (userResponse.isRight()) {
      final User user = userResponse.getRightOrThrow();
      log('USER AT REGISTER: $user');
      _manageUserNotifier.setInitialUser(user);
      await sharedPreferences.setString(userIdKey, user.userId);
      state = state.copyWith(
        isLoading: false,
        successOrFailureOption: some(right(user)),
      );
    } else {
      final Exception exception = userResponse.getLeftOrThrow();
      sharedPreferences.remove(userIdKey);
      state = state.copyWith(
        isLoading: false,
        successOrFailureOption: some(left(exception)),
      );
    }
  }

  Future<bool> login(String userId) async {
    log('[AuthNotifier] login()');
    state = state.copyWith(isLoading: true);

    final userResponse = await _authInterface.loginUser(userId);
    final sharedPreferences = await SharedPreferences.getInstance();

    if (userResponse.isRight()) {
      final User user = userResponse.getRightOrThrow();
      _manageUserNotifier.setInitialUser(user);
      await sharedPreferences.setString(userIdKey, user.userId);
      state = state.copyWith(
        isLoading: false,
        successOrFailureOption: some(right(user)),
      );
      return true;
    } else {
      final Exception exception = userResponse.getLeftOrThrow();
      sharedPreferences.remove(userIdKey);

      state = state.copyWith(
        isLoading: false,
        successOrFailureOption: some(left(exception)),
      );
      return false;
    }
  }

  Future<void> logout() async {
    state = state.copyWith(isLoading: true);
    final sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.remove(userIdKey);
    _manageUserNotifier.logout();
    state = AuthState.initial();
  }
}
