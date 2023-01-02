// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

User _$UserFromJson(Map<String, dynamic> json) {
  return _User.fromJson(json);
}

/// @nodoc
mixin _$User {
  @JsonKey(name: "user_id")
  String get userId => throw _privateConstructorUsedError;

  @DateTimeConverter()
  @JsonKey(name: "created")
  DateTime get createdAt => throw _privateConstructorUsedError;

  @JsonKey(name: "sent_crosswords")
  int get sentCrosswords => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $UserCopyWith<User> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserCopyWith<$Res> {
  factory $UserCopyWith(User value, $Res Function(User) then) =
      _$UserCopyWithImpl<$Res, User>;

  @useResult
  $Res call(
      {@JsonKey(name: "user_id") String userId,
      @DateTimeConverter() @JsonKey(name: "created") DateTime createdAt,
      @JsonKey(name: "sent_crosswords") int sentCrosswords});
}

/// @nodoc
class _$UserCopyWithImpl<$Res, $Val extends User>
    implements $UserCopyWith<$Res> {
  _$UserCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;

  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? createdAt = null,
    Object? sentCrosswords = null,
  }) {
    return _then(_value.copyWith(
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      sentCrosswords: null == sentCrosswords
          ? _value.sentCrosswords
          : sentCrosswords // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_UserCopyWith<$Res> implements $UserCopyWith<$Res> {
  factory _$$_UserCopyWith(_$_User value, $Res Function(_$_User) then) =
      __$$_UserCopyWithImpl<$Res>;

  @override
  @useResult
  $Res call(
      {@JsonKey(name: "user_id") String userId,
      @DateTimeConverter() @JsonKey(name: "created") DateTime createdAt,
      @JsonKey(name: "sent_crosswords") int sentCrosswords});
}

/// @nodoc
class __$$_UserCopyWithImpl<$Res> extends _$UserCopyWithImpl<$Res, _$_User>
    implements _$$_UserCopyWith<$Res> {
  __$$_UserCopyWithImpl(_$_User _value, $Res Function(_$_User) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? createdAt = null,
    Object? sentCrosswords = null,
  }) {
    return _then(_$_User(
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      sentCrosswords: null == sentCrosswords
          ? _value.sentCrosswords
          : sentCrosswords // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_User implements _User {
  const _$_User(
      {@JsonKey(name: "user_id") required this.userId,
      @DateTimeConverter() @JsonKey(name: "created") required this.createdAt,
      @JsonKey(name: "sent_crosswords") required this.sentCrosswords});

  factory _$_User.fromJson(Map<String, dynamic> json) => _$$_UserFromJson(json);

  @override
  @JsonKey(name: "user_id")
  final String userId;
  @override
  @DateTimeConverter()
  @JsonKey(name: "created")
  final DateTime createdAt;
  @override
  @JsonKey(name: "sent_crosswords")
  final int sentCrosswords;

  @override
  String toString() {
    return 'User(userId: $userId, createdAt: $createdAt, sentCrosswords: $sentCrosswords)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_User &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.sentCrosswords, sentCrosswords) ||
                other.sentCrosswords == sentCrosswords));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, userId, createdAt, sentCrosswords);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_UserCopyWith<_$_User> get copyWith =>
      __$$_UserCopyWithImpl<_$_User>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_UserToJson(
      this,
    );
  }
}

abstract class _User implements User {
  const factory _User(
      {@JsonKey(name: "user_id")
          required final String userId,
      @DateTimeConverter()
      @JsonKey(name: "created")
          required final DateTime createdAt,
      @JsonKey(name: "sent_crosswords")
          required final int sentCrosswords}) = _$_User;

  factory _User.fromJson(Map<String, dynamic> json) = _$_User.fromJson;

  @override
  @JsonKey(name: "user_id")
  String get userId;

  @override
  @DateTimeConverter()
  @JsonKey(name: "created")
  DateTime get createdAt;

  @override
  @JsonKey(name: "sent_crosswords")
  int get sentCrosswords;

  @override
  @JsonKey(ignore: true)
  _$$_UserCopyWith<_$_User> get copyWith => throw _privateConstructorUsedError;
}
