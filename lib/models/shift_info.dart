import 'package:json_annotation/json_annotation.dart';

part 'shift_info.g.dart';

@JsonSerializable()
class ShiftInfo {
  final String shiftName;
  final String start;
  final String end;
  final int capacity;
  final int bookedCount;
  final List<TimeSlot> slots;

  ShiftInfo({
    required this.shiftName,
    required this.start,
    required this.end,
    required this.capacity,
    required this.bookedCount,
    required this.slots,
  });

  factory ShiftInfo.fromJson(Map<String, dynamic> json) => _$ShiftInfoFromJson(json);
  Map<String, dynamic> toJson() => _$ShiftInfoToJson(this);
}

@JsonSerializable()
class TimeSlot {
  final String start;
  final String end;

  TimeSlot({
    required this.start,
    required this.end,
  });

  factory TimeSlot.fromJson(Map<String, dynamic> json) => _$TimeSlotFromJson(json);
  Map<String, dynamic> toJson() => _$TimeSlotToJson(this);
}