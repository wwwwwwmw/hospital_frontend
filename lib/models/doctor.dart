import 'package:json_annotation/json_annotation.dart';

part 'doctor.g.dart'; // File này sẽ được tự động sinh ra

@JsonSerializable()
class Doctor {
  @JsonKey(name: '_id') // Ánh xạ _id từ MongoDB
  final String id;
  final String fullName;
  final String phone;
  final String email;
  // Thêm các trường khác nếu cần

  Doctor({required this.id, required this.fullName, required this.phone, required this.email});

  factory Doctor.fromJson(Map<String, dynamic> json) => _$DoctorFromJson(json);
  Map<String, dynamic> toJson() => _$DoctorToJson(this);
}