import 'package:crossword_solver/auth/models/user.dart';
import 'package:dartz/dartz.dart';

abstract class AuthInterface {
  Future<Either<Exception, User>> registerUser();

  Future<Either<Exception, User>> loginUser(String userId);
}
