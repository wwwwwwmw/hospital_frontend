// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shift_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ShiftInfo _$ShiftInfoFromJson(Map<String, dynamic> json) => ShiftInfo(
  shiftName: json['shiftName'] as String,
  start: json['start'] as String,
  end: json['end'] as String,
  capacity: (json['capacity'] as num).toInt(),
  bookedCount: (json['bookedCount'] as num).toInt(),
  slots: (json['slots'] as List<dynamic>)
      .map((e) => TimeSlot.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$ShiftInfoToJson(ShiftInfo instance) => <String, dynamic>{
  'shiftName': instance.shiftName,
  'start': instance.start,
  'end': instance.end,
  'capacity': instance.capacity,
  'bookedCount': instance.bookedCount,
  'slots': instance.slots,
};

TimeSlot _$TimeSlotFromJson(Map<String, dynamic> json) =>
    TimeSlot(start: json['start'] as String, end: json['end'] as String);

Map<String, dynamic> _$TimeSlotToJson(TimeSlot instance) => <String, dynamic>{
  'start': instance.start,
  'end': instance.end,
};
