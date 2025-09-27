// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
  id: json['_id'] as String,
  fullName: json['fullName'] as String,
  email: json['email'] as String,
  role: json['role'] as String,
);

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
  '_id': instance.id,
  'fullName': instance.fullName,
  'email': instance.email,
  'role': instance.role,
};
