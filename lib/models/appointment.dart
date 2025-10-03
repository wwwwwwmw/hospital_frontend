import 'package:json_annotation/json_annotation.dart';
import 'doctor.dart';
import 'patient.dart';
import 'service.dart';

part 'appointment.g.dart';

@JsonSerializable(explicitToJson: true)
class Appointment {
  @JsonKey(name: '_id')
  final String id;
  
  final Doctor doctor; 
  final Patient? patient;
  final MedicalService? service; // Thêm service, cho phép null

  // === SỬA ĐỔI QUAN TRỌNG TẠI ĐÂY ===
  final DateTime date;      // Thay vì startTime
  final String slotStart;   // Thêm trường này
  // ===================================
  
  final String status;

  Appointment({
    required this.id,
    required this.doctor,
    this.patient,
    this.service,
    required this.date,      // Sửa ở đây
    required this.slotStart, // Sửa ở đây
    required this.status,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) =>
      _$AppointmentFromJson(json);

  Map<String, dynamic> toJson() => _$AppointmentToJson(this);
}