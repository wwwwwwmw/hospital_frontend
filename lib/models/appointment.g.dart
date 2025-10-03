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
  service: json['service'] == null
      ? null
      : MedicalService.fromJson(json['service'] as Map<String, dynamic>),
  date: DateTime.parse(json['date'] as String),
  slotStart: json['slotStart'] as String,
  status: json['status'] as String,
);

Map<String, dynamic> _$AppointmentToJson(Appointment instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'doctor': instance.doctor.toJson(),
      'patient': instance.patient?.toJson(),
      'service': instance.service?.toJson(),
      'date': instance.date.toIso8601String(),
      'slotStart': instance.slotStart,
      'status': instance.status,
    };
