import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../plants/domain/entities/plant.dart';

part 'report.freezed.dart';
part 'report.g.dart';

@freezed
class Report with _$Report {
  const factory Report({
    required String id,
    required DateTime timestamp,
    required String leader,
    required String shift,
    required Plant plant,
    required Map<String, dynamic> data,
    String? notes,
    @Default(false) bool synced,
  }) = _Report;

  factory Report.fromJson(Map<String, dynamic> json) => _$ReportFromJson(json);
}

/// Extensión para facilitar acceso a datos específicos
extension ReportExtension on Report {
  /// Método seguro para obtener números del mapa de datos
  double getNumeric(String key, [double defaultValue = 0.0]) {
    final value = data[key];
    if (value == null) return defaultValue;

    if (value is num) return value.toDouble();
    if (value is String) {
      try {
        return double.parse(value);
      } catch (_) {
        return defaultValue;
      }
    }
    return defaultValue;
  }

  /// Método seguro para obtener strings del mapa de datos
  String getString(String key, [String defaultValue = '']) {
    final value = data[key];
    if (value == null) return defaultValue;
    return value.toString();
  }
}
