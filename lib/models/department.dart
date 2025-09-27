import 'package:json_annotation/json_annotation.dart';

part 'department.g.dart'; // File này sẽ được tự động sinh ra

@JsonSerializable()
class Department {
  @JsonKey(name: '_id') // Ánh xạ _id từ MongoDB
  final String id;
  final String name;
  final String? description; // Có thể null

  Department({
    required this.id,
    required this.name,
    this.description,
  });

  /// Connects the generated [_$DepartmentFromJson] function to the `fromJson` factory.
  factory Department.fromJson(Map<String, dynamic> json) =>
      _$DepartmentFromJson(json);

  /// Connects the generated [_$DepartmentToJson] function to the `toJson` method.
  Map<String, dynamic> toJson() => _$DepartmentToJson(this);
}
