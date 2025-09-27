import 'package:json_annotation/json_annotation.dart';
import 'user.dart'; // Import model User để sử dụng

part 'patient.g.dart'; // File này sẽ được tự động sinh ra

@JsonSerializable()
class Patient {
  @JsonKey(name: '_id') // Ánh xạ _id từ MongoDB
  final String id;

  // Tham chiếu đến người dùng giám hộ, có thể là một đối tượng User đầy đủ
  final User guardianUser;

  final String phone;
  final String fullName;
  final DateTime dob;
  final String gender;

  Patient({
    required this.id,
    required this.guardianUser,
    required this.phone,
    required this.fullName,
    required this.dob,
    required this.gender,
  });

  /// Connects the generated [_$PatientFromJson] function to the `fromJson` factory.
  factory Patient.fromJson(Map<String, dynamic> json) =>
      _$PatientFromJson(json);

  /// Connects the generated [_$PatientToJson] function to the `toJson` method.
  Map<String, dynamic> toJson() => _$PatientToJson(this);
}
