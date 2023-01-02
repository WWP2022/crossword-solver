// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_User _$$_UserFromJson(Map<String, dynamic> json) => _$_User(
      userId: json['user_id'] as String,
      createdAt: DateTime.parse(json['created'] as String),
      sentCrosswords: json['sent_crosswords'] as int,
    );

Map<String, dynamic> _$$_UserToJson(_$_User instance) => <String, dynamic>{
      'user_id': instance.userId,
      'created': instance.createdAt.toIso8601String(),
      'sent_crosswords': instance.sentCrosswords,
    };
