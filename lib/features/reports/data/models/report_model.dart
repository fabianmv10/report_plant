import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../plants/data/models/plant_model.dart';
import '../../../plants/domain/entities/plant.dart';
import '../../domain/entities/report.dart';

part 'report_model.freezed.dart';
part 'report_model.g.dart';

/// Modelo de datos para Report (extiende la entidad de dominio)
@freezed
class ReportModel with _$ReportModel {
  const ReportModel._();

  const factory ReportModel({
    required String id,
    required DateTime timestamp,
    required String leader,
    required String shift,
    required PlantModel plant,
    required Map<String, dynamic> data,
    String? notes,
    @Default(false) bool synced,
  }) = _ReportModel;

  /// Crear desde JSON de API
  factory ReportModel.fromJson(Map<String, dynamic> json) =>
      _$ReportModelFromJson(json);

  /// Convertir a entidad de dominio
  Report toEntity() {
    return Report(
      id: id,
      timestamp: timestamp,
      leader: leader,
      shift: shift,
      plant: plant.toEntity(),
      data: data,
      notes: notes,
      synced: synced,
    );
  }

  /// Crear desde entidad de dominio
  factory ReportModel.fromEntity(Report entity) {
    return ReportModel(
      id: entity.id,
      timestamp: entity.timestamp,
      leader: entity.leader,
      shift: entity.shift,
      plant: PlantModel.fromEntity(entity.plant),
      data: entity.data,
      notes: entity.notes,
      synced: entity.synced,
    );
  }

  /// Convertir a JSON para base de datos local
  Map<String, dynamic> toJsonForDb() {
    return {
      'id': id,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'leader': leader,
      'shift': shift,
      'plant_id': plant.id,
      'data': data,
      'notes': notes,
      'synced': synced ? 1 : 0,
      'created_at': DateTime.now().millisecondsSinceEpoch,
      'updated_at': DateTime.now().millisecondsSinceEpoch,
    };
  }

  /// Crear desde JSON de base de datos local
  factory ReportModel.fromDbJson(Map<String, dynamic> json, Plant plant) {
    return ReportModel(
      id: json['id'] as String,
      timestamp: DateTime.fromMillisecondsSinceEpoch(json['timestamp'] as int),
      leader: json['leader'] as String,
      shift: json['shift'] as String,
      plant: PlantModel.fromEntity(plant),
      data: json['data'] is String
          ? {} // Si es string, parsearlo después
          : Map<String, dynamic>.from(json['data'] as Map),
      notes: json['notes'] as String?,
      synced: (json['synced'] as int) == 1,
    );
  }
}
