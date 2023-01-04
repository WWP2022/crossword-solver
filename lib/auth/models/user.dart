import 'package:crossword_solver/auth/utils/date_time_converter.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';
part 'user.g.dart';

@freezed
class User with _$User {
  const factory User({
    @JsonKey(name: "user_id") required String userId,
    @DateTimeConverter() @JsonKey(name: "created") required DateTime createdAt,
    @JsonKey(name: "sent_crosswords") required int sentCrosswords,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}
