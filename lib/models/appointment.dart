import 'package:json_annotation/json_annotation.dart';
import 'doctor.dart';
import 'patient.dart';

part 'appointment.g.dart';

@JsonSerializable(explicitToJson: true) // Thêm explicitToJson
class Appointment {
  @JsonKey(name: '_id')
  final String id;
  
  final Doctor doctor; 
  
  final Patient? patient; // Sửa thành Patient?
  
  final DateTime startTime; // Sửa thành startTime
  
  final String status;

  Appointment({
    required this.id,
    required this.doctor,
    this.patient,
    required this.startTime,
    required this.status,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) =>
      _$AppointmentFromJson(json);

  Map<String, dynamic> toJson() => _$AppointmentToJson(this);
}

