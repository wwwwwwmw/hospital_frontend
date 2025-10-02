import 'package:json_annotation/json_annotation.dart';
import 'time_slot.dart';

part 'shift_info.g.dart';

@JsonSerializable(explicitToJson: true)
class ShiftInfo {
  // === BỔ SUNG 2 TRƯỜNG CÒN THIẾU ===
  @JsonKey(defaultValue: '')
  final String start;

  @JsonKey(defaultValue: '')
  final String end;
  
  // === CÁC TRƯỜNG CŨ GIỮ NGUYÊN ===
  @JsonKey(defaultValue: 'Unknown Shift')
  final String shiftName;

  @JsonKey(defaultValue: 0)
  final int capacity;

  @JsonKey(defaultValue: 0)
  final int bookedCount;

  @JsonKey(defaultValue: [])
  final List<TimeSlot> slots;

  ShiftInfo({
    required this.start, // Thêm vào constructor
    required this.end,   // Thêm vào constructor
    required this.shiftName,
    required this.capacity,
    required this.bookedCount,
    required this.slots,
  });

  factory ShiftInfo.fromJson(Map<String, dynamic> json) =>
      _$ShiftInfoFromJson(json);

  Map<String, dynamic> toJson() => _$ShiftInfoToJson(this);
}