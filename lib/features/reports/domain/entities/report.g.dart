// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'report.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ReportImpl _$$ReportImplFromJson(Map<String, dynamic> json) => _$ReportImpl(
      id: json['id'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      leader: json['leader'] as String,
      shift: json['shift'] as String,
      plant: Plant.fromJson(json['plant'] as Map<String, dynamic>),
      data: json['data'] as Map<String, dynamic>,
      notes: json['notes'] as String?,
      synced: json['synced'] as bool? ?? false,
    );

Map<String, dynamic> _$$ReportImplToJson(_$ReportImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'timestamp': instance.timestamp.toIso8601String(),
      'leader': instance.leader,
      'shift': instance.shift,
      'plant': instance.plant,
      'data': instance.data,
      'notes': instance.notes,
      'synced': instance.synced,
    };
