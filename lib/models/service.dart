// File: lib/models/service.dart

import 'package:json_annotation/json_annotation.dart';

part 'service.g.dart'; // Tên file được sinh ra tự động

@JsonSerializable()
class MedicalService {
  @JsonKey(name: '_id') // Ánh xạ _id từ backend
  final String id;
  
  final String name;
  final double price;

  MedicalService({
    required this.id,
    required this.name,
    required this.price,
  });

  // Hàm để chuyển đổi từ JSON thành đối tượng MedicalService
  factory MedicalService.fromJson(Map<String, dynamic> json) =>
      _$MedicalServiceFromJson(json);

  // Hàm để chuyển đổi từ đối tượng MedicalService thành JSON
  Map<String, dynamic> toJson() => _$MedicalServiceToJson(this);
}