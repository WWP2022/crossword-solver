import 'package:dartz/dartz.dart';

extension OptionEx<A> on Option<A> {
  A getOrThrow() {
    return fold(
      () => throw Exception(
          "Got None<> instead of Some<> at unrecoverable state"),
      (r) => r,
    );
  }
}
