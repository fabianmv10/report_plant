import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/plant.dart';

part 'plant_model.freezed.dart';
part 'plant_model.g.dart';

/// Modelo de datos para Plant (extiende la entidad de dominio)
@freezed
class PlantModel with _$PlantModel {
  const PlantModel._();

  const factory PlantModel({
    required String id,
    required String name,
    DateTime? lastSynced,
  }) = _PlantModel;

  /// Crear desde JSON de API
  factory PlantModel.fromJson(Map<String, dynamic> json) =>
      _$PlantModelFromJson(json);

  /// Convertir a entidad de dominio
  Plant toEntity() {
    return Plant(
      id: id,
      name: name,
      lastSynced: lastSynced,
    );
  }

  /// Crear desde entidad de dominio
  factory PlantModel.fromEntity(Plant entity) {
    return PlantModel(
      id: entity.id,
      name: entity.name,
      lastSynced: entity.lastSynced,
    );
  }

  /// Convertir a JSON para base de datos local
  Map<String, dynamic> toJsonForDb() {
    return {
      'id': id,
      'name': name,
      'last_synced': lastSynced?.millisecondsSinceEpoch,
    };
  }
}
