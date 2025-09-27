import 'package:json_annotation/json_annotation.dart';
import 'doctor.dart'; // Giả sử backend trả về thông tin doctor đầy đủ

part 'appointment.g.dart';

@JsonSerializable()
class Appointment {
  @JsonKey(name: '_id')
  final String id;
  final Doctor doctor;
  final String patient; // ID của bệnh nhân
  final DateTime appointmentDate;
  final String status;

  Appointment({
    required this.id,
    required this.doctor,
    required this.patient,
    required this.appointmentDate,
    required this.status,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) =>
      _$AppointmentFromJson(json);
  Map<String, dynamic> toJson() => _$AppointmentToJson(this);
}
