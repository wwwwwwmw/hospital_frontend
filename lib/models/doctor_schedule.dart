import 'package:json_annotation/json_annotation.dart';

part 'doctor_schedule.g.dart';

@JsonSerializable()
class ScheduleBlock {
  final String start;
  final String end;
  final int slotDurationMin;
  final int capacityPerSlot;

  ScheduleBlock({
    required this.start,
    required this.end,
    required this.slotDurationMin,
    required this.capacityPerSlot,
  });

  factory ScheduleBlock.fromJson(Map<String, dynamic> json) => _$ScheduleBlockFromJson(json);
  Map<String, dynamic> toJson() => _$ScheduleBlockToJson(this);
}

@JsonSerializable(explicitToJson: true)
class DoctorSchedule {
  @JsonKey(name: '_id')
  final String id;

  @JsonKey(name: 'doctor')
  final String doctorId;
  
  final int weekday;
  final List<ScheduleBlock> blocks;
  final bool isActive;

  DoctorSchedule({
    required this.id,
    required this.doctorId,
    required this.weekday,
    required this.blocks,
    required this.isActive,
  });

  factory DoctorSchedule.fromJson(Map<String, dynamic> json) => _$DoctorScheduleFromJson(json);
  Map<String, dynamic> toJson() => _$DoctorScheduleToJson(this);
}