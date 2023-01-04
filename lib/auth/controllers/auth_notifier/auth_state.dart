import 'package:crossword_solver/auth/models/user.dart';
import 'package:dartz/dartz.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_state.freezed.dart';

@freezed
class AuthState with _$AuthState {
  const factory AuthState({
    required bool isLoading,
    required Option<Either<Exception, User>> successOrFailureOption,
  }) = _AuthState;

  factory AuthState.initial() => AuthState(
        isLoading: false,
        successOrFailureOption: none(),
      );
}

extension AuthStateEx on AuthState {
  bool get isException => successOrFailureOption.fold(
        () => true,
        (a) => a.fold(
          (l) => true,
          (r) => false,
        ),
      );

  User? get escapedState => successOrFailureOption.fold(
        () => null,
        (a) => a.fold(
          (l) => null,
          (r) => r,
        ),
      );
}
