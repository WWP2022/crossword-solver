import 'package:crossword_solver/auth/interface/auth_interface.dart';
import 'package:crossword_solver/auth/models/user.dart';
import 'package:dartz/dartz.dart';

class AuthTestService implements AuthInterface {
  @override
  Future<Either<Exception, User>> registerUser() async {
    return right(
      User(
        userId: "jifoej042j90",
        createdAt: DateTime.now(),
        sentCrosswords: 5,
      ),
    );
  }

  @override
  Future<Either<Exception, User>> loginUser(String userId) async {
    return right(
      User(
        userId: "jifoej042j90",
        createdAt: DateTime.now(),
        sentCrosswords: 5,
      ),
    );
  }
}
