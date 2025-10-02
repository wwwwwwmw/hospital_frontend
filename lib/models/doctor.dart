import 'package:json_annotation/json_annotation.dart';
import 'department.dart';

part 'doctor.g.dart';

@JsonSerializable(explicitToJson: true)
class Doctor {
  @JsonKey(name: '_id')
  final String id;
  
  final String fullName;

  // SỬA Ở ĐÂY: Cho phép email có thể null
  final String? email; 
  
  final String? phone;
  final Department department;
  final bool isActive;

  Doctor({
    required this.id,
    required this.fullName,
    this.email, // Sửa ở đây
    this.phone,
    required this.department,
    required this.isActive,
  });

  factory Doctor.fromJson(Map<String, dynamic> json) => _$DoctorFromJson(json);
  Map<String, dynamic> toJson() => _$DoctorToJson(this);
}