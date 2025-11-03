// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'report_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ReportModelImpl _$$ReportModelImplFromJson(Map<String, dynamic> json) =>
    _$ReportModelImpl(
      id: json['id'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      leader: json['leader'] as String,
      shift: json['shift'] as String,
      plant: PlantModel.fromJson(json['plant'] as Map<String, dynamic>),
      data: json['data'] as Map<String, dynamic>,
      notes: json['notes'] as String?,
      synced: json['synced'] as bool? ?? false,
    );

Map<String, dynamic> _$$ReportModelImplToJson(_$ReportModelImpl instance) =>
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
