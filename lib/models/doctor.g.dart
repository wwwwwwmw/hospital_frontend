// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'doctor.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Doctor _$DoctorFromJson(Map<String, dynamic> json) => Doctor(
  id: json['_id'] as String,
  fullName: json['fullName'] as String,
  phone: json['phone'] as String,
  email: json['email'] as String,
);

Map<String, dynamic> _$DoctorToJson(Doctor instance) => <String, dynamic>{
  '_id': instance.id,
  'fullName': instance.fullName,
  'phone': instance.phone,
  'email': instance.email,
};
