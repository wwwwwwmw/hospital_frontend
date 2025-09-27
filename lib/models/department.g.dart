// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'department.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Department _$DepartmentFromJson(Map<String, dynamic> json) => Department(
  id: json['_id'] as String,
  name: json['name'] as String,
  description: json['description'] as String?,
);

Map<String, dynamic> _$DepartmentToJson(Department instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'name': instance.name,
      'description': instance.description,
    };
