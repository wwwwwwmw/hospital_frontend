// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shift_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ShiftInfo _$ShiftInfoFromJson(Map<String, dynamic> json) => ShiftInfo(
  start: json['start'] as String? ?? '',
  end: json['end'] as String? ?? '',
  shiftName: json['shiftName'] as String? ?? 'Unknown Shift',
  capacity: (json['capacity'] as num?)?.toInt() ?? 0,
  bookedCount: (json['bookedCount'] as num?)?.toInt() ?? 0,
  slots:
      (json['slots'] as List<dynamic>?)
          ?.map((e) => TimeSlot.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
);

Map<String, dynamic> _$ShiftInfoToJson(ShiftInfo instance) => <String, dynamic>{
  'start': instance.start,
  'end': instance.end,
  'shiftName': instance.shiftName,
  'capacity': instance.capacity,
  'bookedCount': instance.bookedCount,
  'slots': instance.slots.map((e) => e.toJson()).toList(),
};
