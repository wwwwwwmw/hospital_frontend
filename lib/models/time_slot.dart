import 'package:json_annotation/json_annotation.dart';

// !!! THÊM DÒNG NÀY VÀO !!!
part 'time_slot.g.dart';

@JsonSerializable()
class TimeSlot {
  final DateTime startTime;
  final DateTime endTime;

  TimeSlot({
    required this.startTime,
    required this.endTime,
  });

  factory TimeSlot.fromJson(Map<String, dynamic> json) =>
      _$TimeSlotFromJson(json);

  Map<String, dynamic> toJson() => _$TimeSlotToJson(this);
}

