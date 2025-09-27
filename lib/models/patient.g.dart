// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'patient.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Patient _$PatientFromJson(Map<String, dynamic> json) => Patient(
  id: json['_id'] as String,
  guardianUser: User.fromJson(json['guardianUser'] as Map<String, dynamic>),
  phone: json['phone'] as String,
  fullName: json['fullName'] as String,
  dob: DateTime.parse(json['dob'] as String),
  gender: json['gender'] as String,
);

Map<String, dynamic> _$PatientToJson(Patient instance) => <String, dynamic>{
  '_id': instance.id,
  'guardianUser': instance.guardianUser,
  'phone': instance.phone,
  'fullName': instance.fullName,
  'dob': instance.dob.toIso8601String(),
  'gender': instance.gender,
};
