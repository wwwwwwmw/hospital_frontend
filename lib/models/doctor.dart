import 'package:json_annotation/json_annotation.dart';
import 'department.dart';

part 'doctor.g.dart';

@JsonSerializable(explicitToJson: true)
class Doctor {
  @JsonKey(name: '_id')
  final String id;
  
  final String fullName;
  final String email;
  final String? phone;
  final Department department;

  // Bổ sung trường isActive còn thiếu
  final bool isActive;

  Doctor({
    required this.id,
    required this.fullName,
    required this.email,
    this.phone,
    required this.department,
    required this.isActive,
  });

  factory Doctor.fromJson(Map<String, dynamic> json) => _$DoctorFromJson(json);
  Map<String, dynamic> toJson() => _$DoctorToJson(this);
}