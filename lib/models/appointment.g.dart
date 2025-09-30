// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'appointment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Appointment _$AppointmentFromJson(Map<String, dynamic> json) => Appointment(
  id: json['_id'] as String,
  doctor: Doctor.fromJson(json['doctor'] as Map<String, dynamic>),
  patient: json['patient'] == null
      ? null
      : Patient.fromJson(json['patient'] as Map<String, dynamic>),
  startTime: DateTime.parse(json['startTime'] as String),
  status: json['status'] as String,
);

Map<String, dynamic> _$AppointmentToJson(Appointment instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'doctor': instance.doctor.toJson(),
      'patient': instance.patient?.toJson(),
      'startTime': instance.startTime.toIso8601String(),
      'status': instance.status,
    };
