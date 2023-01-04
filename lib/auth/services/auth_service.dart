import 'dart:developer';

import 'package:crossword_solver/auth/interface/auth_interface.dart';
import 'package:crossword_solver/auth/models/user.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

class AuthService implements AuthInterface {
  AuthService(this._dio);

  final Dio _dio;

  @override
  Future<Either<Exception, User>> registerUser() async {
    late Either<Exception, User> result;
    try {
      final response = await _dio.post('/register');
      if (response.statusCode == 200 || response.statusCode == 201) {
        result = Right(User.fromJson(response.data));
      } else {
        result = Left(
          Exception("Error! registerUser status code ${response.statusCode}"),
        );
      }
    } on DioError catch (e, s) {
      log("[AuthService] -> registerUser() ", error: e, stackTrace: s);

      result = Left(Exception(e.message));
    }
    return result;
  }

  @override
  Future<Either<Exception, User>> loginUser(String userId) async {
    late Either<Exception, User> result;

    final Map<String, dynamic> dto = {'user_id': userId};
    try {
      final response = await _dio.post('/login', data: dto);
      log("[AuthService] loginUser() response: ${response.data}");
      if (response.statusCode == 200 || response.statusCode == 201) {
        return Right(User.fromJson(response.data));
      } else {
        result = Left(
            Exception("Error! loginUser status code ${response.statusCode}"));
      }
    } on DioError catch (e, s) {
      log("[AuthService] -> loginUser() ", error: e, stackTrace: s);

      result = Left(Exception(e.message));
    }
    return result;
  }
}
