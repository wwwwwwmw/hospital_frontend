// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'doctor.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Doctor _$DoctorFromJson(Map<String, dynamic> json) => Doctor(
  id: json['_id'] as String,
  fullName: json['fullName'] as String,
  email: json['email'] as String,
  phone: json['phone'] as String?,
  department: Department.fromJson(json['department'] as Map<String, dynamic>),
  isActive: json['isActive'] as bool,
);

Map<String, dynamic> _$DoctorToJson(Doctor instance) => <String, dynamic>{
  '_id': instance.id,
  'fullName': instance.fullName,
  'email': instance.email,
  'phone': instance.phone,
  'department': instance.department.toJson(),
  'isActive': instance.isActive,
};
