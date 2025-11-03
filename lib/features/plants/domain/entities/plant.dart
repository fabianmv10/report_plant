import 'package:freezed_annotation/freezed_annotation.dart';

part 'plant.freezed.dart';
part 'plant.g.dart';

@freezed
class Plant with _$Plant {
  const factory Plant({
    required String id,
    required String name,
    DateTime? lastSynced,
  }) = _Plant;

  factory Plant.fromJson(Map<String, dynamic> json) => _$PlantFromJson(json);
}
