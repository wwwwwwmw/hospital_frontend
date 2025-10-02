// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'doctor_schedule.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ScheduleBlock _$ScheduleBlockFromJson(Map<String, dynamic> json) =>
    ScheduleBlock(
      start: json['start'] as String,
      end: json['end'] as String,
      slotDurationMin: (json['slotDurationMin'] as num).toInt(),
      capacityPerSlot: (json['capacityPerSlot'] as num).toInt(),
    );

Map<String, dynamic> _$ScheduleBlockToJson(ScheduleBlock instance) =>
    <String, dynamic>{
      'start': instance.start,
      'end': instance.end,
      'slotDurationMin': instance.slotDurationMin,
      'capacityPerSlot': instance.capacityPerSlot,
    };

DoctorSchedule _$DoctorScheduleFromJson(Map<String, dynamic> json) =>
    DoctorSchedule(
      id: json['_id'] as String,
      doctorId: json['doctor'] as String,
      weekday: (json['weekday'] as num).toInt(),
      blocks: (json['blocks'] as List<dynamic>)
          .map((e) => ScheduleBlock.fromJson(e as Map<String, dynamic>))
          .toList(),
      isActive: json['isActive'] as bool,
    );

Map<String, dynamic> _$DoctorScheduleToJson(DoctorSchedule instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'doctor': instance.doctorId,
      'weekday': instance.weekday,
      'blocks': instance.blocks.map((e) => e.toJson()).toList(),
      'isActive': instance.isActive,
    };
