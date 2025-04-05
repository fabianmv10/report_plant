// lib/services/database_helper.dart
import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import '../models/report.dart';
import 'api_service.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;
  final ApiService _apiService = ApiService.instance;

  DatabaseHelper._init();

  // Inicializar base de datos local (para caché y modo offline)
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('reports_cache.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }
  //ignore: avoid-unused-parameters
  Future _createDB(Database db, int version) async {
    // Crear tabla de plantas
    await db.execute('''
    CREATE TABLE plants(
      id TEXT PRIMARY KEY,
      name TEXT NOT NULL,
      last_synced INTEGER
    )
    ''');

    // Crear tabla de reportes (caché local)
    await db.execute('''
    CREATE TABLE reports(
      id TEXT PRIMARY KEY,
      timestamp INTEGER NOT NULL,
      leader TEXT NOT NULL,
      shift TEXT NOT NULL,
      plant_id TEXT NOT NULL,
      data TEXT NOT NULL,
      notes TEXT,
      synced INTEGER DEFAULT 0,
      FOREIGN KEY (plant_id) REFERENCES plants (id)
    )
    ''');
  }

  // MÉTODOS PARA PLANTAS

  Future<int> insertPlant(Plant plant) async {
    try {
      // Intentar insertar en API remota
      final success = await _apiService.insertPlant(plant);
      
      // Guardar localmente también (para caché)
      final db = await instance.database;
      final plantMap = {
        'id': plant.id,
        'name': plant.name,
        'last_synced': DateTime.now().millisecondsSinceEpoch,
      };
      
      await db.insert('plants', plantMap, 
        conflictAlgorithm: ConflictAlgorithm.replace,);
      
      return success ? 1 : 0;
    } catch (e) {
      if (e is DioException && e.type == DioExceptionType.connectionTimeout) {
        // Sin conexión, guardar solo localmente
        final db = await instance.database;
        final plantMap = {
          'id': plant.id,
          'name': plant.name,
          'last_synced': 0, // No sincronizado
        };
        
        return await db.insert('plants', plantMap, 
          conflictAlgorithm: ConflictAlgorithm.replace,);
      }
      return -1;
    }
  }

  Future<List<Plant>> getAllPlants() async {
    try {
      // Intentar obtener de la API
      final remotePlants = await _apiService.getAllPlants();
      
      // Actualizar caché local
      if (remotePlants.isNotEmpty) {
        final db = await instance.database;
        for (var plant in remotePlants) {
          await db.insert(
            'plants', 
            {
              'id': plant.id,
              'name': plant.name,
              'last_synced': DateTime.now().millisecondsSinceEpoch,
            },
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
      }
      
      return remotePlants;
    } catch (e) {
      // Si hay error de conexión, obtener desde caché local
      final db = await instance.database;
      final result = await db.query('plants');
      
      return result.map((json) => Plant(
        id: json['id'] as String,
        name: json['name'] as String,
      )).toList();
    }
  }

  // MÉTODOS PARA REPORTES

  Future<int> insertReport(Report report) async {
    try {
      // Intentar insertar en API remota
      final success = await _apiService.insertReport(report);
      
      // Guardar localmente también (para caché)
      final db = await instance.database;
      final reportMap = {
        'id': report.id,
        'timestamp': report.timestamp.millisecondsSinceEpoch,
        'leader': report.leader,
        'shift': report.shift,
        'plant_id': report.plant.id,
        'data': jsonEncode(report.data),
        'notes': report.notes,
        'synced': success ? 1 : 0,
      };
      
      await db.insert('reports', reportMap, 
        conflictAlgorithm: ConflictAlgorithm.replace,);
      
      return success ? 1 : 0;
    } catch (e) {
      // Sin conexión, guardar solo localmente
      final db = await instance.database;
      final reportMap = {
        'id': report.id,
        'timestamp': report.timestamp.millisecondsSinceEpoch,
        'leader': report.leader,
        'shift': report.shift,
        'plant_id': report.plant.id,
        'data': jsonEncode(report.data),
        'notes': report.notes,
        'synced': 0,
      };
      
      return await db.insert('reports', reportMap, 
        conflictAlgorithm: ConflictAlgorithm.replace,);
    }
  }

  Future<List<Report>> getAllReports() async {
    try {
      // Intentar obtener de la API
      final remoteReports = await _apiService.getAllReports();
      
      // Actualizar caché local
      if (remoteReports.isNotEmpty) {
        _updateLocalCache(remoteReports);
      }
      
      return remoteReports;
    } catch (e) {
      // Si hay error de conexión, obtener desde caché local
      return _getLocalReports();
    }
  }

  Future<void> _updateLocalCache(List<Report> reports) async {
    final db = await instance.database;
    
    // Primero insertar/actualizar las plantas
    for (var report in reports) {
      await db.insert(
        'plants',
        {
          'id': report.plant.id,
          'name': report.plant.name,
          'last_synced': DateTime.now().millisecondsSinceEpoch,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    
    // Luego los reportes
    for (var report in reports) {
      await db.insert(
        'reports',
        {
          'id': report.id,
          'timestamp': report.timestamp.millisecondsSinceEpoch,
          'leader': report.leader,
          'shift': report.shift,
          'plant_id': report.plant.id,
          'data': jsonEncode(report.data),
          'notes': report.notes,
          'synced': 1,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  Future<List<Report>> _getLocalReports() async {
    final db = await instance.database;
    
    // Obtener reportes con JOIN a plantas
    final results = await db.rawQuery('''
    SELECT r.*, p.name as plant_name
    FROM reports r
    JOIN plants p ON r.plant_id = p.id
    ORDER BY r.timestamp DESC
    ''');
    
    return results.map((json) {
      final plant = Plant(
        id: json['plant_id'] as String,
        name: json['plant_name'] as String,
      );
      
      // Decodificar los datos JSON
      Map<String, dynamic> reportData;
      try {
        reportData = jsonDecode(json['data'] as String);
      } catch (e) {
        reportData = {};
      }
      
      return Report(
        id: json['id'] as String,
        timestamp: DateTime.fromMillisecondsSinceEpoch(json['timestamp'] as int),
        leader: json['leader'] as String,
        shift: json['shift'] as String,
        plant: plant,
        data: reportData,
        notes: json['notes'] as String?,
      );
    }).toList();
  }

  Future<List<Report>> getReportsByPlant(String plantId) async {
    try {
      // Intentar obtener de la API
      final remoteReports = await _apiService.getReportsByPlant(plantId);
      
      // Actualizar caché local
      if (remoteReports.isNotEmpty) {
        _updateLocalCache(remoteReports);
      }
      
      return remoteReports;
    } catch (e) {
      // Si hay error de conexión, obtener desde caché local
      final db = await instance.database;
      
      final results = await db.rawQuery('''
      SELECT r.*, p.name as plant_name
      FROM reports r
      JOIN plants p ON r.plant_id = p.id
      WHERE r.plant_id = ?
      ORDER BY r.timestamp DESC
      ''', [plantId],);
      
      return _processReportResults(results);
    }
  }

  List<Report> _processReportResults(List<Map<String, dynamic>> results) {
    return results.map((json) {
      final plant = Plant(
        id: json['plant_id'] as String,
        name: json['plant_name'] as String,
      );
      
      // Decodificar los datos JSON
      Map<String, dynamic> reportData;
      try {
        reportData = jsonDecode(json['data'] as String);
      } catch (e) {
        reportData = {};
      }
      
      return Report(
        id: json['id'] as String,
        timestamp: DateTime.fromMillisecondsSinceEpoch(json['timestamp'] as int),
        leader: json['leader'] as String,
        shift: json['shift'] as String,
        plant: plant,
        data: reportData,
        notes: json['notes'] as String?,
      );
    }).toList();
  }

  // Sincronización de datos pendientes
  Future<bool> syncPendingReports() async {
    try {
      final db = await instance.database;
      
      // Obtener reportes no sincronizados
      final results = await db.query(
        'reports',
        where: 'synced = ?',
        whereArgs: [0],
      );
      
      if (results.isEmpty) return true;
      
      // Sincronizar cada reporte
      for (var result in results) {
        // Obtener datos de la planta
        final plantId = result['plant_id'] as String;
        final plantResults = await db.query(
          'plants',
          where: 'id = ?',
          whereArgs: [plantId],
        );
        
        if (plantResults.isEmpty) continue;
        
        final plant = Plant(
          id: plantId,
          name: plantResults.first['name'] as String,
        );
        
        // Decodificar los datos JSON
        Map<String, dynamic> reportData;
        try {
          reportData = jsonDecode(result['data'] as String);
        } catch (e) {
          reportData = {};
        }
        
        // Crear objeto reporte
        final report = Report(
          id: result['id'] as String,
          timestamp: DateTime.fromMillisecondsSinceEpoch(result['timestamp'] as int),
          leader: result['leader'] as String,
          shift: result['shift'] as String,
          plant: plant,
          data: reportData,
          notes: result['notes'] as String?,
        );
        
        // Enviar a la API
        final success = await _apiService.insertReport(report);
        
        // Actualizar estado de sincronización
        if (success) {
          await db.update(
            'reports',
            {'synced': 1},
            where: 'id = ?',
            whereArgs: [report.id],
          );
        }
      }
      
      return true;
    } catch (e) {
      return false;
    }
  }

  // Exportación
  Future<bool> exportReportsToCSV() async {
    try {
      final csvUrl = await _apiService.exportReportsToCSV();
      return csvUrl != null;
    } catch (e) {
      return false;
    }
  }

  Future<bool> exportReportsToJSON() async {
    try {
      final jsonUrl = await _apiService.exportReportsToJSON();
      return jsonUrl != null;
    } catch (e) {
      return false;
    }
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}