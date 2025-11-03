import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/utils/logger.dart';
import '../../../plants/data/models/plant_model.dart';
import '../../../plants/domain/entities/plant.dart';
import '../models/report_model.dart';

/// Fuente de datos local para reportes (SQLite)
abstract class ReportLocalDataSource {
  Future<List<ReportModel>> getAllReports({int page = 1, int pageSize = 20});
  Future<ReportModel> getReportById(String id);
  Future<List<ReportModel>> getReportsByPlant(String plantId, {int page = 1, int pageSize = 20});
  Future<void> insertReport(ReportModel report);
  Future<void> updateReport(ReportModel report);
  Future<void> deleteReport(String id);
  Future<void> cacheReports(List<ReportModel> reports);
  Future<List<ReportModel>> getPendingReports();
  Future<void> markAsSynced(String id);
}

class ReportLocalDataSourceImpl implements ReportLocalDataSource {
  final Database database;

  ReportLocalDataSourceImpl(this.database);

  @override
  Future<List<ReportModel>> getAllReports({int page = 1, int pageSize = 20}) async {
    try {
      final offset = (page - 1) * pageSize;

      final results = await database.rawQuery('''
        SELECT r.*, p.name as plant_name
        FROM reports r
        JOIN plants p ON r.plant_id = p.id
        ORDER BY r.timestamp DESC
        LIMIT ? OFFSET ?
      ''', [pageSize, offset]);

      return _processReportResults(results);
    } catch (e) {
      logger.error('Error en getAllReports local', e);
      throw CacheException('Error al obtener reportes del caché');
    }
  }

  @override
  Future<ReportModel> getReportById(String id) async {
    try {
      final results = await database.rawQuery('''
        SELECT r.*, p.name as plant_name
        FROM reports r
        JOIN plants p ON r.plant_id = p.id
        WHERE r.id = ?
      ''', [id]);

      if (results.isEmpty) {
        throw CacheException('Reporte no encontrado en caché');
      }

      return _processReportResults(results).first;
    } catch (e) {
      logger.error('Error en getReportById local', e);
      throw CacheException('Error al obtener reporte del caché');
    }
  }

  @override
  Future<List<ReportModel>> getReportsByPlant(
    String plantId, {
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final offset = (page - 1) * pageSize;

      final results = await database.rawQuery('''
        SELECT r.*, p.name as plant_name
        FROM reports r
        JOIN plants p ON r.plant_id = p.id
        WHERE r.plant_id = ?
        ORDER BY r.timestamp DESC
        LIMIT ? OFFSET ?
      ''', [plantId, pageSize, offset]);

      return _processReportResults(results);
    } catch (e) {
      logger.error('Error en getReportsByPlant local', e);
      throw CacheException('Error al obtener reportes por planta del caché');
    }
  }

  @override
  Future<void> insertReport(ReportModel report) async {
    try {
      final reportData = {
        'id': report.id,
        'timestamp': report.timestamp.millisecondsSinceEpoch,
        'leader': report.leader,
        'shift': report.shift,
        'plant_id': report.plant.id,
        'data': jsonEncode(report.data),
        'notes': report.notes,
        'synced': report.synced ? 1 : 0,
        'created_at': DateTime.now().millisecondsSinceEpoch,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      };

      await database.insert(
        'reports',
        reportData,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      logger.error('Error en insertReport local', e);
      throw CacheException('Error al insertar reporte en caché');
    }
  }

  @override
  Future<void> updateReport(ReportModel report) async {
    try {
      final reportData = {
        'timestamp': report.timestamp.millisecondsSinceEpoch,
        'leader': report.leader,
        'shift': report.shift,
        'plant_id': report.plant.id,
        'data': jsonEncode(report.data),
        'notes': report.notes,
        'synced': report.synced ? 1 : 0,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      };

      await database.update(
        'reports',
        reportData,
        where: 'id = ?',
        whereArgs: [report.id],
      );
    } catch (e) {
      logger.error('Error en updateReport local', e);
      throw CacheException('Error al actualizar reporte en caché');
    }
  }

  @override
  Future<void> deleteReport(String id) async {
    try {
      await database.delete(
        'reports',
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      logger.error('Error en deleteReport local', e);
      throw CacheException('Error al eliminar reporte del caché');
    }
  }

  @override
  Future<void> cacheReports(List<ReportModel> reports) async {
    try {
      final batch = database.batch();
      for (var report in reports) {
        final reportData = {
          'id': report.id,
          'timestamp': report.timestamp.millisecondsSinceEpoch,
          'leader': report.leader,
          'shift': report.shift,
          'plant_id': report.plant.id,
          'data': jsonEncode(report.data),
          'notes': report.notes,
          'synced': 1, // Marcar como sincronizado si viene del servidor
          'created_at': DateTime.now().millisecondsSinceEpoch,
          'updated_at': DateTime.now().millisecondsSinceEpoch,
        };

        batch.insert(
          'reports',
          reportData,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      await batch.commit(noResult: true);
    } catch (e) {
      logger.error('Error en cacheReports', e);
      throw CacheException('Error al cachear reportes');
    }
  }

  @override
  Future<List<ReportModel>> getPendingReports() async {
    try {
      final results = await database.rawQuery('''
        SELECT r.*, p.name as plant_name
        FROM reports r
        JOIN plants p ON r.plant_id = p.id
        WHERE r.synced = 0
        ORDER BY r.timestamp ASC
      ''');

      return _processReportResults(results);
    } catch (e) {
      logger.error('Error en getPendingReports', e);
      throw CacheException('Error al obtener reportes pendientes');
    }
  }

  @override
  Future<void> markAsSynced(String id) async {
    try {
      await database.update(
        'reports',
        {'synced': 1, 'updated_at': DateTime.now().millisecondsSinceEpoch},
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      logger.error('Error en markAsSynced', e);
      throw CacheException('Error al marcar reporte como sincronizado');
    }
  }

  List<ReportModel> _processReportResults(List<Map<String, dynamic>> results) {
    return results.map((json) {
      final plant = Plant(
        id: json['plant_id'] as String,
        name: json['plant_name'] as String,
      );

      Map<String, dynamic> reportData;
      try {
        final dataString = json['data'] as String;
        reportData = jsonDecode(dataString) as Map<String, dynamic>;
      } catch (e) {
        logger.warning('Error decodificando data para reporte ${json['id']}', e);
        reportData = {};
      }

      return ReportModel.fromDbJson({
        'id': json['id'],
        'timestamp': json['timestamp'],
        'leader': json['leader'],
        'shift': json['shift'],
        'plant_id': json['plant_id'],
        'data': reportData,
        'notes': json['notes'],
        'synced': json['synced'],
      }, plant);
    }).toList();
  }
}
