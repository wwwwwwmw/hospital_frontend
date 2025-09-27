// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'appointment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Appointment _$AppointmentFromJson(Map<String, dynamic> json) => Appointment(
  id: json['_id'] as String,
  doctor: Doctor.fromJson(json['doctor'] as Map<String, dynamic>),
  patient: json['patient'] as String,
  appointmentDate: DateTime.parse(json['appointmentDate'] as String),
  status: json['status'] as String,
);

Map<String, dynamic> _$AppointmentToJson(Appointment instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'doctor': instance.doctor,
      'patient': instance.patient,
      'appointmentDate': instance.appointmentDate.toIso8601String(),
      'status': instance.status,
    };
